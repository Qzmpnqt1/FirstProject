/// Domain entity для задачи (без зависимостей от инфраструктуры)
enum TaskPriority { low, medium, high, urgent }
enum TaskRepeatType { none, daily, weekly, monthly }

class TaskEntity {
  final String id;
  final String title;
  final bool done;
  final TaskPriority priority;
  final List<String> tags;
  final List<String> subtasks; // ID подзадач
  final TaskRepeatType repeatType;
  final DateTime? repeatUntil;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? parentTaskId; // Для подзадач
  final String? sessionId; // Привязка к занятию
  final String? moduleId; // Привязка к модулю

  const TaskEntity({
    required this.id,
    required this.title,
    this.done = false,
    this.priority = TaskPriority.medium,
    this.tags = const [],
    this.subtasks = const [],
    this.repeatType = TaskRepeatType.none,
    this.repeatUntil,
    required this.createdAt,
    this.completedAt,
    this.parentTaskId,
    this.sessionId,
    this.moduleId,
  });

  TaskEntity copyWith({
    String? id,
    String? title,
    bool? done,
    TaskPriority? priority,
    List<String>? tags,
    List<String>? subtasks,
    TaskRepeatType? repeatType,
    DateTime? repeatUntil,
    DateTime? createdAt,
    DateTime? completedAt,
    String? parentTaskId,
    String? sessionId,
    String? moduleId,
  }) =>
      TaskEntity(
        id: id ?? this.id,
        title: title ?? this.title,
        done: done ?? this.done,
        priority: priority ?? this.priority,
        tags: tags ?? this.tags,
        subtasks: subtasks ?? this.subtasks,
        repeatType: repeatType ?? this.repeatType,
        repeatUntil: repeatUntil ?? this.repeatUntil,
        createdAt: createdAt ?? this.createdAt,
        completedAt: completedAt ?? this.completedAt,
        parentTaskId: parentTaskId ?? this.parentTaskId,
        sessionId: sessionId ?? this.sessionId,
        moduleId: moduleId ?? this.moduleId,
      );
}

