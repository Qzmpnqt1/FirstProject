import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/auth_user.dart';
import '../data/module.dart';
import '../data/storage.dart';
import '../data/task.dart';

class AppState {
  final bool themeDark;
  final bool notifications;
  final bool analytics;
  final String name;
  final String role;
  final AuthUser? user;
  final int counter;
  final List<Task> tasks;
  final List<String> modules;
  final List<Module> modulesEx;

  const AppState({
    required this.themeDark,
    required this.notifications,
    required this.analytics,
    required this.name,
    required this.role,
    required this.user,
    required this.counter,
    required this.tasks,
    required this.modules,
    required this.modulesEx,
  });

  factory AppState.initial() => AppState(
        themeDark: Storage.getDark(),
        notifications: Storage.getNotifications(),
        analytics: Storage.getAnalytics(),
        name: Storage.getName(),
        role: Storage.getRole(),
        user: Storage.getCurrentUser(),
        counter: Storage.getCounter(),
        tasks: List.unmodifiable(Storage.getTasks()),
        modules: List.unmodifiable(Storage.getModules()),
        modulesEx: List.unmodifiable(Storage.getModulesEx()),
      );

  AppState copyWith({
    bool? themeDark,
    bool? notifications,
    bool? analytics,
    String? name,
    String? role,
    AuthUser? user,
    int? counter,
    List<Task>? tasks,
    List<String>? modules,
    List<Module>? modulesEx,
  }) {
    return AppState(
      themeDark: themeDark ?? this.themeDark,
      notifications: notifications ?? this.notifications,
      analytics: analytics ?? this.analytics,
      name: name ?? this.name,
      role: role ?? this.role,
      user: user ?? this.user,
      counter: counter ?? this.counter,
      tasks: tasks != null ? List.unmodifiable(tasks) : this.tasks,
      modules: modules != null ? List.unmodifiable(modules) : this.modules,
      modulesEx: modulesEx != null ? List.unmodifiable(modulesEx) : this.modulesEx,
    );
  }
}

class AppCubit extends Cubit<AppState> {
  AppCubit() : super(AppState.initial());

  // --- настройки ---
  Future<void> setDark(bool value) async {
    emit(state.copyWith(themeDark: value));
    await Storage.setDark(value);
  }

  Future<void> setNotifications(bool value) async {
    emit(state.copyWith(notifications: value));
    await Storage.setNotifications(value);
  }

  Future<void> setAnalytics(bool value) async {
    emit(state.copyWith(analytics: value));
    await Storage.setAnalytics(value);
  }

  Future<void> setName(String value) async {
    emit(state.copyWith(name: value));
    await Storage.setName(value);
  }

  Future<void> setRole(String value) async {
    emit(state.copyWith(role: value));
    await Storage.setRole(value);
  }

  // --- счётчик и задачи ---
  Future<void> setCounter(int value) async {
    emit(state.copyWith(counter: value));
    await Storage.setCounter(value);
  }

  Future<void> incCounter() => setCounter(state.counter + 1);
  Future<void> decCounter() => setCounter(state.counter > 0 ? state.counter - 1 : 0);
  Future<void> resetCounter() => setCounter(0);

  Future<void> addTask(String title) async {
    final list = [Task(title), ...state.tasks];
    emit(state.copyWith(tasks: list));
    await Storage.setTasks(list);
  }

  Future<void> toggleTask(int index, bool done) async {
    final list = [...state.tasks];
    list[index] = list[index].copyWith(done: done);
    emit(state.copyWith(tasks: list));
    await Storage.setTasks(list);
  }

  Future<void> deleteTask(int index) async {
    final list = [...state.tasks]..removeAt(index);
    emit(state.copyWith(tasks: list));
    await Storage.setTasks(list);
  }

  Future<void> clearDone() async {
    final list = state.tasks.where((t) => !t.done).toList();
    emit(state.copyWith(tasks: list));
    await Storage.setTasks(list);
  }

