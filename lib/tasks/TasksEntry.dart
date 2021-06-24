import 'package:flutter/material.dart';
import 'package:flutter_book/models/TasksModel.dart';
import 'package:flutter_book/utilities/utils.dart' as utils;
import '../services/TasksDBWorker.dart';
import '../models/TasksModel.dart';

class TasksEntry extends StatelessWidget {
  TasksEntry() {
    _descriptionController.addListener(() {
      tasksModel.entityBeingEdited.description = _descriptionController.text;
    });
  }
  final TextEditingController _descriptionController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _save(BuildContext inContext, TasksModel inModel) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (inModel.entityBeingEdited.id == null) {
      await TasksDBWorker.db.create(tasksModel.entityBeingEdited);
    } else {
      await TasksDBWorker.db.update(tasksModel.entityBeingEdited);
    }
    inModel.loadData("tasks", TasksDBWorker.db);
    inModel.setStackIndex(0);
    ScaffoldMessenger.of(inContext).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
        content: Text("Task saved"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (tasksModel.entityBeingEdited == null) {
      _descriptionController.text = '';
    } else {
      // tasksModel.entityBeingEdited.description;
      _descriptionController.text = tasksModel.entityBeingEdited.description;
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
                  tasksModel.setStackIndex(0);
                },
              ),
              TextButton(
                  onPressed: () {
                    _save(context, tasksModel);
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
                  leading: Icon(Icons.description),
                  title: TextFormField(
                    keyboardType: TextInputType.multiline,
                    maxLines: 5,
                    decoration: InputDecoration(hintText: "Description"),
                    controller: _descriptionController,
                    onChanged: (val) {},
                    validator: (String? value) {
                      if (value!.length == 0) {
                        return "Please enter a description";
                      }
                      return null;
                    },
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.today),
                  title: Text("Due Date"),
                  subtitle: Text(tasksModel.chosenDate == null
                      ? ""
                      : tasksModel.chosenDate!),
                  trailing: IconButton(
                      icon: Icon(Icons.edit),
                      color: Colors.blue,
                      onPressed: () async {
                        String chosenDate = await utils.selectDate(
                          context,
                          tasksModel,
                          tasksModel.entityBeingEdited.dueDate == null
                              ? ''
                              : tasksModel.entityBeingEdited.dueDate,
                        );
                        // ignore: unnecessary_null_comparison
                        if (chosenDate != null) {
                          tasksModel.entityBeingEdited.dueDate = chosenDate;
                        }
                      }),
                )
              ],
            )));
  }
}
