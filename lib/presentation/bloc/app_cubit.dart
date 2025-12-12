import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/app_settings_entity.dart';
import '../../domain/entities/module_entity.dart';
import '../../domain/entities/study_session_entity.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/modules_repository.dart';
import '../../domain/repositories/sessions_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/repositories/tasks_repository.dart';
import 'app_state.dart';

/// Cubit для управления состоянием приложения
class AppCubit extends Cubit<AppState> {
  final TasksRepository _tasksRepository;
  final ModulesRepository _modulesRepository;
  final SessionsRepository _sessionsRepository;
  final AuthRepository _authRepository;
  final SettingsRepository _settingsRepository;

  AppCubit({
    required TasksRepository tasksRepository,
    required ModulesRepository modulesRepository,
    required SessionsRepository sessionsRepository,
    required AuthRepository authRepository,
    required SettingsRepository settingsRepository,
  })  : _tasksRepository = tasksRepository,
        _modulesRepository = modulesRepository,
        _sessionsRepository = sessionsRepository,
        _authRepository = authRepository,
        _settingsRepository = settingsRepository,
        super(AppState(
          settings: const AppSettingsEntity(
            themeDark: false,
            notifications: true,
            analytics: false,
            name: '',
            role: '',
            group: '',
            goal: '',
            contacts: '',
            counter: 0,
          ),
          user: null,
          tasks: const [],
          modules: const [],
          modulesEx: const [],
          sessions: const [],
        )) {
    _loadInitialState();
  }

  Future<void> _loadInitialState() async {
    final settings = await _settingsRepository.getSettings();
    final user = await _authRepository.getCurrentUser();
    final tasks = await _tasksRepository.getTasks();
    final modulesEx = await _modulesRepository.getModules();
    final sessions = await _sessionsRepository.getSessions();

    emit(AppState(
      settings: settings,
      user: user,
      tasks: tasks,
      modules: const [], // legacy, не используется
      modulesEx: modulesEx,
      sessions: sessions,
    ));
  }

  // --- Settings ---
  Future<void> setDark(bool value) async {
    final newSettings = state.settings.copyWith(themeDark: value);
    await _settingsRepository.saveSettings(newSettings);
    emit(state.copyWith(settings: newSettings));
  }

  Future<void> setNotifications(bool value) async {
    final newSettings = state.settings.copyWith(notifications: value);
    await _settingsRepository.saveSettings(newSettings);
    emit(state.copyWith(settings: newSettings));
  }

  Future<void> setAnalytics(bool value) async {
    final newSettings = state.settings.copyWith(analytics: value);
    await _settingsRepository.saveSettings(newSettings);
    emit(state.copyWith(settings: newSettings));
  }

  Future<void> setName(String value) async {
    final newSettings = state.settings.copyWith(name: value);
    await _settingsRepository.saveSettings(newSettings);
    emit(state.copyWith(settings: newSettings));
  }

  Future<void> setRole(String value) async {
    final newSettings = state.settings.copyWith(role: value);
    await _settingsRepository.saveSettings(newSettings);
    emit(state.copyWith(settings: newSettings));
  }

  Future<void> setProfileGroup(String value) async {
    final newSettings = state.settings.copyWith(group: value);
    await _settingsRepository.saveSettings(newSettings);
    emit(state.copyWith(settings: newSettings));
  }

  Future<void> setProfileGoal(String value) async {
    final newSettings = state.settings.copyWith(goal: value);
    await _settingsRepository.saveSettings(newSettings);
    emit(state.copyWith(settings: newSettings));
  }

  Future<void> setProfileContacts(String value) async {
    final newSettings = state.settings.copyWith(contacts: value);
    await _settingsRepository.saveSettings(newSettings);
    emit(state.copyWith(settings: newSettings));
  }

  Future<void> setCounter(int value) async {
    final newSettings = state.settings.copyWith(counter: value);
    await _settingsRepository.saveSettings(newSettings);
    emit(state.copyWith(settings: newSettings));
  }

  Future<void> incCounter() => setCounter(state.settings.counter + 1);
  Future<void> decCounter() => setCounter(state.settings.counter > 0 ? state.settings.counter - 1 : 0);
  Future<void> resetCounter() => setCounter(0);

  // --- Tasks ---
  Future<void> addTask(String title) async {
    final task = TaskEntity(title: title);
    final list = [task, ...state.tasks];
    await _tasksRepository.saveTasks(list);
    emit(state.copyWith(tasks: list));
  }

