import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'task.dart';
import 'auth_user.dart';
import 'module.dart';
import 'study_session.dart';

class Storage {
  static late SharedPreferences _prefs;

  static const _kDark = 'dark_theme';
  static const _kCounter = 'counter';
  static const _kTasks = 'tasks_json';
  static const _kName = 'profile_name';
  static const _kRole = 'profile_role';
  static const _kGroup = 'profile_group';
  static const _kGoal = 'profile_goal';
  static const _kContacts = 'profile_contacts';
  static const _kNotif = 'settings_notifications';
  static const _kAnalyt = 'settings_analytics';
  static const _kSessions = 'study_sessions_json';

  // Старые модули (строки)
  static const _kModules = 'modules_json';
  // Новые модули (сущности)
  static const _kModulesEx = 'modules_ex_json';

  // Auth
  static const _kUsersIndex = 'auth_users_index_json'; // список зарегистрированных пользователей
  static const _kCurrentUser = 'auth_current_user_json'; // текущий пользователь
  static const _kPasswords = 'auth_passwords_json'; // email -> пароль (учебно)

  static Future<void> init() async => _prefs = await SharedPreferences.getInstance();

  static bool getDark() => _prefs.getBool(_kDark) ?? false;
  static Future<void> setDark(bool v) => _prefs.setBool(_kDark, v);

  static int getCounter() => _prefs.getInt(_kCounter) ?? 0;
  static Future<void> setCounter(int v) => _prefs.setInt(_kCounter, v);

  static String getName() => _prefs.getString(_kName) ?? 'Амерханов Кирилл';
  static String getRole() => _prefs.getString(_kRole) ?? 'Разработчик';
  static String getProfileGroup() => _prefs.getString(_kGroup) ?? 'ИКБО-00-00';
  static String getProfileGoal() => _prefs.getString(_kGoal) ?? 'Освоить курс';
  static String getProfileContacts() => _prefs.getString(_kContacts) ?? 'telegram:@student';
  static Future<void> setName(String v) => _prefs.setString(_kName, v);
  static Future<void> setRole(String v) => _prefs.setString(_kRole, v);
  static Future<void> setProfileGroup(String v) => _prefs.setString(_kGroup, v);
  static Future<void> setProfileGoal(String v) => _prefs.setString(_kGoal, v);
  static Future<void> setProfileContacts(String v) => _prefs.setString(_kContacts, v);

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

  // --------- СТАРОЕ: список строк ----------
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

  // --------- НОВОЕ: сущности модулей ----------
  static List<Module> getModulesEx() {
    final raw = _prefs.getString(_kModulesEx);
    if (raw != null && raw.isNotEmpty) {
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      return list.map(Module.fromJson).toList();
    }
    // Миграция из старого формата (строки)
    final legacy = getModules();
    if (legacy.isNotEmpty) {
      final seeded = legacy.asMap().entries.map((e) {
        return Module(
          id: 'legacy_${e.key}',
          title: e.value,
          type: ModuleType.lecture,
          hours: 2,
          status: ModuleStatus.notStarted,
          topics: [TopicItem('Обзор материала "${e.value}"')],
          practices: [TopicItem('Мини-практика по "${e.value}"')],
        );
      }).toList();
      setModulesEx(seeded);
      return seeded;
    }
    // Значения по умолчанию
    final defaults = [
      Module(
        id: 'm1',
        title: 'Основы Flutter и структура проекта',
        type: ModuleType.lecture,
        hours: 4,
        status: ModuleStatus.notStarted,
        topics: const [TopicItem('Widget tree'), TopicItem('MaterialApp/Theme'), TopicItem('Навигация')],
        practices: const [TopicItem('Собрать экран профиля')],
      ),
      Module(
        id: 'm2',
        title: 'Списки и работа с состоянием',
        type: ModuleType.practice,
        hours: 4,
        status: ModuleStatus.notStarted,
        topics: const [TopicItem('ValueNotifier/ValueListenableBuilder')],
        practices: const [TopicItem('CRUD для модулей'), TopicItem('Dismissible карточки')],
      ),
      Module(
        id: 'm3',
        title: 'Персистентность: SharedPreferences',
        type: ModuleType.lab,
        hours: 3,
        status: ModuleStatus.notStarted,
        topics: const [TopicItem('Ключи и схемы хранения')],
        practices: const [TopicItem('Сохранение прогресса и профиля')],
      ),
    ];
    setModulesEx(defaults);
    return defaults;
  }

