import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/module_entity.dart';
import '../models/task_model.dart';
import '../models/module_model.dart';
import '../models/auth_user_model.dart';
import '../models/study_session_model.dart';
import 'data_source_interface.dart';

/// Data source для локального хранилища (SharedPreferences)
class LocalStorageDataSource implements DataSourceInterface {
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
  static const _kModules = 'modules_json';
  static const _kModulesEx = 'modules_ex_json';
  static const _kUsersIndex = 'auth_users_index_json';
  static const _kCurrentUser = 'auth_current_user_json';
  static const _kPasswords = 'auth_passwords_json';

  static Future<void> init() async => _prefs = await SharedPreferences.getInstance();

  // Settings
  bool getDark() => _prefs.getBool(_kDark) ?? false;
  Future<void> setDark(bool v) => _prefs.setBool(_kDark, v);

  int getCounter() => _prefs.getInt(_kCounter) ?? 0;
  Future<void> setCounter(int v) => _prefs.setInt(_kCounter, v);

  String getName() => _prefs.getString(_kName) ?? 'Амерханов Кирилл';
  String getRole() => _prefs.getString(_kRole) ?? 'Разработчик';
  String getProfileGroup() => _prefs.getString(_kGroup) ?? 'ИКБО-00-00';
  String getProfileGoal() => _prefs.getString(_kGoal) ?? 'Освоить курс';
  String getProfileContacts() => _prefs.getString(_kContacts) ?? 'telegram:@student';
  Future<void> setName(String v) => _prefs.setString(_kName, v);
  Future<void> setRole(String v) => _prefs.setString(_kRole, v);
  Future<void> setProfileGroup(String v) => _prefs.setString(_kGroup, v);
  Future<void> setProfileGoal(String v) => _prefs.setString(_kGoal, v);
  Future<void> setProfileContacts(String v) => _prefs.setString(_kContacts, v);

  bool getNotifications() => _prefs.getBool(_kNotif) ?? true;
  bool getAnalytics() => _prefs.getBool(_kAnalyt) ?? false;
  Future<void> setNotifications(bool v) => _prefs.setBool(_kNotif, v);
  Future<void> setAnalytics(bool v) => _prefs.setBool(_kAnalyt, v);

  // Tasks
  List<TaskModel> getTasks() {
    final raw = _prefs.getString(_kTasks);
    if (raw == null || raw.isEmpty) {
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
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map((e) => TaskModel.fromJson(e)).toList();
  }

  @override
  Future<void> setTasks(List<TaskModel> tasks) =>
      _prefs.setString(_kTasks, jsonEncode(tasks.map((e) => e.toJson()).toList()));

  // Modules
  @override
  List<String> getModules() {
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

  @override
  Future<void> setModules(List<String> modules) =>
      _prefs.setString(_kModules, jsonEncode(modules));

  @override
  List<ModuleModel> getModulesEx() {
    final raw = _prefs.getString(_kModulesEx);
    if (raw != null && raw.isNotEmpty) {
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      return list.map((e) => ModuleModel.fromJson(e)).toList();
    }
    final legacy = getModules();
    if (legacy.isNotEmpty) {
      final seeded = legacy.asMap().entries.map((e) {
        return ModuleModel(
          id: 'legacy_${e.key}',
          title: e.value,
          type: ModuleType.lecture,
          hours: 2,
          status: ModuleStatus.notStarted,
          topics: const [TopicItemModel(title: 'Обзор материала')],
          practices: const [TopicItemModel(title: 'Мини-практика')],
          createdAt: DateTime.now(),
        );
      }).toList();
      setModulesEx(seeded);
      return List<ModuleModel>.from(seeded);
    }
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
      ModuleModel(
        id: 'm2',
        title: 'Списки и работа с состоянием',
        type: ModuleType.practice,
        hours: 4,
        status: ModuleStatus.notStarted,
        topics: [TopicItemModel(title: 'ValueNotifier/ValueListenableBuilder')],
        practices: [
          TopicItemModel(title: 'CRUD для модулей'),
          TopicItemModel(title: 'Dismissible карточки'),
        ],
        createdAt: DateTime.now(),
      ),
      ModuleModel(
        id: 'm3',
        title: 'Персистентность: SharedPreferences',
        type: ModuleType.lab,
        hours: 3,
        status: ModuleStatus.notStarted,
        topics: [TopicItemModel(title: 'Ключи и схемы хранения')],
        practices: [TopicItemModel(title: 'Сохранение прогресса и профиля')],
        createdAt: DateTime.now(),
      ),
    ];
    setModulesEx(defaults);
    return List<ModuleModel>.from(defaults);
  }

  @override
  Future<void> setModulesEx(List<ModuleModel> modules) =>
      _prefs.setString(_kModulesEx, jsonEncode(modules.map((e) => e.toJson()).toList()));

  // Sessions
  @override
  List<StudySessionModel> getSessions() {
    final raw = _prefs.getString(_kSessions);
    if (raw == null || raw.isEmpty) return [];
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map((e) => StudySessionModel.fromJson(e)).toList();
  }

  @override
  Future<void> setSessions(List<StudySessionModel> sessions) =>
      _prefs.setString(_kSessions, jsonEncode(sessions.map((e) => e.toJson()).toList()));

  // Auth
  @override
  AuthUserModel? getCurrentUser() {
    final raw = _prefs.getString(_kCurrentUser);
    if (raw == null || raw.isEmpty) return null;
    return AuthUserModel.fromJson(jsonDecode(raw));
  }

  @override
  Future<void> setCurrentUser(AuthUserModel? u) async {
    if (u == null) {
      await _prefs.remove(_kCurrentUser);
    } else {
      await _prefs.setString(_kCurrentUser, jsonEncode(u.toJson()));
    }
  }
  
  Future<void> _setCurrentUser(AuthUserModel? u) async => setCurrentUser(u);

  Map<String, String> _getPasswords() {
    final raw = _prefs.getString(_kPasswords);
    if (raw == null || raw.isEmpty) return {};
    return (jsonDecode(raw) as Map).map((k, v) => MapEntry(k as String, v as String));
  }

  Future<void> _setPasswords(Map<String, String> map) =>
      _prefs.setString(_kPasswords, jsonEncode(map));

  List<AuthUserModel> _getUsersIndex() {
    final raw = _prefs.getString(_kUsersIndex);
    if (raw == null || raw.isEmpty) return [];
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map((e) => AuthUserModel.fromJson(e)).toList();
  }

  Future<void> _setUsersIndex(List<AuthUserModel> users) =>
      _prefs.setString(_kUsersIndex, jsonEncode(users.map((e) => e.toJson()).toList()));

  @override
  Future<bool> register(String fullName, String email, String password) async {
    final users = _getUsersIndex();
    if (users.any((u) => u.email.toLowerCase() == email.toLowerCase())) return false;
    final u = AuthUserModel(email: email, fullName: fullName.isEmpty ? email : fullName);
    users.add(u);
    await _setUsersIndex(users);
    final pw = _getPasswords();
    pw[email.toLowerCase()] = password;
    await _setPasswords(pw);
    return true;
  }

  @override
  Future<AuthUserModel?> login(String email, String password) async {
    final pw = _getPasswords();
    final ok = pw[email.toLowerCase()] == password;
    if (!ok) return null;
    final u = _getUsersIndex().firstWhere(
          (x) => x.email.toLowerCase() == email.toLowerCase(),
      orElse: () => AuthUserModel(email: email, fullName: email),
    );
    await _setCurrentUser(u);
    return u;
  }

  @override
  Future<void> logout() => setCurrentUser(null);
}

