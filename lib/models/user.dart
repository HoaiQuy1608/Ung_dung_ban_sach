enum UserRole { admin, user }

class User {
  final String id;
  final String email;
  final String password;
  final UserRole role;
  final String name;
  final String phone;
  final String address;

  const User({
    required this.id,
    required this.email,
    required this.password,
    required this.role,
    this.name = '',
    this.phone = '',
    this.address = '',
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'email': email,
    'password': password,
    'role': role.name,
    'name': name,
    'phone': phone,
    'address': address,
  };

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      role: map['role'] == 'admin' ? UserRole.admin : UserRole.user,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
    );
  }

  User copyWith({
    String? id,
    String? email,
    String? password,
    UserRole? role,
    String? name,
    String? phone,
    String? address,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
    );
  }
}
