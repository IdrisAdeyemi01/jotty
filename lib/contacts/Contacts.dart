import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/ContactsDBWorker.dart';
import 'ContactsEntry.dart';
import 'ContactsList.dart';
import '../models/ContactsModel.dart';

class Contacts extends StatelessWidget {
  Contacts() {
    contactsModel.loadData('contacts', ContactsDBWorker.db);
    contactsModel.rebuidWidgets();
  }
  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: Provider.of<ContactsModel>(context).stackIndex,
      children: [
        ContactsList(),
        ContactsEntry(),
      ],
    );
  }
}
