import 'package:get_it/get_it.dart';
import 'app_state.dart';

final getIt = GetIt.instance;

/// Регистрируем все зависимости приложения
void setupDI() {
  if (!getIt.isRegistered<AppState>()) {
    // AppState создаётся один раз и живёт всё время работы приложения
    getIt.registerLazySingleton<AppState>(() => AppState());
  }
}