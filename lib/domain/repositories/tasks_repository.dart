import '../entities/task_entity.dart';

/// Интерфейс репозитория для работы с задачами
abstract class TasksRepository {
  Future<List<TaskEntity>> getTasks();
  Future<void> saveTasks(List<TaskEntity> tasks);
}

