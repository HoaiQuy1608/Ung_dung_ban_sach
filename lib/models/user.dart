enum UserRole { admin, user }

class User {
  final String id;
  final String email;
  final String password;
  final UserRole role;
  final String name;
  final String phone;
  final String address;
  final Set<String> favorites; 

  const User({
    required this.id,
    required this.email,
    required this.password,
    required this.role,
    this.name = '',
    this.phone = '',
    this.address = '',
    this.favorites = const {},
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'email': email,
    'password': password,
    'role': role.name,
    'name': name,
    'phone': phone,
    'address': address,
    'favorites': { for (var bookId in favorites) bookId: true },
  };

  factory User.fromMap(Map<String, dynamic> map) {
    final favMap = Map<String, dynamic>.from(map['favorites'] ?? {});
    final favSet = favMap.keys.toSet();
    return User(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      role: map['role'] == 'admin' ? UserRole.admin : UserRole.user,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      favorites: favSet,
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
    Set<String>? favorites,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      favorites: favorites ?? this.favorites,
    );
  }
}
