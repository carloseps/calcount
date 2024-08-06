class User {
  String? id;
  String email;
  String password;

  User({this.id, required this.email, required this.password});

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
    };
  }
}