  Future<void> toggleTask(int index, bool done) async {
    final list = [...state.tasks];
    list[index] = list[index].copyWith(done: done);
    await _tasksRepository.saveTasks(list);
    emit(state.copyWith(tasks: list));
  }

  Future<void> deleteTask(int index) async {
    final list = [...state.tasks]..removeAt(index);
    await _tasksRepository.saveTasks(list);
    emit(state.copyWith(tasks: list));
  }

  Future<void> clearDone() async {
    final list = state.tasks.where((t) => !t.done).toList();
    await _tasksRepository.saveTasks(list);
    emit(state.copyWith(tasks: list));
  }

  // --- Modules ---
  Future<void> addModuleEx(String title, ModuleType type, int hours) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString() + Random().nextInt(9999).toString();
    final module = ModuleEntity(
      id: id,
      title: title,
      type: type,
      hours: hours,
      status: ModuleStatus.notStarted,
      topics: const [],
      practices: const [],
    );
    final list = [module, ...state.modulesEx];
    await _modulesRepository.saveModules(list);
    emit(state.copyWith(modulesEx: list));
  }

  Future<void> deleteModuleEx(String id) async {
    final list = [...state.modulesEx]..removeWhere((e) => e.id == id);
    await _modulesRepository.saveModules(list);
    emit(state.copyWith(modulesEx: list));
  }

  Future<void> renameModule(String id, String newTitle) async {
    final list = state.modulesEx.map((m) => m.id == id ? m.copyWith(title: newTitle) : m).toList();
    await _modulesRepository.saveModules(list);
    emit(state.copyWith(modulesEx: list));
  }

  Future<void> addTopic(String id, bool isTheory, String title) async {
    final list = state.modulesEx.map((m) {
      if (m.id != id) return m;
      if (isTheory) {
        return m.copyWith(
          topics: [...m.topics, TopicItemEntity(title: title)],
          status: ModuleStatus.inProgress,
        );
      }
      return m.copyWith(
        practices: [...m.practices, TopicItemEntity(title: title)],
        status: ModuleStatus.inProgress,
      );
    }).toList();
    await _modulesRepository.saveModules(list);
    emit(state.copyWith(modulesEx: list));
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
    await _modulesRepository.saveModules(list);
    emit(state.copyWith(modulesEx: list));
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
    await _modulesRepository.saveModules(list);
    emit(state.copyWith(modulesEx: list));
  }

  // --- Sessions ---
  Future<void> addSession(String title, String moduleTitle, DateTime dateTime, int durationMinutes) async {
    final session = StudySessionEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString() + Random().nextInt(9999).toString(),
      title: title,
      moduleTitle: moduleTitle,
      scheduledAt: dateTime,
      durationMinutes: durationMinutes,
      completed: false,
    );
    final list = [session, ...state.sessions]..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    await _sessionsRepository.saveSessions(list);
    emit(state.copyWith(sessions: list));
  }

  Future<void> toggleSession(String id, bool value) async {
    final list = state.sessions
        .map((s) => s.id == id ? s.copyWith(completed: value) : s)
        .toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    await _sessionsRepository.saveSessions(list);
    emit(state.copyWith(sessions: list));
  }

  Future<void> deleteSession(String id) async {
    final list = [...state.sessions]..removeWhere((s) => s.id == id);
    await _sessionsRepository.saveSessions(list);
    emit(state.copyWith(sessions: list));
  }

  // --- Auth ---
  Future<bool> register(
    String fullName,
    String email,
    String password, {
    required String group,
    required String goal,
    required String contacts,
  }) async {
    final ok = await _authRepository.register(fullName, email, password);
    if (ok) {
      await setName(fullName.isEmpty ? email : fullName);
      await setRole('Студент');
      await setProfileGroup(group);
      await setProfileGoal(goal);
      await setProfileContacts(contacts);
      final user = await _authRepository.getCurrentUser();
      emit(state.copyWith(user: user));
    }
    return ok;
  }

  Future<bool> login(String email, String password) async {
    final user = await _authRepository.login(email, password);
    if (user == null) return false;
    final settings = await _settingsRepository.getSettings();
    emit(state.copyWith(user: user, settings: settings));
    return true;
  }

  Future<void> logout() async {
    await _authRepository.logout();
    emit(state.copyWith(user: null));
  }
}

