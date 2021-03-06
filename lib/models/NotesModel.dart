import 'package:flutter_book/utilities/BaseModel.dart';

class Note {
  int? id;
  String title = '';
  String content = '';
  String color = '';

  @override
  toString() {
    return "{id=$id, title=$title, content=$content, color=$color}";
  }
}

class NotesModel extends BaseModel {
  String? color;
  void setColor(String inColor) {
    color = inColor;
    notifyListeners();
  }
}

NotesModel notesModel = NotesModel();
