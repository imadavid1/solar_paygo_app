class AuthSession {
  final String accessToken;
  final int userId;
  final String name;
  final String email;
  final String role;

  const AuthSession({
    required this.accessToken,
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
  });

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      accessToken: json['access_token'] as String,
      userId: json['user_id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
    );
  }

  bool get isProvider => role.toLowerCase() == 'provider';
}