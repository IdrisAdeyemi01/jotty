import 'package:flutter/material.dart';
import 'package:flutter_book/services/TasksDBWorker.dart';
import 'package:flutter_book/models/TasksModel.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TasksList extends StatelessWidget {
  Future _deleteTask(BuildContext inContext, Task inTask) {
    return showDialog(
        context: inContext,
        builder: (inAlertContext) {
          return AlertDialog(
            title: Text("Delete Task"),
            content: Text('Are you sure you want to delete this task?'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(inAlertContext).pop();
                  },
                  child: Text('Cancel')),
              TextButton(
                  onPressed: () async {
                    await TasksDBWorker.db.delete(inTask.id!);
                    Navigator.of(inAlertContext).pop();
                    ScaffoldMessenger.of(inContext).showSnackBar(SnackBar(
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 2),
                        content: Text("Task deleted")));
                    tasksModel.loadData("tasks", TasksDBWorker.db);
                  },
                  child: Text('Delete'))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    int entityLength = tasksModel.entityList.length;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () {
          tasksModel = Provider.of<TasksModel>(context, listen: false);
          tasksModel.entityBeingEdited = Task();
          tasksModel.setStackIndex(1);
        },
      ),
      body: tasksModel.entityList.isEmpty
          ? Center(
              child: Text('You have no added task(s) yet'),
            )
          : ListView.builder(
              itemCount: entityLength,
              itemBuilder: (context, entityLength) {
                Task task = tasksModel.entityList[entityLength];
                String? sDueDate;
                if (task.dueDate != null) {
                  List dateParts = task.dueDate!.split(",");
                  DateTime dueDate = DateTime(int.parse(dateParts[0]),
                      int.parse(dateParts[1]), int.parse(dateParts[2]));
                  sDueDate =
                      DateFormat.yMMMMd("en_US").format(dueDate.toLocal());
                }

                return Slidable(
                  actionPane: SlidableDrawerActionPane(),
                  actionExtentRatio: 0.25,
                  child: ListTile(
                    leading: Checkbox(
                      value: task.completed == "true" ? true : false,
                      onChanged: (val) async {
                        tasksModel =
                            Provider.of<TasksModel>(context, listen: false);
                        task.completed = val.toString();
                        await TasksDBWorker.db.update(task);
                        tasksModel.loadData('tasks', TasksDBWorker.db);
                      },
                    ),
                    title: Text(
                      "${task.description}",
                      style: task.completed == true.toString()
                          ? TextStyle(
                              color: Theme.of(context).disabledColor,
                              decoration: TextDecoration.lineThrough)
                          : TextStyle(
                              color:
                                  Theme.of(context).textTheme.headline6!.color),
                    ),
                    subtitle: task.dueDate == null
                        ? null
                        : Text(
                            sDueDate!,
                            style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .headline6!
                                    .color),
                          ),
                    onTap: () async {
                      if (task.completed == "true") {
                        return;
                      }
                      tasksModel =
                          Provider.of<TasksModel>(context, listen: false);
                      tasksModel.entityBeingEdited =
                          await TasksDBWorker.db.get(task.id!);
                      if (tasksModel.entityBeingEdited.dueDate == null) {
                        tasksModel.setChosenDate('');
                      } else {
                        tasksModel.setChosenDate(sDueDate!);
                      }
                      tasksModel.setStackIndex(1);
                    },
                  ),
                  secondaryActions: [
                    IconSlideAction(
                        caption: "Delete",
                        color: Colors.red,
                        icon: Icons.delete,
                        onTap: () => _deleteTask(context, task))
                  ],
                );
              }),
    );
  }
}
