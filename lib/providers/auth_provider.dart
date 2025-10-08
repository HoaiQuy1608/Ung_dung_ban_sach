import 'package:flutter/foundation.dart';
import 'package:ungdungbansach/models/user.dart';

class AuthProvider extends ChangeNotifier {
  // Tài khoản Admin
  static const User _adminUser = User(
    email: 'admin@book.com',
    password: 'admin123',
    role: UserRole.admin,
  );

  final List<User> _users = [];

  User? _currentUser;

  bool get isAuthenticated => _currentUser != null;

  bool get isAdmin => _currentUser?.role == UserRole.admin;

  // --- Chức năng ĐĂNG KÝ ---
  bool register(String email, String password) {
    if (email == _adminUser.email) return false;

    if (_users.any((user) => user.email == email)) {
      return false;
    }

    final newUser = User(email: email, password: password, role: UserRole.user);
    _users.add(newUser);

    return true;
  }

  // --- Chức năng ĐĂNG NHẬP ---
  bool login(String email, String password) {
    // 1. Kiểm tra tài khoản Admin trước
    if (email == _adminUser.email && password == _adminUser.password) {
      _currentUser = _adminUser;
      notifyListeners();
      return true;
    }

    // 2. Nếu không phải Admin, tìm trong danh sách User thường
    final user = _users.firstWhere(
      (user) => user.email == email && user.password == password,
      orElse: () => const User(email: '', password: '', role: UserRole.user),
    );

    if (user.email.isNotEmpty) {
      _currentUser = user;
      notifyListeners();
      return true;
    }

    return false;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
