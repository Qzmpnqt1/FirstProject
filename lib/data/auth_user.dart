class AuthUser {
  final String email;
  final String fullName;

  const AuthUser({required this.email, required this.fullName});

  Map<String, dynamic> toJson() => {'email': email, 'fullName': fullName};

  factory AuthUser.fromJson(Map<String, dynamic> json) =>
      AuthUser(email: json['email'] as String, fullName: json['fullName'] as String);
}
