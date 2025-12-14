import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/module_entity.dart';
import '../models/task_model.dart';
import '../models/module_model.dart';
import '../models/auth_user_model.dart';
import '../models/study_session_model.dart';
import 'data_source_interface.dart';

/// Data source для NoSQL хранилища (Hive)
class HiveDataSource implements DataSourceInterface {
  static const String _tasksBox = 'tasks_box';
  static const String _modulesBox = 'modules_box';
  static const String _modulesExBox = 'modules_ex_box';
  static const String _sessionsBox = 'sessions_box';
  static const String _authBox = 'auth_box';
  static const String _settingsBox = 'settings_box';

  static Future<void> init() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(0)) {
    }
    
    // Открытие боксов
    await Hive.openBox(_tasksBox);
    await Hive.openBox(_modulesBox);
    await Hive.openBox(_modulesExBox);
    await Hive.openBox(_sessionsBox);
    await Hive.openBox(_authBox);
    await Hive.openBox(_settingsBox);
  }

  Box get _tasksBoxInstance => Hive.box(_tasksBox);
  Box get _modulesBoxInstance => Hive.box(_modulesBox);
  Box get _modulesExBoxInstance => Hive.box(_modulesExBox);
  Box get _sessionsBoxInstance => Hive.box(_sessionsBox);
  Box get _authBoxInstance => Hive.box(_authBox);
  Box get _settingsBoxInstance => Hive.box(_settingsBox);

  @override
  bool getDark() {
    return _settingsBoxInstance.get('dark_theme', defaultValue: false) as bool;
  }

  @override
  Future<void> setDark(bool v) async {
    await _settingsBoxInstance.put('dark_theme', v);
  }

  @override
  int getCounter() {
    return _settingsBoxInstance.get('counter', defaultValue: 0) as int;
  }

  @override
  Future<void> setCounter(int v) async {
    await _settingsBoxInstance.put('counter', v);
  }

  @override
  String getName() {
    return _settingsBoxInstance.get('profile_name', defaultValue: 'Амерханов Кирилл') as String;
  }

  @override
  String getRole() {
    return _settingsBoxInstance.get('profile_role', defaultValue: 'Разработчик') as String;
  }

  @override
  String getProfileGroup() {
    return _settingsBoxInstance.get('profile_group', defaultValue: 'ИКБО-00-00') as String;
  }

  @override
  String getProfileGoal() {
    return _settingsBoxInstance.get('profile_goal', defaultValue: 'Освоить курс') as String;
  }

  @override
  String getProfileContacts() {
    return _settingsBoxInstance.get('profile_contacts', defaultValue: 'telegram:@student') as String;
  }

  @override
  Future<void> setName(String v) async {
    await _settingsBoxInstance.put('profile_name', v);
  }

  @override
  Future<void> setRole(String v) async {
    await _settingsBoxInstance.put('profile_role', v);
  }

  @override
  Future<void> setProfileGroup(String v) async {
    await _settingsBoxInstance.put('profile_group', v);
  }

  @override
  Future<void> setProfileGoal(String v) async {
    await _settingsBoxInstance.put('profile_goal', v);
  }

  @override
  Future<void> setProfileContacts(String v) async {
    await _settingsBoxInstance.put('profile_contacts', v);
  }

  @override
  bool getNotifications() {
    return _settingsBoxInstance.get('settings_notifications', defaultValue: true) as bool;
  }

  @override
  bool getAnalytics() {
    return _settingsBoxInstance.get('settings_analytics', defaultValue: false) as bool;
  }

  @override
  Future<void> setNotifications(bool v) async {
    await _settingsBoxInstance.put('settings_notifications', v);
  }

  @override
  Future<void> setAnalytics(bool v) async {
    await _settingsBoxInstance.put('settings_analytics', v);
  }

  @override
  List<TaskModel> getTasks() {
    final raw = _tasksBoxInstance.get('tasks_list');
    if (raw == null) {
      return [
        TaskModel(
          id: 't1',
          title: 'Изучить виджеты Text/Button/Row/Column',
          createdAt: DateTime.now(),
        ),
        TaskModel(
          id: 't2',
          title: 'Сделать собственные Stateless/Stateful',
          createdAt: DateTime.now(),
        ),
        TaskModel(
          id: 't3',
          title: 'Смену контента по BottomBar',
          done: true,
          createdAt: DateTime.now(),
          completedAt: DateTime.now(),
        ),
      ];
    }
    final list = (jsonDecode(raw as String) as List).cast<Map<String, dynamic>>();
    return list.map((e) => TaskModel.fromJson(e)).toList();
  }

  @override
  Future<void> setTasks(List<TaskModel> tasks) async {
    await _tasksBoxInstance.put('tasks_list', jsonEncode(tasks.map((e) => e.toJson()).toList()));
  }

  @override
  List<String> getModules() {
    final raw = _modulesBoxInstance.get('modules_list');
    if (raw == null) {
      return [
        'Введение в Flutter',
        'Стейт-менеджмент (ValueNotifier)',
        'Списки: Column / ListView',
        'Работа с SharedPreferences',
        'Практическая №3 – виджеты',
      ];
    }
    return (jsonDecode(raw as String) as List).cast<String>();
  }

  @override
  Future<void> setModules(List<String> modules) async {
    await _modulesBoxInstance.put('modules_list', jsonEncode(modules));
  }

  @override
  List<ModuleModel> getModulesEx() {
    final raw = _modulesExBoxInstance.get('modules_ex_list');
    if (raw == null) {
      final defaults = [
        ModuleModel(
          id: 'm1',
          title: 'Основы Flutter и структура проекта',
          type: ModuleType.lecture,
          hours: 4,
          status: ModuleStatus.notStarted,
          topics: [
            TopicItemModel(title: 'Widget tree'),
            TopicItemModel(title: 'MaterialApp/Theme'),
            TopicItemModel(title: 'Навигация'),
          ],
          practices: [TopicItemModel(title: 'Собрать экран профиля')],
          createdAt: DateTime.now(),
        ),
      ];
      setModulesEx(defaults);
      return List<ModuleModel>.from(defaults);
    }
    final list = (jsonDecode(raw as String) as List).cast<Map<String, dynamic>>();
    return list.map((e) => ModuleModel.fromJson(e)).toList();
  }

  @override
  Future<void> setModulesEx(List<ModuleModel> modules) async {
    await _modulesExBoxInstance.put('modules_ex_list', jsonEncode(modules.map((e) => e.toJson()).toList()));
  }

  @override
  List<StudySessionModel> getSessions() {
    final raw = _sessionsBoxInstance.get('sessions_list');
    if (raw == null) return [];
    final list = (jsonDecode(raw as String) as List).cast<Map<String, dynamic>>();
    return list.map((e) => StudySessionModel.fromJson(e)).toList();
  }

  @override
  Future<void> setSessions(List<StudySessionModel> sessions) async {
    await _sessionsBoxInstance.put('sessions_list', jsonEncode(sessions.map((e) => e.toJson()).toList()));
  }

  @override
  AuthUserModel? getCurrentUser() {
    final raw = _authBoxInstance.get('current_user');
    if (raw == null) return null;
    return AuthUserModel.fromJson(jsonDecode(raw as String));
  }

  @override
  Future<void> setCurrentUser(AuthUserModel? user) async {
    if (user == null) {
      await _authBoxInstance.delete('current_user');
    } else {
      await _authBoxInstance.put('current_user', jsonEncode(user.toJson()));
    }
  }

  @override
  Future<bool> register(String fullName, String email, String password) async {
    final usersRaw = _authBoxInstance.get('users_index');
    List<AuthUserModel> users = [];
    if (usersRaw != null) {
      final list = (jsonDecode(usersRaw as String) as List).cast<Map<String, dynamic>>();
      users = list.map((e) => AuthUserModel.fromJson(e)).toList();
    }
    if (users.any((u) => u.email.toLowerCase() == email.toLowerCase())) return false;
    final u = AuthUserModel(email: email, fullName: fullName.isEmpty ? email : fullName);
    users.add(u);
    await _authBoxInstance.put('users_index', jsonEncode(users.map((e) => e.toJson()).toList()));
    
    final passwordsRaw = _authBoxInstance.get('passwords');
    Map<String, String> passwords = {};
    if (passwordsRaw != null) {
      passwords = (jsonDecode(passwordsRaw as String) as Map).map((k, v) => MapEntry(k as String, v as String));
    }
    passwords[email.toLowerCase()] = password;
    await _authBoxInstance.put('passwords', jsonEncode(passwords));
    return true;
  }

  @override
  Future<AuthUserModel?> login(String email, String password) async {
    final passwordsRaw = _authBoxInstance.get('passwords');
    if (passwordsRaw == null) return null;
    final passwords = (jsonDecode(passwordsRaw as String) as Map).map((k, v) => MapEntry(k as String, v as String));
    final ok = passwords[email.toLowerCase()] == password;
    if (!ok) return null;
    
    final usersRaw = _authBoxInstance.get('users_index');
    if (usersRaw == null) return null;
    final list = (jsonDecode(usersRaw as String) as List).cast<Map<String, dynamic>>();
    final users = list.map((e) => AuthUserModel.fromJson(e)).toList();
    final u = users.firstWhere(
      (x) => x.email.toLowerCase() == email.toLowerCase(),
      orElse: () => AuthUserModel(email: email, fullName: email),
    );
    await setCurrentUser(u);
    return u;
  }

  @override
  Future<void> logout() async {
    await setCurrentUser(null);
  }
}

