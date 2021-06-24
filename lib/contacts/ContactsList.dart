import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_book/services/ContactsDBWorker.dart';
import 'package:flutter_book/utilities/utils.dart' as utils;
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

import '../models/ContactsModel.dart';

class ContactsList extends StatelessWidget {
  Future<void> _deleteContact(BuildContext inContext, Contact inContact) async {
    return showDialog(
        context: inContext,
        builder: (inContext) {
          return AlertDialog(
            title: Text("Delete Contact"),
            content: Text("Are you sure you want to delete ${inContact.name}"),
            actions: [
              TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(inContext).pop();
                  }),
              TextButton(
                  onPressed: () async {
                    File avatarFile = File(
                        join(utils.docsDir!.path, inContact.id.toString()));
                    if (avatarFile.existsSync()) {
                      avatarFile.deleteSync();
                    }
                    await ContactsDBWorker.db.delete(inContact.id!);
                    Navigator.pop(inContext);
                    ScaffoldMessenger.of(inContext).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 2),
                        content: Text("Contact deleted"),
                      ),
                    );
                    contactsModel.triggerRebuild();
                    contactsModel.loadData("contacts", ContactsDBWorker.db);
                  },
                  child: Text('Delete'))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          contactsModel = Provider.of<ContactsModel>(context, listen: false);
          File avatarFile = File(join(utils.docsDir!.path, "avatar"));
          if (avatarFile.existsSync()) {
            avatarFile.deleteSync();
          }
          contactsModel.entityBeingEdited = Contact();
          contactsModel.setStackIndex(1);
        },
      ),
      body: contactsModel.entityList.isEmpty
          ? Center(child: Text('You have not saved any contact yet'))
          : Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListView.builder(
                  itemCount: contactsModel.entityList.length,
                  itemBuilder: (context, index) {
                    Contact contact = contactsModel.entityList[index];
                    File avatarFile =
                        File(join(utils.docsDir!.path, contact.id.toString()));
                    bool avatarFileExists = avatarFile.existsSync();
                    return Column(
                      children: [
                        Slidable(
                          actionPane: SlidableDrawerActionPane(),
                          actionExtentRatio: 0.25,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.indigoAccent,
                              foregroundColor: Colors.white,
                              backgroundImage: avatarFileExists
                                  ? FileImage(avatarFile)
                                  : null,
                              child: avatarFileExists
                                  ? null
                                  : Text(
                                      contact.name!
                                          .substring(0, 1)
                                          .toUpperCase(),
                                    ),
                            ),
                            title: Text("${contact.name!}"),
                            subtitle: contact.phone == null
                                ? null
                                : Text("${contact.phone}"),
                            onTap: () async {
                              contactsModel = Provider.of<ContactsModel>(
                                  context,
                                  listen: false);
                              File avatarFile =
                                  File(join(utils.docsDir!.path, "avatar"));
                              print(avatarFile);
                              if (avatarFile.existsSync()) {
                                avatarFile.deleteSync();
                              }
                              contactsModel.entityBeingEdited =
                                  await ContactsDBWorker.db.get(contact.id!);
                              if (contactsModel.entityBeingEdited.birthday ==
                                  null) {
                                contactsModel.setChosenDate(
                                    DateFormat.yMMMd('en_US')
                                        .format(DateTime.now().toLocal()));
                              } else {
                                print(contactsModel.entityBeingEdited.birthday);
                                List dateParts = contactsModel
                                    .entityBeingEdited.birthday
                                    .split(',');
                                DateTime birthday;
                                if (dateParts.length == 1) {
                                  birthday = DateTime.now();
                                } else {
                                  print(dateParts.length);
                                  birthday = DateTime(
                                      int.parse(dateParts[0]),
                                      int.parse(dateParts[1]),
                                      int.parse(dateParts[2]));
                                }

                                contactsModel.setChosenDate(
                                  DateFormat.yMMMd('en_US')
                                      .format(birthday.toLocal()),
                                );
                                contactsModel.setStackIndex(1);
                              }
                            },
                          ),
                          secondaryActions: [
                            IconSlideAction(
                              icon: Icons.delete,
                              caption: "Delete",
                              color: Colors.red,
                              onTap: () => _deleteContact(context, contact),
                            ),
                          ],
                        ),
                        Divider(),
                      ],
                    );
                  }),
            ),
    );
  }
}
