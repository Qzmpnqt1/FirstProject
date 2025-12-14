import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/entities/module_entity.dart';
import '../models/task_model.dart';
import '../models/module_model.dart';
import '../models/auth_user_model.dart';
import '../models/study_session_model.dart';
import 'data_source_interface.dart';

/// Data source для безопасного хранилища (Flutter Secure Store)
class SecureStoreDataSource implements DataSourceInterface {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

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

  // Кэш для синхронного доступа
  bool? _darkCache;
  int? _counterCache;
  String? _nameCache;
  String? _roleCache;
  String? _groupCache;
  String? _goalCache;
  String? _contactsCache;
  bool? _notificationsCache;
  bool? _analyticsCache;
  List<TaskModel>? _tasksCache;
  List<String>? _modulesCache;
  List<ModuleModel>? _modulesExCache;
  List<StudySessionModel>? _sessionsCache;
  AuthUserModel? _currentUserCache;

  SecureStoreDataSource();

  Future<void> loadCache() async {
    final darkValue = await _storage.read(key: _kDark);
    _darkCache = darkValue == 'true';
    
    final counterValue = await _storage.read(key: _kCounter);
    _counterCache = counterValue != null ? int.tryParse(counterValue) ?? 0 : 0;
    
    _nameCache = await _storage.read(key: _kName) ?? 'Амерханов Кирилл';
    _roleCache = await _storage.read(key: _kRole) ?? 'Разработчик';
    _groupCache = await _storage.read(key: _kGroup) ?? 'ИКБО-00-00';
    _goalCache = await _storage.read(key: _kGoal) ?? 'Освоить курс';
    _contactsCache = await _storage.read(key: _kContacts) ?? 'telegram:@student';
    
    final notifValue = await _storage.read(key: _kNotif);
    _notificationsCache = notifValue == 'true';
    
    final analytValue = await _storage.read(key: _kAnalyt);
    _analyticsCache = analytValue == 'true';
    
    final tasksRaw = await _storage.read(key: _kTasks);
    if (tasksRaw == null || tasksRaw.isEmpty) {
      _tasksCache = [
        const TaskModel(title: 'Изучить виджеты Text/Button/Row/Column'),
        const TaskModel(title: 'Сделать собственные Stateless/Stateful'),
        const TaskModel(title: 'Смену контента по BottomBar', done: true),
      ];
    } else {
      final list = (jsonDecode(tasksRaw) as List).cast<Map<String, dynamic>>();
      _tasksCache = list.map((e) => TaskModel.fromJson(e)).toList();
    }
    
    final modulesExRaw = await _storage.read(key: _kModulesEx);
    if (modulesExRaw == null || modulesExRaw.isEmpty) {
      _modulesExCache = [
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
      setModulesEx(_modulesExCache!);
    } else {
      final list = (jsonDecode(modulesExRaw) as List).cast<Map<String, dynamic>>();
      _modulesExCache = list.map((e) => ModuleModel.fromJson(e)).toList();
    }
    
    final sessionsRaw = await _storage.read(key: _kSessions);
    if (sessionsRaw == null || sessionsRaw.isEmpty) {
      _sessionsCache = [];
    } else {
      final list = (jsonDecode(sessionsRaw) as List).cast<Map<String, dynamic>>();
      _sessionsCache = list.map((e) => StudySessionModel.fromJson(e)).toList();
    }
    
    final userRaw = await _storage.read(key: _kCurrentUser);
    if (userRaw == null || userRaw.isEmpty) {
      _currentUserCache = null;
    } else {
      _currentUserCache = AuthUserModel.fromJson(jsonDecode(userRaw));
    }
    
    final modulesRaw = await _storage.read(key: _kModules);
    if (modulesRaw == null || modulesRaw.isEmpty) {
      _modulesCache = [
        'Введение в Flutter',
        'Стейт-менеджмент (ValueNotifier)',
        'Списки: Column / ListView',
        'Работа с SharedPreferences',
        'Практическая №3 – виджеты',
      ];
    } else {
      _modulesCache = (jsonDecode(modulesRaw) as List).cast<String>();
    }
  }

  static Future<void> init() async {
    // Secure Store не требует явной инициализации
  }

  @override
  bool getDark() {
    return _darkCache ?? false;
  }

  @override
  Future<void> setDark(bool v) async {
    await _storage.write(key: _kDark, value: v.toString());
    _darkCache = v;
  }

  @override
  int getCounter() {
    return _counterCache ?? 0;
  }

  @override
  Future<void> setCounter(int v) async {
    await _storage.write(key: _kCounter, value: v.toString());
    _counterCache = v;
  }

  @override
  String getName() {
    return _nameCache ?? 'Амерханов Кирилл';
  }

  @override
  String getRole() {
    return _roleCache ?? 'Разработчик';
  }

  @override
  String getProfileGroup() {
    return _groupCache ?? 'ИКБО-00-00';
  }

  @override
  String getProfileGoal() {
    return _goalCache ?? 'Освоить курс';
  }

  @override
  String getProfileContacts() {
    return _contactsCache ?? 'telegram:@student';
  }

  @override
  Future<void> setName(String v) async {
    await _storage.write(key: _kName, value: v);
    _nameCache = v;
  }

  @override
  Future<void> setRole(String v) async {
    await _storage.write(key: _kRole, value: v);
    _roleCache = v;
  }

  @override
  Future<void> setProfileGroup(String v) async {
    await _storage.write(key: _kGroup, value: v);
    _groupCache = v;
  }

  @override
  Future<void> setProfileGoal(String v) async {
    await _storage.write(key: _kGoal, value: v);
    _goalCache = v;
  }

  @override
  Future<void> setProfileContacts(String v) async {
    await _storage.write(key: _kContacts, value: v);
    _contactsCache = v;
  }

  @override
  bool getNotifications() {
    return _notificationsCache ?? true;
  }

  @override
  bool getAnalytics() {
    return _analyticsCache ?? false;
  }

  @override
  Future<void> setNotifications(bool v) async {
    await _storage.write(key: _kNotif, value: v.toString());
    _notificationsCache = v;
  }

  @override
  Future<void> setAnalytics(bool v) async {
    await _storage.write(key: _kAnalyt, value: v.toString());
    _analyticsCache = v;
  }

  @override
  List<TaskModel> getTasks() {
    return _tasksCache ?? [
      const TaskModel(title: 'Изучить виджеты Text/Button/Row/Column'),
      const TaskModel(title: 'Сделать собственные Stateless/Stateful'),
      const TaskModel(title: 'Смену контента по BottomBar', done: true),
    ];
  }

  @override
  Future<void> setTasks(List<TaskModel> tasks) async {
    await _storage.write(key: _kTasks, value: jsonEncode(tasks.map((e) => e.toJson()).toList()));
    _tasksCache = tasks;
  }

  @override
  List<String> getModules() {
    return _modulesCache ?? [
      'Введение в Flutter',
      'Стейт-менеджмент (ValueNotifier)',
      'Списки: Column / ListView',
      'Работа с SharedPreferences',
      'Практическая №3 – виджеты',
    ];
  }

  @override
  Future<void> setModules(List<String> modules) async {
    await _storage.write(key: _kModules, value: jsonEncode(modules));
    _modulesCache = modules;
  }

  @override
  List<ModuleModel> getModulesEx() {
    return _modulesExCache ?? [];
  }

  @override
  Future<void> setModulesEx(List<ModuleModel> modules) async {
    await _storage.write(key: _kModulesEx, value: jsonEncode(modules.map((e) => e.toJson()).toList()));
    _modulesExCache = modules;
  }

  @override
  List<StudySessionModel> getSessions() {
    return _sessionsCache ?? [];
  }

  @override
  Future<void> setSessions(List<StudySessionModel> sessions) async {
    await _storage.write(key: _kSessions, value: jsonEncode(sessions.map((e) => e.toJson()).toList()));
    _sessionsCache = sessions;
  }

  @override
  AuthUserModel? getCurrentUser() {
    return _currentUserCache;
  }

  @override
  Future<void> setCurrentUser(AuthUserModel? user) async {
    if (user == null) {
      await _storage.delete(key: _kCurrentUser);
    } else {
      await _storage.write(key: _kCurrentUser, value: jsonEncode(user.toJson()));
    }
    _currentUserCache = user;
  }

  @override
  Future<bool> register(String fullName, String email, String password) async {
    final usersRaw = await _storage.read(key: _kUsersIndex);
    List<AuthUserModel> users = [];
    if (usersRaw != null && usersRaw.isNotEmpty) {
      final list = (jsonDecode(usersRaw) as List).cast<Map<String, dynamic>>();
      users = list.map((e) => AuthUserModel.fromJson(e)).toList();
    }
    if (users.any((u) => u.email.toLowerCase() == email.toLowerCase())) return false;
    final u = AuthUserModel(email: email, fullName: fullName.isEmpty ? email : fullName);
    users.add(u);
    await _storage.write(key: _kUsersIndex, value: jsonEncode(users.map((e) => e.toJson()).toList()));
    
    final passwordsRaw = await _storage.read(key: _kPasswords);
    Map<String, String> passwords = {};
    if (passwordsRaw != null && passwordsRaw.isNotEmpty) {
      passwords = (jsonDecode(passwordsRaw) as Map).map((k, v) => MapEntry(k as String, v as String));
    }
    passwords[email.toLowerCase()] = password;
    await _storage.write(key: _kPasswords, value: jsonEncode(passwords));
    return true;
  }

  @override
  Future<AuthUserModel?> login(String email, String password) async {
    final passwordsRaw = await _storage.read(key: _kPasswords);
    if (passwordsRaw == null || passwordsRaw.isEmpty) return null;
    final passwords = (jsonDecode(passwordsRaw) as Map).map((k, v) => MapEntry(k as String, v as String));
    final ok = passwords[email.toLowerCase()] == password;
    if (!ok) return null;
    
    final usersRaw = await _storage.read(key: _kUsersIndex);
    if (usersRaw == null || usersRaw.isEmpty) return null;
    final list = (jsonDecode(usersRaw) as List).cast<Map<String, dynamic>>();
    final users = list.map((e) => AuthUserModel.fromJson(e)).toList();
    final u = users.firstWhere(
      (x) => x.email.toLowerCase() == email.toLowerCase(),
      orElse: () => AuthUserModel(email: email, fullName: email),
    );
    await setCurrentUser(u);
    _currentUserCache = u;
    return u;
  }

  @override
  Future<void> logout() async {
    await setCurrentUser(null);
  }
}

