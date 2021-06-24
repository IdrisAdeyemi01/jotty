import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'utilities/BaseModel.dart';
import 'app_entry.dart';
import 'utilities/utils.dart' as utils;
import 'package:path_provider/path_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  startMeUp() async {
    Directory docsDir = await getApplicationDocumentsDirectory();
    utils.docsDir = docsDir;
  }

  runApp(MyApp());
  startMeUp();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BaseModel(),
      child: FlutterBook(),
    );
  }
}
