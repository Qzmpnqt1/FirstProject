import 'package:flutter/material.dart';
import 'data/datasources/local_storage_data_source.dart';
import 'data/datasources/secure_store_data_source.dart';
import 'data/datasources/hive_data_source.dart';
import 'app/my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Инициализация всех типов хранилищ
  await LocalStorageDataSource.init();
  await SecureStoreDataSource.init();
  await HiveDataSource.init();
  // Drift инициализируется при создании AppDatabase
  
  runApp(const MyApp());
}
