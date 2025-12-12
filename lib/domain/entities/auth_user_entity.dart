/// Domain entity для пользователя
class AuthUserEntity {
  final String email;
  final String fullName;

  const AuthUserEntity({
    required this.email,
    required this.fullName,
  });
}

