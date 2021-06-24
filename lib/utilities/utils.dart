import 'package:flutter/material.dart';
import 'dart:io';
import 'BaseModel.dart';
import 'package:intl/intl.dart';

Directory? docsDir;
Future selectDate(
    BuildContext inContext, BaseModel inModel, String inDateString) async {
  DateTime initialDate = DateTime.now();

  if (inDateString.isNotEmpty) {
    List dateParts = inDateString.split(',');
    initialDate = DateTime(int.parse(dateParts[0]), int.parse(dateParts[1]),
        int.parse(dateParts[2]));
  }
  DateTime? picked = await showDatePicker(
      context: inContext,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100));

  if (picked != null) {
    inModel.setChosenDate(DateFormat.yMMMMd('en_US').format(picked.toLocal()));
    return "${picked.year}, ${picked.month}, ${picked.day}";
  } else {
    picked = DateTime.now();
    inModel.setChosenDate(DateFormat.yMMMMd('en_US').format(picked.toLocal()));
    return "${picked.year}, ${picked.month}, ${picked.day}";
  }
}
