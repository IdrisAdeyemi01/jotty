import 'package:flutter/material.dart';
import 'package:flutter_book/appointments/Appointments.dart';
import 'package:flutter_book/contacts/Contacts.dart';
import 'package:flutter_book/notes/Notes.dart';
import 'package:flutter_book/tasks/Tasks.dart';
import 'package:flutter_book/models/TasksModel.dart';
import 'package:provider/provider.dart';

import 'models/AppointmentsModel.dart';
import 'models/ContactsModel.dart';
import 'models/NotesModel.dart';

class FlutterBook extends StatelessWidget {
  const FlutterBook({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Flutter Book'),
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.date_range), text: 'Appointments'),
              Tab(icon: Icon(Icons.contacts), text: 'Contacts'),
              Tab(icon: Icon(Icons.notes), text: 'Notes'),
              Tab(icon: Icon(Icons.assignment_turned_in), text: 'Tasks'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ChangeNotifierProvider<AppointmentsModel>(
              create: (_) => AppointmentsModel(),
              child: Appointments(),
            ),
            ChangeNotifierProvider<ContactsModel>(
              create: (_) => ContactsModel(),
              child: Contacts(),
            ),
            ChangeNotifierProvider<NotesModel>(
              create: (_) => NotesModel(),
              child: Notes(),
            ),
            ChangeNotifierProvider<TasksModel>(
              create: (_) => TasksModel(),
              child: Tasks(),
            ),
          ],
        ),
      ),
    ));
  }
}
