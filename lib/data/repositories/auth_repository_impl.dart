import '../../domain/entities/auth_user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/secure_store_data_source.dart';

/// Реализация репозитория для аутентификации
/// Использует Flutter Secure Store для безопасного хранения паролей и токенов
class AuthRepositoryImpl implements AuthRepository {
  final SecureStoreDataSource _dataSource;

  AuthRepositoryImpl(this._dataSource);

  @override
  Future<AuthUserEntity?> getCurrentUser() async {
    final model = _dataSource.getCurrentUser();
    return model;
  }

  @override
  Future<bool> register(String fullName, String email, String password) async {
    return await _dataSource.register(fullName, email, password);
  }

  @override
  Future<AuthUserEntity?> login(String email, String password) async {
    final model = await _dataSource.login(email, password);
    return model;
  }

  @override
  Future<void> logout() async {
    await _dataSource.logout();
  }
}

