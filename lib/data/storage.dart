// lib/data/storage.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'task.dart';

class Storage {
  static late SharedPreferences _prefs;

  static const _kDark = 'dark_theme';
  static const _kCounter = 'counter';
  static const _kTasks = 'tasks_json';
  static const _kName = 'profile_name';
  static const _kRole = 'profile_role';
  static const _kNotif = 'settings_notifications';
  static const _kAnalyt = 'settings_analytics';

  // NEW:
  static const _kModules = 'modules_json';

  static Future<void> init() async => _prefs = await SharedPreferences.getInstance();

  static bool getDark() => _prefs.getBool(_kDark) ?? false;
  static Future<void> setDark(bool v) => _prefs.setBool(_kDark, v);

  static int getCounter() => _prefs.getInt(_kCounter) ?? 0;
  static Future<void> setCounter(int v) => _prefs.setInt(_kCounter, v);

  static String getName() => _prefs.getString(_kName) ?? 'Амерханов Кирилл';
  static String getRole() => _prefs.getString(_kRole) ?? 'Разработчик';
  static Future<void> setName(String v) => _prefs.setString(_kName, v);
  static Future<void> setRole(String v) => _prefs.setString(_kRole, v);

  static bool getNotifications() => _prefs.getBool(_kNotif) ?? true;
  static bool getAnalytics() => _prefs.getBool(_kAnalyt) ?? false;
  static Future<void> setNotifications(bool v) => _prefs.setBool(_kNotif, v);
  static Future<void> setAnalytics(bool v) => _prefs.setBool(_kAnalyt, v);

  static List<Task> getTasks() {
    final raw = _prefs.getString(_kTasks);
    if (raw == null || raw.isEmpty) {
      return [
        Task('Изучить виджеты Text/Button/Row/Column'),
        Task('Сделать собственные Stateless/Stateful'),
        Task('Смену контента по BottomBar', done: true),
      ];
    }
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map(Task.fromJson).toList();
  }

  static Future<void> setTasks(List<Task> tasks) =>
      _prefs.setString(_kTasks, jsonEncode(tasks.map((e) => e.toJson()).toList()));

  // --------- NEW: сохранение учебных модулей (список строк) ----------
  static List<String> getModules() {
    final raw = _prefs.getString(_kModules);
    if (raw == null || raw.isEmpty) {
      return [
        'Введение в Flutter',
        'Стейт-менеджмент (ValueNotifier)',
        'Списки: Column / ListView',
        'Работа с SharedPreferences',
        'Практическая №3 – виджеты',
      ];
    }
    return (jsonDecode(raw) as List).cast<String>();
  }

  static Future<void> setModules(List<String> modules) =>
      _prefs.setString(_kModules, jsonEncode(modules));
}
