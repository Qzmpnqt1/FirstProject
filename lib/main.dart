import 'package:flutter/material.dart';
import 'data/storage.dart';
import 'app/my_app_go_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Storage.init();
  runApp(const MyAppGoRouter());
}
