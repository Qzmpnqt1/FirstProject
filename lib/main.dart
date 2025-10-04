import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app/app_state.dart';
import 'data/storage.dart';
import 'app/my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Storage.init();
  runApp(const MyApp());
}