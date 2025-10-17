import 'package:flutter/foundation.dart' show ValueNotifier;
import '../data/storage.dart';
import '../data/task.dart';
import '../data/auth_user.dart';
import '../data/module.dart';
import 'dart:math';

class AppState {
  // Тема/настройки
  final themeDark = ValueNotifier<bool>(Storage.getDark());
  final notifications = ValueNotifier<bool>(Storage.getNotifications());
  final analytics = ValueNotifier<bool>(Storage.getAnalytics());

  // Профиль (локальный профиль экрана "Профиль")
  final name = ValueNotifier<String>(Storage.getName());
  final role = ValueNotifier<String>(Storage.getRole());

  // Auth
  final user = ValueNotifier<AuthUser?>(Storage.getCurrentUser());

  // Данные
  final counter = ValueNotifier<int>(Storage.getCounter());
  final tasks = ValueNotifier<List<Task>>(Storage.getTasks());

  // СТАРЫЕ строковые модули (совместимость)
  final modules = ValueNotifier<List<String>>(Storage.getModules());

  // НОВЫЕ сущности модулей
  final modulesEx = ValueNotifier<List<Module>>(Storage.getModulesEx());

  // --- переключатели ---
  Future<void> setDark(bool v) async { themeDark.value = v; await Storage.setDark(v); }
  Future<void> setNotifications(bool v) async { notifications.value = v; await Storage.setNotifications(v); }
  Future<void> setAnalytics(bool v) async { analytics.value = v; await Storage.setAnalytics(v); }

  Future<void> setName(String v) async { name.value = v; await Storage.setName(v); }
  Future<void> setRole(String v) async { role.value = v; await Storage.setRole(v); }

  // --- счётчик/задачи ---
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

  // --- старые строковые модули ---
  Future<void> addModule(String title) async {
    final list = [...modules.value, title];
    modules.value = list;
    await Storage.setModules(list);
  }
  Future<void> deleteModuleAt(int index) async {
    final list = [...modules.value]..removeAt(index);
    modules.value = list;
    await Storage.setModules(list);
  }
  Future<void> deleteModuleByTitle(String title) async {
    final list = [...modules.value]..removeWhere((e) => e == title);
    modules.value = list;
    await Storage.setModules(list);
  }

  // --- НОВЫЕ модули (сущности) ---
  Future<void> addModuleEx(String title, ModuleType type, int hours) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString() + Random().nextInt(9999).toString();
    final m = Module(
      id: id,
      title: title,
      type: type,
      hours: hours,
      status: ModuleStatus.notStarted,
      topics: const [],
      practices: const [],
    );
    final list = [m, ...modulesEx.value];
    modulesEx.value = list;
    await Storage.setModulesEx(list);
  }

  Future<void> deleteModuleEx(String id) async {
    final list = [...modulesEx.value]..removeWhere((e) => e.id == id);
    modulesEx.value = list;
    await Storage.setModulesEx(list);
  }

  Future<void> renameModule(String id, String newTitle) async {
    final list = modulesEx.value.map((m) => m.id == id ? m.copyWith(title: newTitle) : m).toList();
    modulesEx.value = list;
    await Storage.setModulesEx(list);
  }

  Future<void> addTopic(String id, bool isTheory, String title) async {
    final list = modulesEx.value.map((m) {
      if (m.id != id) return m;
      if (isTheory) {
        return m.copyWith(
          topics: [...m.topics, TopicItem(title)],
          status: ModuleStatus.inProgress,
        );
      } else {
        return m.copyWith(
          practices: [...m.practices, TopicItem(title)],
          status: ModuleStatus.inProgress,
        );
      }
    }).toList();
    modulesEx.value = list;
    await Storage.setModulesEx(list);
  }

  Future<void> toggleTopic(String id, bool isTheory, int index, bool value) async {
    final list = modulesEx.value.map((m) {
      if (m.id != id) return m;
      final ts = [...(isTheory ? m.topics : m.practices)];
      ts[index] = ts[index].copyWith(done: value);
      final updated = isTheory ? m.copyWith(topics: ts) : m.copyWith(practices: ts);
      final st = updated.progress >= 1 ? ModuleStatus.completed : ModuleStatus.inProgress;
      return updated.copyWith(status: st);
    }).toList();
    modulesEx.value = list;
    await Storage.setModulesEx(list);
  }

  Future<void> deleteTopic(String id, bool isTheory, int index) async {
    final list = modulesEx.value.map((m) {
      if (m.id != id) return m;
      final ts = [...(isTheory ? m.topics : m.practices)]..removeAt(index);
      final updated = isTheory ? m.copyWith(topics: ts) : m.copyWith(practices: ts);
      final st = updated.progress == 0 ? ModuleStatus.notStarted : (updated.progress >= 1 ? ModuleStatus.completed : ModuleStatus.inProgress);
      return updated.copyWith(status: st);
    }).toList();
    modulesEx.value = list;
    await Storage.setModulesEx(list);
  }

  // --- Auth ---
  Future<bool> register(String fullName, String email, String password) async {
    return Storage.register(fullName, email, password);
  }

  Future<bool> login(String email, String password) async {
    final u = await Storage.login(email, password);
    user.value = u;
    if (u != null) {
      await setName(u.fullName);
      await setRole('Студент');
    }
    return u != null;
  }

  Future<void> logout() async {
    await Storage.logout();
    user.value = null;
  }
}
