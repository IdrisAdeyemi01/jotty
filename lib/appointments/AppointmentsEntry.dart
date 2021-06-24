import 'package:flutter/material.dart';
import '../services/AppointmentsDBWorker.dart';
import '../models/AppointmentsModel.dart';
import 'package:flutter_book/utilities/utils.dart' as utils;

class AppointmentsEntry extends StatelessWidget {
  AppointmentsEntry() {
    _titleController.addListener(() {
      apptsModel.entityBeingEdited.title = _titleController.text;
    });
    _descriptionController.addListener(() {
      apptsModel.entityBeingEdited.description = _descriptionController.text;
    });
  }

  _save(BuildContext context, AppointmentsModel inModel) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (inModel.entityBeingEdited.id == null) {
      await AppointmentsDBWorker.db.create(apptsModel.entityBeingEdited);
    } else {
      await AppointmentsDBWorker.db.update(apptsModel.entityBeingEdited);
    }
    inModel.loadData("appointments", AppointmentsDBWorker.db);
    inModel.setStackIndex(0);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
        content: Text("Appointment saved"),
      ),
    );
  }

  _selectTime(BuildContext context) async {
    TimeOfDay initialTime = TimeOfDay.now();
    if (apptsModel.entityBeingEdited.apptTime != null) {
      List timeParts = apptsModel.entityBeingEdited.apptTime.split(',');
      initialTime = TimeOfDay(
          hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));
    }
    TimeOfDay? picked =
        await showTimePicker(context: context, initialTime: initialTime);
    if (picked != null) {
      apptsModel.entityBeingEdited.apptTime =
          "${picked.hour}, ${picked.minute}";
      apptsModel.setApptTime(picked.format(context));
    }
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    if (apptsModel.entityBeingEdited == null) {
      _titleController.text = '';
      _descriptionController.text = '';
    } else {
      _titleController.text = apptsModel.entityBeingEdited.title;
      _descriptionController.text = apptsModel.entityBeingEdited.description;
    }

    return Scaffold(
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                FocusScope.of(context).requestFocus(FocusNode());
                apptsModel.setStackIndex(0);
              },
            ),
            TextButton(
                onPressed: () {
                  _save(context, apptsModel);
                },
                child: Text('Save'))
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            ListTile(
              leading: Icon(Icons.notes),
              title: TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(hintText: "Title"),
                  validator: (inValue) {
                    if (inValue!.length == 0) {
                      return "Please enter content";
                    }
                    return null;
                  }),
            ),
            ListTile(
              leading: Icon(Icons.description),
              title: TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(hintText: "Description"),
                  keyboardType: TextInputType.multiline,
                  maxLines: 7,
                  validator: (inValue) {
                    if (inValue!.length == 0) {
                      return "Please enter content";
                    }
                    return null;
                  }),
            ),
            ListTile(
              leading: Icon(Icons.today),
              title: Text("Date"),
              subtitle: Text(apptsModel.chosenDate == null
                  ? "${DateTime.now().day}"
                  : apptsModel.chosenDate!),
              trailing: IconButton(
                  icon: Icon(Icons.edit),
                  color: Colors.blue,
                  onPressed: () async {
                    String chosenDate = await utils.selectDate(
                      context,
                      apptsModel,
                      apptsModel.entityBeingEdited.apptDate == null
                          ? ''
                          : apptsModel.entityBeingEdited.apptDate,
                    );
                    if (chosenDate != null) {
                      apptsModel.entityBeingEdited.apptDate = chosenDate;
                    }
                  }),
            ),
            ListTile(
              leading: Icon(Icons.alarm),
              title: Text("Time"),
              subtitle:
                  Text(apptsModel.apptTime == null ? "" : apptsModel.apptTime!),
              trailing: IconButton(
                icon: Icon(Icons.edit),
                color: Colors.blue,
                onPressed: () => _selectTime(context),
              ),
            )
          ],
        ),
      ),
    );
  }
}
