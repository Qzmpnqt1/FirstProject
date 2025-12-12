import '../entities/auth_user_entity.dart';

/// Интерфейс репозитория для аутентификации
abstract class AuthRepository {
  Future<AuthUserEntity?> getCurrentUser();
  Future<bool> register(String fullName, String email, String password);
  Future<AuthUserEntity?> login(String email, String password);
  Future<void> logout();
}

