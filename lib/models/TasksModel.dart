import 'package:flutter_book/utilities/BaseModel.dart';

class Task {
  int? id;
  String description = '';
  String? dueDate;
  String? completed;
}

class TasksModel extends BaseModel {}

TasksModel tasksModel = TasksModel();
