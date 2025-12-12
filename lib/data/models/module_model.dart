import '../../domain/entities/module_entity.dart';

/// Data model для модуля с JSON сериализацией
class TopicItemModel extends TopicItemEntity {
  const TopicItemModel({
    required super.title,
    super.done = false,
  });

  factory TopicItemModel.fromEntity(TopicItemEntity entity) => TopicItemModel(
        title: entity.title,
        done: entity.done,
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'done': done,
      };

  factory TopicItemModel.fromJson(Map<String, dynamic> json) => TopicItemModel(
        title: json['title'] as String,
        done: json['done'] as bool? ?? false,
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
  });

  factory ModuleModel.fromEntity(ModuleEntity entity) => ModuleModel(
        id: entity.id,
        title: entity.title,
        type: entity.type,
        hours: entity.hours,
        status: entity.status,
        topics: entity.topics.map((t) => TopicItemModel.fromEntity(t)).toList(),
        practices: entity.practices.map((p) => TopicItemModel.fromEntity(p)).toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'type': type.name,
        'hours': hours,
        'status': status.name,
        'topics': topics.map((e) => (e as TopicItemModel).toJson()).toList(),
        'practices': practices.map((e) => (e as TopicItemModel).toJson()).toList(),
      };

  factory ModuleModel.fromJson(Map<String, dynamic> json) => ModuleModel(
        id: json['id'] as String,
        title: json['title'] as String,
        type: ModuleType.values.firstWhere((e) => e.name == json['type']),
        hours: json['hours'] as int,
        status: ModuleStatus.values.firstWhere((e) => e.name == json['status']),
        topics: (json['topics'] as List).map((e) => TopicItemModel.fromJson(e)).toList(),
        practices: (json['practices'] as List).map((e) => TopicItemModel.fromJson(e)).toList(),
      );
}

