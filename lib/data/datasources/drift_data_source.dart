import 'dart:convert';
import 'package:drift/drift.dart';
import '../../domain/entities/module_entity.dart';
import '../models/task_model.dart';
import '../models/module_model.dart';
import '../models/auth_user_model.dart';
import '../models/study_session_model.dart';
import '../database/app_database.dart';
import 'data_source_interface.dart';

/// Data source для SQL хранилища (Drift)
class DriftDataSource implements DataSourceInterface {
  final AppDatabase _db;
  
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
  List<ModuleModel>? _modulesExCache;
  List<StudySessionModel>? _sessionsCache;
  AuthUserModel? _currentUserCache;

  DriftDataSource(this._db);

  Future<void> loadCache() async {
    final setting = await _db.getSetting('dark_theme');
    _darkCache = setting?.value == 'true';
    
    final counterSetting = await _db.getSetting('counter');
    _counterCache = counterSetting != null ? int.tryParse(counterSetting.value) ?? 0 : 0;
    
    final nameSetting = await _db.getSetting('profile_name');
    _nameCache = nameSetting?.value ?? 'Амерханов Кирилл';
    
    final roleSetting = await _db.getSetting('profile_role');
    _roleCache = roleSetting?.value ?? 'Разработчик';
    
    final groupSetting = await _db.getSetting('profile_group');
    _groupCache = groupSetting?.value ?? 'ИКБО-00-00';
    
    final goalSetting = await _db.getSetting('profile_goal');
    _goalCache = goalSetting?.value ?? 'Освоить курс';
    
    final contactsSetting = await _db.getSetting('profile_contacts');
    _contactsCache = contactsSetting?.value ?? 'telegram:@student';
    
    final notifSetting = await _db.getSetting('settings_notifications');
    _notificationsCache = notifSetting?.value != 'false';
    
    final analytSetting = await _db.getSetting('settings_analytics');
    _analyticsCache = analytSetting?.value == 'true';
    
    final tasks = await _db.getAllTasks();
    _tasksCache = tasks.isEmpty ? [
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
    ] : tasks.map((t) => TaskModel(
      id: t.id.toString(),
      title: t.title,
      done: t.done,
      createdAt: DateTime.now(),
      completedAt: t.done ? DateTime.now() : null,
    )).toList();
    
    final modules = await _db.getAllModules();
    if (modules.isEmpty) {
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
      _modulesExCache = modules.map((m) {
        final topics = (jsonDecode(m.topicsJson) as List).map((e) => TopicItemModel.fromJson(e)).toList();
        final practices = (jsonDecode(m.practicesJson) as List).map((e) => TopicItemModel.fromJson(e)).toList();
        return ModuleModel(
          id: m.id,
          title: m.title,
          type: ModuleType.values.firstWhere((e) => e.name == m.type),
          hours: m.hours,
          status: ModuleStatus.values.firstWhere((e) => e.name == m.status),
          topics: topics,
          practices: practices,
          createdAt: DateTime.now(), // Используем текущую дату, если нет в БД
        );
      }).toList();
    }
    
    final sessions = await _db.getAllSessions();
    _sessionsCache = sessions.map((s) => StudySessionModel(
      id: s.id,
      title: s.title,
      moduleTitle: s.moduleTitle,
      scheduledAt: s.scheduledAt,
      durationMinutes: s.durationMinutes,
      completed: s.completed,
    )).toList();
    
    final user = await _db.getCurrentUser();
    _currentUserCache = user != null ? AuthUserModel(email: user.email, fullName: user.fullName) : null;
  }

  static Future<AppDatabase> init() async {
    final db = AppDatabase();
    return db;
  }

  @override
  bool getDark() {
    return _darkCache ?? false;
  }

  @override
  Future<void> setDark(bool v) async {
    await _db.setSetting('dark_theme', v.toString());
    _darkCache = v;
  }

  @override
  int getCounter() {
    return _counterCache ?? 0;
  }

