import '../../domain/entities/module_entity.dart';

/// Data model для модуля с JSON сериализацией
class TopicItemModel extends TopicItemEntity {
  const TopicItemModel({
    required super.title,
    super.done = false,
    super.notes,
  });

  factory TopicItemModel.fromEntity(TopicItemEntity entity) => TopicItemModel(
        title: entity.title,
        done: entity.done,
        notes: entity.notes,
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'done': done,
        if (notes != null) 'notes': notes,
      };

  factory TopicItemModel.fromJson(Map<String, dynamic> json) => TopicItemModel(
        title: json['title'] as String,
        done: json['done'] as bool? ?? false,
        notes: json['notes'] as String?,
      );
}

class ModuleModel extends ModuleEntity {
  const ModuleModel({
    required super.id,
    required super.title,
    required super.type,
    required super.hours,
    required super.status,
    required super.topics,
    required super.practices,
    super.deadline,
    super.grade,
    super.priority = ModulePriority.medium,
    super.description,
    super.notes,
    required super.createdAt,
    super.completedAt,
    super.stages = const [],
    super.timeSpentMinutes = 0,
    super.materials = const [],
    super.progressHistory = const [],
  });

  factory ModuleModel.fromEntity(ModuleEntity entity) => ModuleModel(
        id: entity.id,
        title: entity.title,
        type: entity.type,
        hours: entity.hours,
        status: entity.status,
        topics: entity.topics.map((t) => TopicItemModel.fromEntity(t)).toList(),
        practices: entity.practices.map((p) => TopicItemModel.fromEntity(p)).toList(),
        deadline: entity.deadline,
        grade: entity.grade,
        priority: entity.priority,
        description: entity.description,
        notes: entity.notes,
        createdAt: entity.createdAt,
        completedAt: entity.completedAt,
        stages: entity.stages,
        timeSpentMinutes: entity.timeSpentMinutes,
        materials: entity.materials,
        progressHistory: entity.progressHistory,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'type': type.name,
        'hours': hours,
        'status': status.name,
        'topics': topics.map((e) => (e as TopicItemModel).toJson()).toList(),
        'practices': practices.map((e) => (e as TopicItemModel).toJson()).toList(),
        if (deadline != null) 'deadline': deadline!.toIso8601String(),
        if (grade != null) 'grade': grade,
        'priority': priority.name,
        if (description != null) 'description': description,
        if (notes != null) 'notes': notes,
        'createdAt': createdAt.toIso8601String(),
        if (completedAt != null) 'completedAt': completedAt!.toIso8601String(),
        'stages': stages.map((s) => {
          'id': s.id,
          'title': s.title,
          'completed': s.completed,
          if (s.completedAt != null) 'completedAt': s.completedAt!.toIso8601String(),
        }).toList(),
        'timeSpentMinutes': timeSpentMinutes,
        'materials': materials.map((m) => {
          'id': m.id,
          'title': m.title,
          'type': m.type,
          'content': m.content,
        }).toList(),
        'progressHistory': progressHistory.map((p) => {
          'date': p.date.toIso8601String(),
          'progress': p.progress,
          'timeSpentMinutes': p.timeSpentMinutes,
        }).toList(),
      };

  factory ModuleModel.fromJson(Map<String, dynamic> json) {
    final deadline = json['deadline'] as String?;
    final completedAt = json['completedAt'] as String?;
    return ModuleModel(
      id: json['id'] as String,
      title: json['title'] as String,
      type: ModuleType.values.firstWhere((e) => e.name == json['type']),
      hours: json['hours'] as int,
      status: ModuleStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ModuleStatus.notStarted,
      ),
      topics: (json['topics'] as List).map((e) => TopicItemModel.fromJson(e)).toList(),
      practices: (json['practices'] as List).map((e) => TopicItemModel.fromJson(e)).toList(),
      deadline: deadline != null ? DateTime.parse(deadline) : null,
      grade: json['grade'] as int?,
      priority: json['priority'] != null
          ? ModulePriority.values.firstWhere((e) => e.name == json['priority'])
          : ModulePriority.medium,
      description: json['description'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      completedAt: completedAt != null ? DateTime.parse(completedAt) : null,
      stages: (json['stages'] as List<dynamic>?)?.map((s) => ModuleStage(
            id: s['id'] as String,
            title: s['title'] as String,
            completed: s['completed'] as bool? ?? false,
            completedAt: s['completedAt'] != null
                ? DateTime.parse(s['completedAt'] as String)
                : null,
          )).toList() ?? const [],
      timeSpentMinutes: json['timeSpentMinutes'] as int? ?? 0,
      materials: (json['materials'] as List<dynamic>?)?.map((m) => ModuleMaterial(
            id: m['id'] as String,
            title: m['title'] as String,
            type: m['type'] as String,
            content: m['content'] as String,
          )).toList() ?? const [],
      progressHistory: (json['progressHistory'] as List<dynamic>?)?.map((p) => ModuleProgressEntry(
            date: DateTime.parse(p['date'] as String),
            progress: (p['progress'] as num).toDouble(),
            timeSpentMinutes: p['timeSpentMinutes'] as int,
          )).toList() ?? const [],
    );
  }
}

