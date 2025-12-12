import '../entities/app_settings_entity.dart';

/// Интерфейс репозитория для настроек приложения
abstract class SettingsRepository {
  Future<AppSettingsEntity> getSettings();
  Future<void> saveSettings(AppSettingsEntity settings);
}

