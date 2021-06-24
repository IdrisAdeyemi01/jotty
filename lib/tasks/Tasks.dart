import 'package:flutter/material.dart';
import 'package:flutter_book/tasks/TasksList.dart';
import 'package:flutter_book/models/TasksModel.dart';
import 'package:provider/provider.dart';
import '../services/TasksDBWorker.dart';
import 'TasksEntry.dart';

class Tasks extends StatelessWidget {
  Tasks() {
    tasksModel.loadData('tasks', TasksDBWorker.db);
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: Provider.of<TasksModel>(context).stackIndex,
      children: [
        TasksList(),
        TasksEntry(),
      ],
    );
  }
}
