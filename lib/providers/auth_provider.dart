import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';
import 'package:ungdungbansach/models/user.dart';

class AuthProvider extends ChangeNotifier {
  static final _database = FirebaseDatabase.instance.ref();
  static const _uuid = Uuid();

  static final User _adminUser = User(
    id: 'admin-id',
    email: 'admin@book.com',
    password: 'admin123',
    role: UserRole.admin,
  );

  User? _currentUser;
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _currentUser?.role == UserRole.admin;

  /// --- Đăng ký ---
  Future<bool> register(String email, String password) async {
    final usersRef = _database.child('users');

    // Kiểm tra email đã tồn tại chưa
    final snapshot = await usersRef
        .orderByChild('email')
        .equalTo(email)
        .get();

    if (snapshot.exists) return false;

    final id = _uuid.v4();
    final newUser = User(
      id: id,
      email: email,
      password: password,
      role: UserRole.user,
    );

    await usersRef.child(id).set(newUser.toMap());
    return true;
  }

  /// --- Đăng nhập ---
  Future<bool> login(String email, String password) async {
    // Kiểm tra admin
    if (email == _adminUser.email && password == _adminUser.password) {
      _currentUser = _adminUser;
      notifyListeners();
      return true;
    }

    final usersRef = _database.child('users');
    final snapshot = await usersRef
        .orderByChild('email')
        .equalTo(email)
        .get();

    if (snapshot.exists) {
      final userMap = Map<String, dynamic>.from(
        (snapshot.children.first.value as Map),
      );

      final user = User.fromMap(userMap);

      if (user.password == password) {
        _currentUser = user;
        notifyListeners();
        return true;
      }
    }

    return false;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
