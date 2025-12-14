import '../../domain/entities/module_entity.dart';
import '../../domain/repositories/modules_repository.dart';
import '../datasources/hive_data_source.dart';
import '../models/module_model.dart';

/// Реализация репозитория для модулей
/// Использует Hive (NoSQL) для быстрого доступа к модулям
class ModulesRepositoryImpl implements ModulesRepository {
  final HiveDataSource _dataSource;

  ModulesRepositoryImpl(this._dataSource);

  @override
  Future<List<ModuleEntity>> getModules() async {
    final models = _dataSource.getModulesEx();
    return models;
  }

  @override
  Future<void> saveModules(List<ModuleEntity> modules) async {
    final models = modules.map((e) => ModuleModel.fromEntity(e)).toList();
    await _dataSource.setModulesEx(models);
  }
}

