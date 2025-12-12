/// Domain entity для задачи (без зависимостей от инфраструктуры)
class TaskEntity {
  final String title;
  final bool done;

  const TaskEntity({
    required this.title,
    this.done = false,
  });

  TaskEntity copyWith({
    String? title,
    bool? done,
  }) =>
      TaskEntity(
        title: title ?? this.title,
        done: done ?? this.done,
      );
}

