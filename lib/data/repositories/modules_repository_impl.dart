import '../../domain/entities/module_entity.dart';
import '../../domain/repositories/modules_repository.dart';
import '../datasources/data_source_interface.dart';
import '../models/module_model.dart';

/// Реализация репозитория для модулей
class ModulesRepositoryImpl implements ModulesRepository {
  final DataSourceInterface _dataSource;

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

