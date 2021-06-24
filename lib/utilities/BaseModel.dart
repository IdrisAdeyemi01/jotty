import 'package:flutter/material.dart';

class BaseModel extends ChangeNotifier {
  int stackIndex = 0;
  List entityList = [];
  var entityBeingEdited;
  String? chosenDate;

  void setChosenDate(String date) {
    chosenDate = date;
    notifyListeners();
  }

  Future<void> loadData(String inEntityType, dynamic inDatabase) async {
    entityList = await inDatabase.getAll();
    notifyListeners();
  }

  void setStackIndex(int inStackIndex) {
    stackIndex = inStackIndex;
    notifyListeners();
  }

  void rebuidWidgets() {
    notifyListeners();
  }
}
