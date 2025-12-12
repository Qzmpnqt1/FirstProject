import '../../domain/entities/auth_user_entity.dart';

/// Data model для пользователя с JSON сериализацией
class AuthUserModel extends AuthUserEntity {
  const AuthUserModel({
    required super.email,
    required super.fullName,
  });

  factory AuthUserModel.fromEntity(AuthUserEntity entity) => AuthUserModel(
        email: entity.email,
        fullName: entity.fullName,
      );

  Map<String, dynamic> toJson() => {
        'email': email,
        'fullName': fullName,
      };

  factory AuthUserModel.fromJson(Map<String, dynamic> json) => AuthUserModel(
        email: json['email'] as String,
        fullName: json['fullName'] as String,
      );
}

