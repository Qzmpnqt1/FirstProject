import '../entities/module_entity.dart';

/// Интерфейс репозитория для работы с модулями
abstract class ModulesRepository {
  Future<List<ModuleEntity>> getModules();
  Future<void> saveModules(List<ModuleEntity> modules);
}

