import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/classes/event_list.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/AppointmentsDBWorker.dart';
import '../models/AppointmentsModel.dart';

class AppointmentsList extends StatelessWidget {
  _showAppointmentTime(DateTime date, inContext) async {
    showModalBottomSheet(
        context: inContext,
        builder: (inContext) {
          return Scaffold(
            body: Container(
              padding: EdgeInsets.all(10),
              child: GestureDetector(
                child: Column(
                  children: [
                    Text(
                      DateFormat.yMMMd("en_US").format(
                        date.toLocal(),
                      ),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(inContext).accentColor,
                        fontSize: 24,
                      ),
                    ),
                    Divider(),
                    Expanded(
                      child: ListView.builder(
                          itemCount: apptsModel.entityList.length,
                          itemBuilder: (inContext, int index) {
                            Appointment appt = apptsModel.entityList[index];
                            if (appt.apptDate !=
                                "${date.year}, ${date.month}, ${date.day}") {
                              return Container(
                                height: 10,
                              );
                            }
                            String apptTime = '';
                            if (appt.apptTime != null) {
                              List timeParts = appt.apptTime!.split(',');
                              TimeOfDay at = TimeOfDay(
                                  hour: int.parse(timeParts[0]),
                                  minute: int.parse(timeParts[1]));
                              apptTime = "(${at.format(inContext)})";
                            }
                            return Slidable(
                              actionPane: SlidableDrawerActionPane(),
                              actionExtentRatio: 0.25,
                              child: Container(
                                margin: EdgeInsets.only(bottom: 8),
                                color: Colors.grey.shade300,
                                child: ListTile(
                                  title: Text("${appt.title} by $apptTime"),
                                  subtitle: appt.description == null
                                      ? null
                                      : Text("${appt.description}"),
                                  onTap: () async {
                                    _editAppointment(inContext, appt);
                                  },
                                ),
                              ),
                              secondaryActions: [
                                IconSlideAction(
                                  caption: "Delete",
                                  icon: Icons.delete,
                                  color: Colors.red,
                                  onTap: () => _deleteAppointment,
                                )
                              ],
                            );
                          }),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  Future _deleteAppointment(BuildContext inContext, Appointment inAppointment) {
    return showDialog(
        context: inContext,
        builder: (inAlertContext) {
          return AlertDialog(
            title: Text("Delete Appointment"),
            content:
                Text('Are you sure you want to delete ${inAppointment.title}?'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(inAlertContext).pop();
                  },
                  child: Text('Cancel')),
              TextButton(
                  onPressed: () async {
                    await AppointmentsDBWorker.db.delete(inAppointment.id!);
                    Navigator.of(inAlertContext).pop();
                    ScaffoldMessenger.of(inContext).showSnackBar(SnackBar(
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 2),
                        content: Text("Appointment deleted")));
                    apptsModel.loadData(
                        "appointments", AppointmentsDBWorker.db);
                  },
                  child: Text('Delete'))
            ],
          );
        });
  }

  void _editAppointment(BuildContext context, Appointment inAppointment) async {
    apptsModel.entityBeingEdited =
        await AppointmentsDBWorker.db.get(inAppointment.id!);
    if (apptsModel.entityBeingEdited.apptDate == null) {
      apptsModel.setChosenDate('');
    } else {
      List dateParts = apptsModel.entityBeingEdited.apptDate.split(",");
      DateTime apptDate = DateTime(int.parse(dateParts[0]),
          int.parse(dateParts[1]), int.parse(dateParts[2]));
      apptsModel.setChosenDate(
        DateFormat.yMMMd("en_US").format(apptDate.toLocal()),
      );
    }
    if (apptsModel.entityBeingEdited.apptTime == null) {
      apptsModel.setApptTime('');
    } else {
      List timeParts = apptsModel.entityBeingEdited.apptTime.split(',');
      TimeOfDay apptTime = TimeOfDay(
          hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));
      apptsModel.setApptTime(apptTime.format(context));
    }
    apptsModel.setStackIndex(1);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    EventList<Event> _markedDateMap = EventList(events: {});
    for (int i = 0; i < apptsModel.entityList.length; i++) {
      Appointment appointment = apptsModel.entityList[i];
      List dateParts = appointment.apptDate!.split(',');
      DateTime apptDate = DateTime(int.parse(dateParts[0]),
          int.parse(dateParts[1]), int.parse(dateParts[2]));
      _markedDateMap.add(
          apptDate,
          Event(
              date: apptDate,
              icon: Container(
                decoration: BoxDecoration(color: Colors.blue),
              )));
    }
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
          onPressed: () async {
            apptsModel = Provider.of<AppointmentsModel>(context, listen: false);
            apptsModel.entityBeingEdited = Appointment();
            DateTime now = DateTime.now();
            apptsModel.entityBeingEdited.apptDate =
                "${now.year},${now.month},${now.day}";
            apptsModel.setChosenDate(
                DateFormat.yMMMMd("en_US").format(now.toLocal()));
            // apptsModel.setApptTime(null);
            apptsModel.setStackIndex(1);
          }),
      body: Column(
        children: [
          Expanded(
            child: Container(
                margin: EdgeInsets.symmetric(horizontal: 10),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      minHeight: 500,
                      maxHeight: MediaQuery.of(context).size.height * 0.8,
                      minWidth: MediaQuery.of(context).size.width),
                  child: CalendarCarousel<Event>(
                    thisMonthDayBorderColor: Colors.grey,
                    daysHaveCircularBorder: true,
                    markedDatesMap: _markedDateMap,
                    onDayPressed: (DateTime inApptTime, List<Event> inEvents) {
                      _showAppointmentTime(inApptTime, context);
                    },
                  ),
                )),
          )
        ],
      ),
    );
  }
}
