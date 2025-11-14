// lib/main.dart
import 'package:flutter/material.dart';
import 'data/storage.dart';
import 'app/my_app.dart';
import 'app/di.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Инициализируем storage
  await Storage.init();

  // 2. Настраиваем DI (регистрируем AppState в GetIt)
  setupDI();

  // 3. Запускаем приложение
  runApp(const MyApp());
}
