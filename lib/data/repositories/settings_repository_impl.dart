import '../../domain/entities/app_settings_entity.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/local_storage_data_source.dart';

/// Реализация репозитория для настроек
/// Использует SharedPreferences для простых настроек
class SettingsRepositoryImpl implements SettingsRepository {
  final LocalStorageDataSource _dataSource;

  SettingsRepositoryImpl(this._dataSource);

  @override
  Future<AppSettingsEntity> getSettings() async {
    return AppSettingsEntity(
      themeDark: _dataSource.getDark(),
      notifications: _dataSource.getNotifications(),
      analytics: _dataSource.getAnalytics(),
      name: _dataSource.getName(),
      role: _dataSource.getRole(),
      group: _dataSource.getProfileGroup(),
      goal: _dataSource.getProfileGoal(),
      contacts: _dataSource.getProfileContacts(),
      counter: _dataSource.getCounter(),
    );
  }

  @override
  Future<void> saveSettings(AppSettingsEntity settings) async {
    await _dataSource.setDark(settings.themeDark);
    await _dataSource.setNotifications(settings.notifications);
    await _dataSource.setAnalytics(settings.analytics);
    await _dataSource.setName(settings.name);
    await _dataSource.setRole(settings.role);
    await _dataSource.setProfileGroup(settings.group);
    await _dataSource.setProfileGoal(settings.goal);
    await _dataSource.setProfileContacts(settings.contacts);
    await _dataSource.setCounter(settings.counter);
  }
}