  @override
  Future<void> setCounter(int v) async {
    await _db.setSetting('counter', v.toString());
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
    await _db.setSetting('profile_name', v);
    _nameCache = v;
  }

  @override
  Future<void> setRole(String v) async {
    await _db.setSetting('profile_role', v);
    _roleCache = v;
  }

  @override
  Future<void> setProfileGroup(String v) async {
    await _db.setSetting('profile_group', v);
    _groupCache = v;
  }

  @override
  Future<void> setProfileGoal(String v) async {
    await _db.setSetting('profile_goal', v);
    _goalCache = v;
  }

  @override
  Future<void> setProfileContacts(String v) async {
    await _db.setSetting('profile_contacts', v);
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
    await _db.setSetting('settings_notifications', v.toString());
    _notificationsCache = v;
  }

  @override
  Future<void> setAnalytics(bool v) async {
    await _db.setSetting('settings_analytics', v.toString());
    _analyticsCache = v;
  }

  @override
  List<TaskModel> getTasks() {
    return _tasksCache ?? [
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

  @override
  Future<void> setTasks(List<TaskModel> tasks) async {
    await _db.deleteAllTasks();
    for (final task in tasks) {
      await _db.insertTask(TasksCompanion.insert(
        title: task.title,
        done: Value(task.done),
      ));
    }
    _tasksCache = tasks;
  }

  @override
  List<String> getModules() {
    // Legacy модули не используются в Drift
    return [];
  }

  @override
  Future<void> setModules(List<String> modules) async {
    // Legacy модули не используются в Drift
  }

  @override
  List<ModuleModel> getModulesEx() {
    return _modulesExCache ?? [];
  }

  @override
  Future<void> setModulesEx(List<ModuleModel> modules) async {
    await _db.deleteAllModules();
    for (final module in modules) {
      await _db.insertModule(ModulesCompanion.insert(
        id: module.id,
        title: module.title,
        type: module.type.name,
        hours: module.hours,
        status: module.status.name,
        topicsJson: jsonEncode(module.topics.map((t) => (t as TopicItemModel).toJson()).toList()),
        practicesJson: jsonEncode(module.practices.map((p) => (p as TopicItemModel).toJson()).toList()),
      ));
    }
    _modulesExCache = modules;
  }

  @override
  List<StudySessionModel> getSessions() {
    return _sessionsCache ?? [];
  }

  @override
  Future<void> setSessions(List<StudySessionModel> sessions) async {
    await _db.deleteAllSessions();
    for (final session in sessions) {
      await _db.insertSession(StudySessionsCompanion.insert(
        id: session.id,
        title: session.title,
        moduleTitle: session.moduleTitle,
        scheduledAt: session.scheduledAt,
        durationMinutes: session.durationMinutes,
        completed: Value(session.completed),
      ));
    }
    _sessionsCache = sessions;
  }

  @override
  AuthUserModel? getCurrentUser() {
    return _currentUserCache;
  }

  @override
  Future<void> setCurrentUser(AuthUserModel? user) async {
    if (user == null) {
      await _db.clearCurrentUser();
    } else {
      await _db.setCurrentUser(user.email, user.fullName);
    }
    _currentUserCache = user;
  }

  @override
  Future<bool> register(String fullName, String email, String password) async {
    final existing = await _db.getUserByEmail(email);
    if (existing != null) return false;
    await _db.insertUser(AuthUsersCompanion.insert(
      email: email,
      fullName: fullName.isEmpty ? email : fullName,
    ));
    await _db.insertPassword(PasswordsCompanion.insert(email: email, password: password));
    return true;
  }

  @override
  Future<AuthUserModel?> login(String email, String password) async {
    final storedPassword = await _db.getPasswordByEmail(email);
    if (storedPassword != password) return null;
    final user = await _db.getUserByEmail(email);
    if (user == null) return null;
    final authUser = AuthUserModel(email: user.email, fullName: user.fullName);
    await setCurrentUser(authUser);
    return authUser;
  }

  @override
  Future<void> logout() async {
    await setCurrentUser(null);
  }
}

