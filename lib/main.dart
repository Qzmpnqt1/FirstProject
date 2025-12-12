import 'package:flutter/material.dart';
import 'data/datasources/local_storage_data_source.dart';
import 'app/my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageDataSource.init();
  runApp(const MyApp());
}
