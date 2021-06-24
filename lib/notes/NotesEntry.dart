import 'package:flutter/material.dart';
import '../services/NotesDBWorker.dart';
import '../models/NotesModel.dart' show NotesModel, notesModel;

class NotesEntry extends StatelessWidget {
  NotesEntry() {
    _titleEditingController.addListener(() {
      notesModel.entityBeingEdited.title = _titleEditingController.text;
    });
    _contentEditingController.addListener(() {
      notesModel.entityBeingEdited.content = _contentEditingController.text;
    });
  }

  final TextEditingController _titleEditingController = TextEditingController();
  final TextEditingController _contentEditingController =
      TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _save(BuildContext inContext, NotesModel inModel) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (inModel.entityBeingEdited.id == null) {
      await NotesDBWorker.db.create(notesModel.entityBeingEdited);
    } else {
      await NotesDBWorker.db.update(notesModel.entityBeingEdited);
    }
    inModel.loadData("notes", NotesDBWorker.db);
    inModel.setStackIndex(0);
    ScaffoldMessenger.of(inContext).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
        content: Text("Note saved"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (notesModel.entityBeingEdited == null) {
      _titleEditingController.text = '';
      _contentEditingController.text = '';
    } else {
      _titleEditingController.text = notesModel.entityBeingEdited.title;
      _contentEditingController.text = notesModel.entityBeingEdited.content;
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
                notesModel.setStackIndex(0);
              },
            ),
            TextButton(
                onPressed: () {
                  _save(context, notesModel);
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
              leading: Icon(Icons.title),
              title: TextFormField(
                decoration: InputDecoration(hintText: "Title"),
                controller: _titleEditingController,
                validator: (String? value) {
                  if (value!.length == 0) {
                    return "Please enter a title";
                  }
                  return null;
                },
              ),
            ),
            ListTile(
              leading: Icon(Icons.content_paste),
              title: TextFormField(
                  keyboardType: TextInputType.multiline,
                  maxLines: 16,
                  decoration: InputDecoration(hintText: "Content"),
                  controller: _contentEditingController,
                  validator: (inValue) {
                    if (inValue!.length == 0) {
                      return "Please enter content";
                    }
                    return null;
                  }),
            ),
            ListTile(
                leading: Icon(Icons.color_lens),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ColorBox(
                      color: Colors.red,
                      colorText: "red",
                    ),
                    ColorBox(
                      color: Colors.green,
                      colorText: "green",
                    ),
                    ColorBox(
                      color: Colors.blue,
                      colorText: "blue",
                    ),
                    ColorBox(
                      color: Colors.yellow,
                      colorText: "yellow",
                    ),
                    ColorBox(
                      color: Colors.grey,
                      colorText: "grey",
                    ),
                    ColorBox(
                      color: Colors.purple,
                      colorText: "purple",
                    )
                  ],
                ))
          ],
        ),
      ),
    );
  }
}

class ColorBox extends StatelessWidget {
  const ColorBox({Key? key, @required this.color, @required this.colorText})
      : super(key: key);
  final Color? color;
  final String? colorText;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: Container(
          decoration: ShapeDecoration(
            shape: Border.all(width: 18, color: color!) +
                Border.all(
                    width: 6,
                    color: notesModel.color == colorText
                        ? color!
                        : Theme.of(context).canvasColor),
          ),
        ),
        onTap: () {
          notesModel.entityBeingEdited.color = colorText!;
          notesModel.setColor(colorText!);
        });
  }
}
