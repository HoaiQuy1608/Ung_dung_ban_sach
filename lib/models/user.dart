enum UserRole { admin, user }

class User {
  final String id;
  final String email;
  final String password;
  final UserRole role;

  const User({
    required this.id,
    required this.email,
    required this.password,
    required this.role,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'email': email,
        'password': password,
        'role': role.name,
      };

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      password: map['password'],
      role: map['role'] == 'admin' ? UserRole.admin : UserRole.user,
    );
  }
}
