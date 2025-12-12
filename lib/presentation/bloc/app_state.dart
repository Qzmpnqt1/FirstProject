import '../../domain/entities/auth_user_entity.dart';
import '../../domain/entities/module_entity.dart';
import '../../domain/entities/study_session_entity.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/app_settings_entity.dart';

/// Presentation state для приложения
class AppState {
  final AppSettingsEntity settings;
  final AuthUserEntity? user;
  final List<TaskEntity> tasks;
  final List<String> modules; // legacy
  final List<ModuleEntity> modulesEx;
  final List<StudySessionEntity> sessions;

  const AppState({
    required this.settings,
    required this.user,
    required this.tasks,
    required this.modules,
    required this.modulesEx,
    required this.sessions,
  });

  AppState copyWith({
    AppSettingsEntity? settings,
    AuthUserEntity? user,
    List<TaskEntity>? tasks,
    List<String>? modules,
    List<ModuleEntity>? modulesEx,
    List<StudySessionEntity>? sessions,
  }) {
    return AppState(
      settings: settings ?? this.settings,
      user: user ?? this.user,
      tasks: tasks != null ? List.unmodifiable(tasks) : this.tasks,
      modules: modules != null ? List.unmodifiable(modules) : this.modules,
      modulesEx: modulesEx != null ? List.unmodifiable(modulesEx) : this.modulesEx,
      sessions: sessions != null ? List.unmodifiable(sessions) : this.sessions,
    );
  }
}

