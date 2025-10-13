class User {
  final String id;
  final String email;
  final String name;
  final int permissions;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.permissions,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    email: json['email'],
    name: json['name'],
    permissions: json['permissions'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'permissions': permissions,
  };
}

class Session {
  final String id;
  final String userId;
  final String token;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime expiresAt;
  final User user;

  Session({
    required this.id,
    required this.userId,
    required this.token,
    required this.createdAt,
    required this.updatedAt,
    required this.expiresAt,
    required this.user,
  });

  factory Session.fromJson(Map<String, dynamic> json) => Session(
    id: json['id'],
    userId: json['userId'],
    token: json['token'],
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
    expiresAt: DateTime.parse(json['expiresAt']),
    user: User.fromJson(json['user']),
  );
}

class SessionResponse {
  final Session session;

  SessionResponse({required this.session});

  factory SessionResponse.fromJson(Map<String, dynamic> json) =>
      SessionResponse(session: Session.fromJson(json['session']));
}
