import '../../domain/entities/task_entity.dart';

/// Data model для задачи с JSON сериализацией
class TaskModel extends TaskEntity {
  const TaskModel({
    required super.title,
    super.done = false,
  });

  factory TaskModel.fromEntity(TaskEntity entity) => TaskModel(
        title: entity.title,
        done: entity.done,
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'done': done,
      };

  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
        title: json['title'] as String,
        done: json['done'] as bool? ?? false,
      );
}

