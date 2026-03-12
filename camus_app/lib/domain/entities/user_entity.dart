class User {
  final String id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});
}

class LoggedUser extends User {
  final String token;
  final String refreshToken;

  LoggedUser({
    required this.token,
    required this.refreshToken,
    required super.id,
    required super.name,
    required super.email,
  });
}
