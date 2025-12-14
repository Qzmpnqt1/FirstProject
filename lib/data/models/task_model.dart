import '../../domain/entities/task_entity.dart';

/// Data model для задачи с JSON сериализацией
class TaskModel extends TaskEntity {
  const TaskModel({
    required super.id,
    required super.title,
    super.done = false,
    super.priority = TaskPriority.medium,
    super.tags = const [],
    super.subtasks = const [],
    super.repeatType = TaskRepeatType.none,
    super.repeatUntil,
    required super.createdAt,
    super.completedAt,
    super.parentTaskId,
    super.sessionId,
    super.moduleId,
  });

  factory TaskModel.fromEntity(TaskEntity entity) => TaskModel(
        id: entity.id,
        title: entity.title,
        done: entity.done,
        priority: entity.priority,
        tags: entity.tags,
        subtasks: entity.subtasks,
        repeatType: entity.repeatType,
        repeatUntil: entity.repeatUntil,
        createdAt: entity.createdAt,
        completedAt: entity.completedAt,
        parentTaskId: entity.parentTaskId,
        sessionId: entity.sessionId,
        moduleId: entity.moduleId,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'done': done,
        'priority': priority.name,
        'tags': tags,
        'subtasks': subtasks,
        'repeatType': repeatType.name,
        if (repeatUntil != null) 'repeatUntil': repeatUntil!.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        if (completedAt != null) 'completedAt': completedAt!.toIso8601String(),
        if (parentTaskId != null) 'parentTaskId': parentTaskId,
        if (sessionId != null) 'sessionId': sessionId,
        if (moduleId != null) 'moduleId': moduleId,
      };

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    // Обработка старых данных без createdAt
    final createdAt = json['createdAt'] != null
        ? DateTime.parse(json['createdAt'] as String)
        : DateTime.now();
    
    return TaskModel(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: json['title'] as String,
        done: json['done'] as bool? ?? false,
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == (json['priority'] as String?),
        orElse: () => TaskPriority.medium,
      ),
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? const [],
      subtasks: (json['subtasks'] as List<dynamic>?)?.cast<String>() ?? const [],
      repeatType: TaskRepeatType.values.firstWhere(
        (e) => e.name == (json['repeatType'] as String?),
        orElse: () => TaskRepeatType.none,
      ),
      repeatUntil: json['repeatUntil'] != null
          ? DateTime.parse(json['repeatUntil'] as String)
          : null,
      createdAt: createdAt,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      parentTaskId: json['parentTaskId'] as String?,
      sessionId: json['sessionId'] as String?,
      moduleId: json['moduleId'] as String?,
      );
  }
}

