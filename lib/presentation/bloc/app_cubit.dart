import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/app_settings_entity.dart';
import '../../domain/entities/module_entity.dart';
import '../../domain/entities/study_session_entity.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/goal_entity.dart';
import '../../domain/entities/focus_session_entity.dart';
import '../../domain/entities/activity_streak_entity.dart';
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
  Future<void> addTask(
    String title, {
    TaskPriority priority = TaskPriority.medium,
    List<String> tags = const [],
    TaskRepeatType repeatType = TaskRepeatType.none,
    DateTime? repeatUntil,
    String? parentTaskId,
    String? sessionId,
    String? moduleId,
  }) async {
    final task = TaskEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString() + Random().nextInt(9999).toString(),
      title: title,
      priority: priority,
      tags: tags,
      repeatType: repeatType,
      repeatUntil: repeatUntil,
      createdAt: DateTime.now(),
      parentTaskId: parentTaskId,
      sessionId: sessionId,
      moduleId: moduleId,
    );
    final list = [task, ...state.tasks];
    await _tasksRepository.saveTasks(list);
    emit(state.copyWith(tasks: list));
    _updateStreak();
  }

  Future<void> toggleTask(String id, bool done) async {
    final list = state.tasks.map((t) {
      if (t.id != id) return t;
      return t.copyWith(
        done: done,
        completedAt: done ? DateTime.now() : null,
      );
    }).toList();
    await _tasksRepository.saveTasks(list);
    emit(state.copyWith(tasks: list));
    if (done) _updateStreak();
  }

  Future<void> deleteTask(String id) async {
    final task = state.tasks.firstWhere((t) => t.id == id);
    final list = state.tasks.where((t) => t.id != id).toList();
    await _tasksRepository.saveTasks(list);
    emit(state.copyWith(tasks: list, lastDeletedTask: task));
  }

  Future<void> undoDeleteTask() async {
    if (state.lastDeletedTask == null) return;
    final task = state.lastDeletedTask!;
    final list = [task, ...state.tasks];
    await _tasksRepository.saveTasks(list);
    emit(state.copyWith(tasks: list, lastDeletedTask: null));
  }

  Future<void> clearDone() async {
    final list = state.tasks.where((t) => !t.done).toList();
    await _tasksRepository.saveTasks(list);
    emit(state.copyWith(tasks: list));
  }

  // --- Modules ---
  Future<void> addModuleEx(
    String title,
    ModuleType type,
    int hours, {
    DateTime? deadline,
    ModulePriority priority = ModulePriority.medium,
    String? description,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString() + Random().nextInt(9999).toString();
    final module = ModuleEntity(
      id: id,
      title: title,
      type: type,
      hours: hours,
      status: ModuleStatus.notStarted,
      topics: const [],
      practices: const [],
      deadline: deadline,
      priority: priority,
      description: description,
      createdAt: DateTime.now(),
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
      return updated.copyWith(
        status: status,
        completedAt: updated.progress >= 1 ? DateTime.now() : null,
      );
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
      return updated.copyWith(
        status: status,
        completedAt: progress >= 1 ? DateTime.now() : null,
      );
    }).toList();
    await _modulesRepository.saveModules(list);
    emit(state.copyWith(modulesEx: list));
  }

  Future<void> updateModuleDeadline(String id, DateTime? deadline) async {
    final list = state.modulesEx.map((m) => m.id == id ? m.copyWith(deadline: deadline) : m).toList();
    await _modulesRepository.saveModules(list);
    emit(state.copyWith(modulesEx: list));
  }

  Future<void> updateModuleGrade(String id, int? grade) async {
    final list = state.modulesEx.map((m) => m.id == id ? m.copyWith(grade: grade) : m).toList();
    await _modulesRepository.saveModules(list);
    emit(state.copyWith(modulesEx: list));
  }

  Future<void> updateModulePriority(String id, ModulePriority priority) async {
    final list = state.modulesEx.map((m) => m.id == id ? m.copyWith(priority: priority) : m).toList();
    await _modulesRepository.saveModules(list);
    emit(state.copyWith(modulesEx: list));
  }

  Future<void> updateModuleDescription(String id, String? description) async {
    final list = state.modulesEx.map((m) => m.id == id ? m.copyWith(description: description) : m).toList();
    await _modulesRepository.saveModules(list);
    emit(state.copyWith(modulesEx: list));
  }

  Future<void> updateModuleNotes(String id, String? notes) async {
    final list = state.modulesEx.map((m) => m.id == id ? m.copyWith(notes: notes) : m).toList();
    await _modulesRepository.saveModules(list);
    emit(state.copyWith(modulesEx: list));
  }

  Future<void> updateTopicNotes(String moduleId, bool isTheory, int index, String? notes) async {
    final list = state.modulesEx.map((m) {
      if (m.id != moduleId) return m;
      final items = [...(isTheory ? m.topics : m.practices)];
      items[index] = items[index].copyWith(notes: notes);
      return isTheory ? m.copyWith(topics: items) : m.copyWith(practices: items);
    }).toList();
    await _modulesRepository.saveModules(list);
    emit(state.copyWith(modulesEx: list));
  }

  // --- Sessions ---
  Future<void> addSession(String title, String moduleTitle, DateTime dateTime, int durationMinutes) async {
    await addSessionEx(title, moduleTitle, dateTime, durationMinutes);
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

  // --- Streak ---
  void _updateStreak() {
    final today = DateTime.now();
    final todayKey = DateTime(today.year, today.month, today.day);
    final completedTasks = state.tasks.where((t) => t.done && t.completedAt != null).length;
    final completedModules = state.modulesEx.where((m) => m.status == ModuleStatus.completed).length;
    final activityCount = completedTasks + completedModules;
    
    if (activityCount > 0) {
      final currentStreak = state.streak ?? ActivityStreakEntity(
        currentStreak: 0,
        longestStreak: 0,
        lastActivityDate: DateTime(1970),
        dailyActivity: const {},
      );
      final updated = currentStreak.updateWithActivity(today, activityCount);
      emit(state.copyWith(streak: updated));
    }
  }

  // --- Goals ---
  Future<void> addGoal(String title, GoalType type, DateTime targetDate, {String? description}) async {
    final goal = GoalEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString() + Random().nextInt(9999).toString(),
      title: title,
      type: type,
      status: GoalStatus.notStarted,
      targetDate: targetDate,
      createdAt: DateTime.now(),
      description: description,
    );
    final list = [goal, ...state.goals];
    emit(state.copyWith(goals: list));
  }

  Future<void> updateGoalStatus(String id, GoalStatus status) async {
    final list = state.goals.map((g) {
      if (g.id != id) return g;
      return g.copyWith(
        status: status,
        completedAt: status == GoalStatus.completed ? DateTime.now() : null,
      );
    }).toList();
    emit(state.copyWith(goals: list));
  }

  Future<void> deleteGoal(String id) async {
    final list = state.goals.where((g) => g.id != id).toList();
    emit(state.copyWith(goals: list));
  }

  // --- Focus Sessions ---
  Future<void> startFocusSession({
    FocusSessionType type = FocusSessionType.pomodoro,
    int durationMinutes = 25,
    String? taskId,
    String? moduleId,
  }) async {
    final session = FocusSessionEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString() + Random().nextInt(9999).toString(),
      type: type,
      durationMinutes: durationMinutes,
      startTime: DateTime.now(),
      taskId: taskId,
      moduleId: moduleId,
    );
    final list = [session, ...state.focusSessions];
    emit(state.copyWith(focusSessions: list));
  }

  Future<void> endFocusSession(String id, {String? notes}) async {
    final list = state.focusSessions.map((s) {
      if (s.id != id) return s;
      return s.copyWith(
        endTime: DateTime.now(),
        completed: true,
        notes: notes,
      );
    }).toList();
    emit(state.copyWith(focusSessions: list));
  }

  // --- Extended Module Functions ---
  Future<void> addModuleStage(String moduleId, String title) async {
    final list = state.modulesEx.map((m) {
      if (m.id != moduleId) return m;
      final stage = ModuleStage(
        id: DateTime.now().millisecondsSinceEpoch.toString() + Random().nextInt(9999).toString(),
        title: title,
      );
      return m.copyWith(stages: [...m.stages, stage]);
    }).toList();
    await _modulesRepository.saveModules(list);
    emit(state.copyWith(modulesEx: list));
  }

  Future<void> toggleModuleStage(String moduleId, String stageId, bool completed) async {
    final list = state.modulesEx.map((m) {
      if (m.id != moduleId) return m;
      final stages = m.stages.map((s) {
        if (s.id != stageId) return s;
        return s.copyWith(
          completed: completed,
          completedAt: completed ? DateTime.now() : null,
        );
      }).toList();
      return m.copyWith(stages: stages);
    }).toList();
    await _modulesRepository.saveModules(list);
    emit(state.copyWith(modulesEx: list));
  }

  Future<void> addModuleMaterial(String moduleId, String title, String type, String content) async {
    final list = state.modulesEx.map((m) {
      if (m.id != moduleId) return m;
      final material = ModuleMaterial(
        id: DateTime.now().millisecondsSinceEpoch.toString() + Random().nextInt(9999).toString(),
        title: title,
        type: type,
        content: content,
      );
      return m.copyWith(materials: [...m.materials, material]);
    }).toList();
    await _modulesRepository.saveModules(list);
    emit(state.copyWith(modulesEx: list));
  }

  Future<void> addModuleTime(String moduleId, int minutes) async {
    final list = state.modulesEx.map((m) {
      if (m.id != moduleId) return m;
      final newTime = m.timeSpentMinutes + minutes;
      final progress = m.progress;
      final entry = ModuleProgressEntry(
        date: DateTime.now(),
        progress: progress,
        timeSpentMinutes: minutes,
      );
      return m.copyWith(
        timeSpentMinutes: newTime,
        progressHistory: [...m.progressHistory, entry],
      );
    }).toList();
    await _modulesRepository.saveModules(list);
    emit(state.copyWith(modulesEx: list));
  }

  Future<void> pauseModule(String id) async {
    final list = state.modulesEx.map((m) {
      if (m.id != id) return m;
      return m.copyWith(status: ModuleStatus.paused);
    }).toList();
    await _modulesRepository.saveModules(list);
    emit(state.copyWith(modulesEx: list));
  }

  Future<void> resumeModule(String id) async {
    final list = state.modulesEx.map((m) {
      if (m.id != id) return m;
      return m.copyWith(status: ModuleStatus.inProgress);
    }).toList();
    await _modulesRepository.saveModules(list);
    emit(state.copyWith(modulesEx: list));
  }

  // --- Extended Session Functions ---
  Future<void> addSessionEx(
    String title,
    String moduleTitle,
    DateTime dateTime,
    int durationMinutes, {
    SessionRepeatType repeatType = SessionRepeatType.none,
    DateTime? repeatUntil,
    bool reminderEnabled = false,
    int reminderMinutesBefore = 15,
  }) async {
    final session = StudySessionEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString() + Random().nextInt(9999).toString(),
      title: title,
      moduleTitle: moduleTitle,
      scheduledAt: dateTime,
      durationMinutes: durationMinutes,
      completed: false,
      repeatType: repeatType,
      repeatUntil: repeatUntil,
      reminderEnabled: reminderEnabled,
      reminderMinutesBefore: reminderMinutesBefore,
    );
    
    // Проверка конфликтов
    final conflicts = state.sessions.where((s) => session.hasConflict(s)).toList();
    if (conflicts.isNotEmpty) {
      // Можно добавить обработку конфликтов
    }
    
    final list = [session, ...state.sessions]..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    await _sessionsRepository.saveSessions(list);
    emit(state.copyWith(sessions: list));
  }

  Future<void> updateSessionAttendance(String id, AttendanceStatus attendance) async {
    final list = state.sessions.map((s) {
      if (s.id != id) return s;
      return s.copyWith(attendance: attendance);
    }).toList();
    await _sessionsRepository.saveSessions(list);
    emit(state.copyWith(sessions: list));
  }

  Future<void> attachTaskToSession(String sessionId, String taskId) async {
    final list = state.sessions.map((s) {
      if (s.id != sessionId) return s;
      if (s.taskIds.contains(taskId)) return s;
      return s.copyWith(taskIds: [...s.taskIds, taskId]);
    }).toList();
    await _sessionsRepository.saveSessions(list);
    emit(state.copyWith(sessions: list));
  }

  // --- Recommendations ---
  String? getRecommendedNextAction() {
    // Просроченные модули
    final overdue = state.modulesEx.where((m) => m.isOverdue && m.status != ModuleStatus.completed).toList();
    if (overdue.isNotEmpty) {
      return 'Начните работу над просроченным модулем: ${overdue.first.title}';
    }
    
    // Срочные модули
    final urgent = state.modulesEx.where((m) => 
      m.priority == ModulePriority.urgent && 
      m.status != ModuleStatus.completed
    ).toList();
    if (urgent.isNotEmpty) {
      return 'Приоритетный модуль: ${urgent.first.title}';
    }
    
    // Ближайшее занятие
    final upcoming = state.sessions.where((s) => 
      !s.completed && 
      s.scheduledAt.isAfter(DateTime.now())
    ).toList();
    if (upcoming.isNotEmpty) {
      final next = upcoming.reduce((a, b) => a.scheduledAt.isBefore(b.scheduledAt) ? a : b);
      return 'Подготовьтесь к занятию: ${next.title}';
    }
    
    // Незавершенные задачи
    final pendingTasks = state.tasks.where((t) => !t.done).toList();
    if (pendingTasks.isNotEmpty) {
      return 'Завершите задачу: ${pendingTasks.first.title}';
    }
    
    return null;
  }

  List<StudySessionEntity> getConflictingSessions(StudySessionEntity session) {
    return state.sessions.where((s) => session.hasConflict(s)).toList();
  }
}

