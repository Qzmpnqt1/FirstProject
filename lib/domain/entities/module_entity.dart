/// Domain entity для модуля обучения
enum ModuleType { lecture, practice, lab }
enum ModuleStatus { notStarted, inProgress, paused, completed }
enum ModulePriority { low, medium, high, urgent }

class TopicItemEntity {
  final String title;
  final bool done;
  final String? notes;

  const TopicItemEntity({
    required this.title,
    this.done = false,
    this.notes,
  });

  TopicItemEntity copyWith({
    String? title,
    bool? done,
    String? notes,
  }) =>
      TopicItemEntity(
        title: title ?? this.title,
        done: done ?? this.done,
        notes: notes ?? this.notes,
      );
}

class ModuleStage {
  final String id;
  final String title;
  final bool completed;
  final DateTime? completedAt;

  const ModuleStage({
    required this.id,
    required this.title,
    this.completed = false,
    this.completedAt,
  });

  ModuleStage copyWith({
    String? id,
    String? title,
    bool? completed,
    DateTime? completedAt,
  }) =>
      ModuleStage(
        id: id ?? this.id,
        title: title ?? this.title,
        completed: completed ?? this.completed,
        completedAt: completedAt ?? this.completedAt,
      );
}

class ModuleMaterial {
  final String id;
  final String title;
  final String type; // 'link', 'file', 'note'
  final String content; // URL, путь к файлу или текст заметки

  const ModuleMaterial({
    required this.id,
    required this.title,
    required this.type,
    required this.content,
  });

  ModuleMaterial copyWith({
    String? id,
    String? title,
    String? type,
    String? content,
  }) =>
      ModuleMaterial(
        id: id ?? this.id,
        title: title ?? this.title,
        type: type ?? this.type,
        content: content ?? this.content,
      );
}

class ModuleProgressEntry {
  final DateTime date;
  final double progress; // 0.0 - 1.0
  final int timeSpentMinutes;

  const ModuleProgressEntry({
    required this.date,
    required this.progress,
    required this.timeSpentMinutes,
  });
}

class ModuleEntity {
  final String id;
  final String title;
  final ModuleType type;
  final int hours;
  final ModuleStatus status;
  final List<TopicItemEntity> topics;
  final List<TopicItemEntity> practices;
  final DateTime? deadline;
  final int? grade; // Оценка (0-100)
  final ModulePriority priority;
  final String? description;
  final String? notes;
  final DateTime createdAt;
  final DateTime? completedAt;
  final List<ModuleStage> stages; // Этапы модуля
  final int timeSpentMinutes; // Время, потраченное на модуль
  final List<ModuleMaterial> materials; // Прикрепленные материалы
  final List<ModuleProgressEntry> progressHistory; // История прогресса

  const ModuleEntity({
    required this.id,
    required this.title,
    required this.type,
    required this.hours,
    required this.status,
    required this.topics,
    required this.practices,
    this.deadline,
    this.grade,
    this.priority = ModulePriority.medium,
    this.description,
    this.notes,
    required this.createdAt,
    this.completedAt,
    this.stages = const [],
    this.timeSpentMinutes = 0,
    this.materials = const [],
    this.progressHistory = const [],
  });

  double get progress {
    final total = topics.length + practices.length;
    if (total == 0) return 0;
    final done = topics.where((t) => t.done).length + practices.where((t) => t.done).length;
    return done / total;
  }

  bool get isOverdue {
    if (deadline == null || status == ModuleStatus.completed) return false;
    return DateTime.now().isAfter(deadline!);
  }

  int get daysUntilDeadline {
    if (deadline == null) return -1;
    return deadline!.difference(DateTime.now()).inDays;
  }

  ModuleEntity copyWith({
    String? id,
    String? title,
    ModuleType? type,
    int? hours,
    ModuleStatus? status,
    List<TopicItemEntity>? topics,
    List<TopicItemEntity>? practices,
    DateTime? deadline,
    int? grade,
    ModulePriority? priority,
    String? description,
    String? notes,
    DateTime? createdAt,
    DateTime? completedAt,
    List<ModuleStage>? stages,
    int? timeSpentMinutes,
    List<ModuleMaterial>? materials,
    List<ModuleProgressEntry>? progressHistory,
  }) =>
      ModuleEntity(
        id: id ?? this.id,
        title: title ?? this.title,
        type: type ?? this.type,
        hours: hours ?? this.hours,
        status: status ?? this.status,
        topics: topics ?? this.topics,
        practices: practices ?? this.practices,
        deadline: deadline ?? this.deadline,
        grade: grade ?? this.grade,
        priority: priority ?? this.priority,
        description: description ?? this.description,
        notes: notes ?? this.notes,
        createdAt: createdAt ?? this.createdAt,
        completedAt: completedAt ?? this.completedAt,
        stages: stages ?? this.stages,
        timeSpentMinutes: timeSpentMinutes ?? this.timeSpentMinutes,
        materials: materials ?? this.materials,
        progressHistory: progressHistory ?? this.progressHistory,
      );

  /// Прогноз завершения модуля на основе текущего прогресса
  DateTime? get estimatedCompletionDate {
    if (progress <= 0 || progress >= 1) return null;
    final daysSinceStart = DateTime.now().difference(createdAt).inDays;
    if (daysSinceStart == 0) return null;
    final progressPerDay = progress / daysSinceStart;
    if (progressPerDay <= 0) return null;
    final daysRemaining = (1 - progress) / progressPerDay;
    return DateTime.now().add(Duration(days: daysRemaining.ceil()));
  }
}

