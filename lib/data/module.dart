enum ModuleType { lecture, practice, lab }
enum ModuleStatus { notStarted, inProgress, completed }

class TopicItem {
  final String title;
  final bool done;
  const TopicItem(this.title, {this.done = false});

  TopicItem copyWith({String? title, bool? done}) =>
      TopicItem(title ?? this.title, done: done ?? this.done);

  Map<String, dynamic> toJson() => {'title': title, 'done': done};
  factory TopicItem.fromJson(Map<String, dynamic> j) =>
      TopicItem(j['title'] as String, done: j['done'] as bool? ?? false);
}

class Module {
  final String id;
  final String title;
  final ModuleType type;
  final int hours; // трудоёмкость
  final ModuleStatus status;
  final List<TopicItem> topics;     // теоретические темы
  final List<TopicItem> practices;  // практические задания

  const Module({
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

  Module copyWith({
    String? id,
    String? title,
    ModuleType? type,
    int? hours,
    ModuleStatus? status,
    List<TopicItem>? topics,
    List<TopicItem>? practices,
  }) =>
      Module(
        id: id ?? this.id,
        title: title ?? this.title,
        type: type ?? this.type,
        hours: hours ?? this.hours,
        status: status ?? this.status,
        topics: topics ?? this.topics,
        practices: practices ?? this.practices,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'type': type.name,
    'hours': hours,
    'status': status.name,
    'topics': topics.map((e) => e.toJson()).toList(),
    'practices': practices.map((e) => e.toJson()).toList(),
  };

  factory Module.fromJson(Map<String, dynamic> j) => Module(
    id: j['id'] as String,
    title: j['title'] as String,
    type: ModuleType.values.firstWhere((e) => e.name == j['type']),
    hours: j['hours'] as int,
    status: ModuleStatus.values.firstWhere((e) => e.name == j['status']),
    topics: (j['topics'] as List).map((e) => TopicItem.fromJson(e)).toList(),
    practices: (j['practices'] as List).map((e) => TopicItem.fromJson(e)).toList(),
  );
}
