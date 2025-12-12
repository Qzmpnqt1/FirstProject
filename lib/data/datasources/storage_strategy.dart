import 'data_source_interface.dart';
import 'local_storage_data_source.dart';
import 'secure_store_data_source.dart';
import 'drift_data_source.dart';
import 'hive_data_source.dart';
import '../database/app_database.dart';

/// Тип хранилища
enum StorageType {
  sharedPreferences,
  secureStore,
  drift,
  hive,
}

/// Стратегия выбора источника данных
class StorageStrategy {
  final StorageType _type;
  DataSourceInterface? _dataSource;

  StorageStrategy(this._type);

  Future<DataSourceInterface> getDataSource() async {
    if (_dataSource != null) return _dataSource!;

    switch (_type) {
      case StorageType.sharedPreferences:
        await LocalStorageDataSource.init();
        _dataSource = LocalStorageDataSource();
        break;
      case StorageType.secureStore:
        await SecureStoreDataSource.init();
        final secureStore = SecureStoreDataSource();
        await secureStore.loadCache();
        _dataSource = secureStore;
        break;
      case StorageType.drift:
        final db = await DriftDataSource.init();
        final drift = DriftDataSource(db);
        await drift.loadCache();
        _dataSource = drift;
        break;
      case StorageType.hive:
        await HiveDataSource.init();
        _dataSource = HiveDataSource();
        break;
    }
    return _dataSource!;
  }

  static StorageType getDefaultType() {
    // Можно добавить логику выбора типа хранилища
    // Например, на основе настроек пользователя или платформы
    return StorageType.sharedPreferences;
  }
}

