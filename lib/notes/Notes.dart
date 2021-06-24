import 'package:flutter/material.dart';
import 'package:flutter_book/models/NotesModel.dart';
import 'package:provider/provider.dart';
import '../services/NotesDBWorker.dart';
import 'NotesList.dart';
import 'NotesEntry.dart';

class Notes extends StatelessWidget {
  Notes() {
    notesModel.loadData('notes', NotesDBWorker.db);
  }
  @override
  Widget build(BuildContext context) {
    return IndexedStack(
        index: Provider.of<NotesModel>(context).stackIndex,
        children: [
          NotesList(),
          NotesEntry(),
        ]);
  }
}
