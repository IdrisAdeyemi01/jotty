import 'package:flutter/material.dart';
import 'package:flutter_book/models/AppointmentsModel.dart';
import 'package:provider/provider.dart';

import '../services/AppointmentsDBWorker.dart';
import 'AppointmentsEntry.dart';
import 'AppointmentsList.dart';

class Appointments extends StatelessWidget {
  Appointments() {
    apptsModel.loadData('notes', AppointmentsDBWorker.db);
    apptsModel.rebuidWidgets();
  }
  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: Provider.of<AppointmentsModel>(context).stackIndex,
      children: [
        AppointmentsList(),
        AppointmentsEntry(),
      ],
    );
  }
}
