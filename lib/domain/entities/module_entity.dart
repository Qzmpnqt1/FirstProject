/// Domain entity для модуля обучения
enum ModuleType { lecture, practice, lab }
enum ModuleStatus { notStarted, inProgress, completed }
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
      );
}

