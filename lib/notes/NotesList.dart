import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../services/NotesDBWorker.dart';
import '../models/NotesModel.dart' show Note, NotesModel, notesModel;

class NotesList extends StatelessWidget {
  Future _deleteNote(BuildContext inContext, Note inNote) {
    return showDialog(
        context: inContext,
        builder: (inAlertContext) {
          return AlertDialog(
            title: Text("Delete Note"),
            content: Text('Are you sure you want to delete ${inNote.title}?'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(inAlertContext).pop();
                  },
                  child: Text('Cancel')),
              TextButton(
                  onPressed: () async {
                    await NotesDBWorker.db.delete(inNote.id!);
                    Navigator.of(inAlertContext).pop();
                    ScaffoldMessenger.of(inContext).showSnackBar(SnackBar(
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 2),
                        content: Text("Note deleted")));
                    notesModel.loadData("notes", NotesDBWorker.db);
                  },
                  child: Text('Delete'))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    int entityLength = notesModel.entityList.length;
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add, color: Colors.white),
          onPressed: () {
            notesModel = Provider.of<NotesModel>(context, listen: false);
            notesModel.entityBeingEdited = Note();
            notesModel.setColor('');
            notesModel.setStackIndex(1);
          },
        ),
        body: notesModel.entityList.isEmpty
            ? Center(
                child: Text(
                'No note to display yet... \n Kindly add a note',
                textAlign: TextAlign.center,
              ))
            : ListView.builder(
                itemCount: entityLength,
                itemBuilder: (context, entityLength) {
                  Note note = notesModel.entityList[entityLength];

                  Color color = Colors.white;
                  switch (note.color) {
                    case "red":
                      color = Colors.red;
                      break;
                    case "green":
                      color = Colors.green;
                      break;
                    case "blue":
                      color = Colors.blue;
                      break;
                    case "yellow":
                      color = Colors.yellow;
                      break;
                    case "grey":
                      color = Colors.grey;
                      break;
                    case "purple":
                      color = Colors.purple;
                      break;
                  }
                  return Container(
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Slidable(
                      actionPane: SlidableDrawerActionPane(),
                      child: Card(
                        elevation: 8,
                        color: color,
                        child: ListTile(
                            title: Text("${note.title}"),
                            subtitle: Text("${note.content}"),
                            onTap: () async {
                              notesModel = Provider.of<NotesModel>(context,
                                  listen: false);
                              notesModel.entityBeingEdited =
                                  await NotesDBWorker.db.get(note.id!);
                              notesModel
                                  .setColor(notesModel.entityBeingEdited.color);
                              notesModel.setStackIndex(1);
                            }),
                      ),
                      actionExtentRatio: .25,
                      actions: [
                        IconSlideAction(
                            caption: 'Delete',
                            color: Colors.red,
                            icon: Icons.delete,
                            onTap: () => _deleteNote(context, note))
                      ],
                    ),
                  );
                }));
  }
}
