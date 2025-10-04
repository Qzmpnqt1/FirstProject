import 'package:flutter/foundation.dart' show ValueNotifier;
import '../data/storage.dart';
import '../data/task.dart';

class AppState {
  // Тема/настройки
  final themeDark = ValueNotifier<bool>(Storage.getDark());
  final notifications = ValueNotifier<bool>(Storage.getNotifications());
  final analytics = ValueNotifier<bool>(Storage.getAnalytics());

  // Профиль
  final name = ValueNotifier<String>(Storage.getName());
  final role = ValueNotifier<String>(Storage.getRole());

  // Данные
  final counter = ValueNotifier<int>(Storage.getCounter());
  final tasks = ValueNotifier<List<Task>>(Storage.getTasks());

  // --- операции с персистом ---
  Future<void> setDark(bool v) async { themeDark.value = v; await Storage.setDark(v); }
  Future<void> setNotifications(bool v) async { notifications.value = v; await Storage.setNotifications(v); }
  Future<void> setAnalytics(bool v) async { analytics.value = v; await Storage.setAnalytics(v); }

  Future<void> setName(String v) async { name.value = v; await Storage.setName(v); }
  Future<void> setRole(String v) async { role.value = v; await Storage.setRole(v); }

  Future<void> setCounter(int v) async { counter.value = v; await Storage.setCounter(v); }
  Future<void> incCounter() => setCounter(counter.value + 1);
  Future<void> decCounter() => setCounter(counter.value > 0 ? counter.value - 1 : 0);
  Future<void> resetCounter() => setCounter(0);

  Future<void> addTask(String title) async {
    final list = [Task(title), ...tasks.value];
    tasks.value = list;
    await Storage.setTasks(list);
  }

  Future<void> toggleTask(int index, bool done) async {
    final list = [...tasks.value];
    list[index] = list[index].copyWith(done: done);
    tasks.value = list;
    await Storage.setTasks(list);
  }

  Future<void> deleteTask(int index) async {
    final list = [...tasks.value]..removeAt(index);
    tasks.value = list;
    await Storage.setTasks(list);
  }

  Future<void> clearDone() async {
    final list = tasks.value.where((t) => !t.done).toList();
    tasks.value = list;
    await Storage.setTasks(list);
  }
}