import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/tasks_repository.dart';
import '../datasources/drift_data_source.dart';
import '../models/task_model.dart';

/// Реализация репозитория для задач
/// Использует Drift (SQL) для структурированного хранения задач
class TasksRepositoryImpl implements TasksRepository {
  final DriftDataSource _dataSource;

  TasksRepositoryImpl(this._dataSource);

  @override
  Future<List<TaskEntity>> getTasks() async {
    final models = _dataSource.getTasks();
    return models;
  }

  @override
  Future<void> saveTasks(List<TaskEntity> tasks) async {
    final models = tasks.map((e) => TaskModel.fromEntity(e)).toList();
    await _dataSource.setTasks(models);
  }
}