  static Future<void> setModulesEx(List<Module> modules) =>
      _prefs.setString(_kModulesEx, jsonEncode(modules.map((e) => e.toJson()).toList()));

  // --------- Study schedule ----------
  static List<StudySession> getSessions() {
    final raw = _prefs.getString(_kSessions);
    if (raw != null && raw.isNotEmpty) {
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      return list.map(StudySession.fromJson).toList();
    }
    final now = DateTime.now();
    final defaults = [
      StudySession(
        id: 'session_1',
        title: 'Повторение лекции по Flutter',
        moduleTitle: 'Основы Flutter и структура проекта',
        scheduledAt: now.add(const Duration(days: 1, hours: 2)),
        durationMinutes: 90,
        completed: false,
      ),
      StudySession(
        id: 'session_2',
        title: 'Практика по спискам',
        moduleTitle: 'Списки и работа с состоянием',
        scheduledAt: now.add(const Duration(days: 2, hours: 3)),
        durationMinutes: 120,
        completed: false,
      ),
      StudySession(
        id: 'session_3',
        title: 'Закрепление SharedPreferences',
        moduleTitle: 'Персистентность: SharedPreferences',
        scheduledAt: now.add(const Duration(days: 3, hours: 1)),
        durationMinutes: 60,
        completed: false,
      ),
    ];
    setSessions(defaults);
    return defaults;
  }

  static Future<void> setSessions(List<StudySession> sessions) => _prefs.setString(
        _kSessions,
        jsonEncode(sessions.map((e) => e.toJson()).toList()),
      );

  // --------- Auth ----------
  static AuthUser? getCurrentUser() {
    final raw = _prefs.getString(_kCurrentUser);
    if (raw == null || raw.isEmpty) return null;
    return AuthUser.fromJson(jsonDecode(raw));
  }

  static Future<void> _setCurrentUser(AuthUser? u) async {
    if (u == null) {
      await _prefs.remove(_kCurrentUser);
    } else {
      await _prefs.setString(_kCurrentUser, jsonEncode(u.toJson()));
    }
  }

  static Map<String, String> _getPasswords() {
    final raw = _prefs.getString(_kPasswords);
    if (raw == null || raw.isEmpty) return {};
    return (jsonDecode(raw) as Map).map((k, v) => MapEntry(k as String, v as String));
  }

  static Future<void> _setPasswords(Map<String, String> map) =>
      _prefs.setString(_kPasswords, jsonEncode(map));

  static List<AuthUser> _getUsersIndex() {
    final raw = _prefs.getString(_kUsersIndex);
    if (raw == null || raw.isEmpty) return [];
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map((e) => AuthUser.fromJson(e)).toList();
  }

  static Future<void> _setUsersIndex(List<AuthUser> users) =>
      _prefs.setString(_kUsersIndex, jsonEncode(users.map((e) => e.toJson()).toList()));

  static Future<bool> register(String fullName, String email, String password) async {
    final users = _getUsersIndex();
    if (users.any((u) => u.email.toLowerCase() == email.toLowerCase())) return false;
    final u = AuthUser(email: email, fullName: fullName.isEmpty ? email : fullName);
    users.add(u);
    await _setUsersIndex(users);
    final pw = _getPasswords();
    pw[email.toLowerCase()] = password; // учебно: без хэширования
    await _setPasswords(pw);
    return true;
  }

  static Future<AuthUser?> login(String email, String password) async {
    final pw = _getPasswords();
    final ok = pw[email.toLowerCase()] == password;
    if (!ok) return null;
    final u = _getUsersIndex().firstWhere(
          (x) => x.email.toLowerCase() == email.toLowerCase(),
      orElse: () => AuthUser(email: email, fullName: email),
    );
    await _setCurrentUser(u);
    return u;
  }

  static Future<void> logout() => _setCurrentUser(null);
}