  // --- списки модулей (строки) ---
  Future<void> addModule(String title) async {
    final list = [...state.modules, title];
    emit(state.copyWith(modules: list));
    await Storage.setModules(list);
  }

  Future<void> deleteModuleAt(int index) async {
    final list = [...state.modules]..removeAt(index);
    emit(state.copyWith(modules: list));
    await Storage.setModules(list);
  }

  Future<void> deleteModuleByTitle(String title) async {
    final list = [...state.modules]..removeWhere((e) => e == title);
    emit(state.copyWith(modules: list));
    await Storage.setModules(list);
  }

  // --- сущности модулей ---
  Future<void> addModuleEx(String title, ModuleType type, int hours) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString() + Random().nextInt(9999).toString();
    final module = Module(
      id: id,
      title: title,
      type: type,
      hours: hours,
      status: ModuleStatus.notStarted,
      topics: const [],
      practices: const [],
    );
    final list = [module, ...state.modulesEx];
    emit(state.copyWith(modulesEx: list));
    await Storage.setModulesEx(list);
  }

  Future<void> deleteModuleEx(String id) async {
    final list = [...state.modulesEx]..removeWhere((e) => e.id == id);
    emit(state.copyWith(modulesEx: list));
    await Storage.setModulesEx(list);
  }

  Future<void> renameModule(String id, String newTitle) async {
    final list = state.modulesEx.map((m) => m.id == id ? m.copyWith(title: newTitle) : m).toList();
    emit(state.copyWith(modulesEx: list));
    await Storage.setModulesEx(list);
  }

  Future<void> addTopic(String id, bool isTheory, String title) async {
    final list = state.modulesEx.map((m) {
      if (m.id != id) return m;
      if (isTheory) {
        return m.copyWith(
          topics: [...m.topics, TopicItem(title)],
          status: ModuleStatus.inProgress,
        );
      }
      return m.copyWith(
        practices: [...m.practices, TopicItem(title)],
        status: ModuleStatus.inProgress,
      );
    }).toList();
    emit(state.copyWith(modulesEx: list));
    await Storage.setModulesEx(list);
  }

  Future<void> toggleTopic(String id, bool isTheory, int index, bool value) async {
    final list = state.modulesEx.map((m) {
      if (m.id != id) return m;
      final items = [...(isTheory ? m.topics : m.practices)];
      items[index] = items[index].copyWith(done: value);
      final updated = isTheory ? m.copyWith(topics: items) : m.copyWith(practices: items);
      final status = updated.progress >= 1 ? ModuleStatus.completed : ModuleStatus.inProgress;
      return updated.copyWith(status: status);
    }).toList();
    emit(state.copyWith(modulesEx: list));
    await Storage.setModulesEx(list);
  }

  Future<void> deleteTopic(String id, bool isTheory, int index) async {
    final list = state.modulesEx.map((m) {
      if (m.id != id) return m;
      final items = [...(isTheory ? m.topics : m.practices)]..removeAt(index);
      final updated = isTheory ? m.copyWith(topics: items) : m.copyWith(practices: items);
      final progress = updated.progress;
      final status = progress == 0
          ? ModuleStatus.notStarted
          : (progress >= 1 ? ModuleStatus.completed : ModuleStatus.inProgress);
      return updated.copyWith(status: status);
    }).toList();
    emit(state.copyWith(modulesEx: list));
    await Storage.setModulesEx(list);
  }

  // --- Auth ---
  Future<bool> register(String fullName, String email, String password) async {
    return Storage.register(fullName, email, password);
  }

  Future<bool> login(String email, String password) async {
    final u = await Storage.login(email, password);
    if (u == null) return false;
    await Storage.setName(u.fullName);
    await Storage.setRole('Студент');
    emit(state.copyWith(
      user: u,
      name: u.fullName,
      role: 'Студент',
    ));
    return true;
  }

  Future<void> logout() async {
    await Storage.logout();
    emit(state.copyWith(user: null));
  }
}
