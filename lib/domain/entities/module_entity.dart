/// Domain entity для модуля обучения
enum ModuleType { lecture, practice, lab }
enum ModuleStatus { notStarted, inProgress, completed }

class TopicItemEntity {
  final String title;
  final bool done;

  const TopicItemEntity({
    required this.title,
    this.done = false,
  });

  TopicItemEntity copyWith({
    String? title,
    bool? done,
  }) =>
      TopicItemEntity(
        title: title ?? this.title,
        done: done ?? this.done,
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

  const ModuleEntity({
    required this.id,
    required this.title,
    required this.type,
    required this.hours,
    required this.status,
    required this.topics,
    required this.practices,
  });

  double get progress {
    final total = topics.length + practices.length;
    if (total == 0) return 0;
    final done = topics.where((t) => t.done).length + practices.where((t) => t.done).length;
    return done / total;
  }

  ModuleEntity copyWith({
    String? id,
    String? title,
    ModuleType? type,
    int? hours,
    ModuleStatus? status,
    List<TopicItemEntity>? topics,
    List<TopicItemEntity>? practices,
  }) =>
      ModuleEntity(
        id: id ?? this.id,
        title: title ?? this.title,
        type: type ?? this.type,
        hours: hours ?? this.hours,
        status: status ?? this.status,
        topics: topics ?? this.topics,
        practices: practices ?? this.practices,
      );
}

