import 'package:flutter/foundation.dart';
import 'package:ungdungbansach/models/user.dart';

class AuthProvider extends ChangeNotifier {
  static const User _adminUser = User(
    email: 'admin@book.com',
    password: 'admin123',
    role: UserRole.admin,
  );

  final List<User> _users = [];

  User? _currentUser;

  bool get isAuthenticated => _currentUser != null;

  bool get isAdmin => _currentUser?.role == UserRole.admin;

  User? get currentUser => _currentUser;

  // --- Chức năng ĐĂNG KÝ (Không đổi) ---
  bool register(String email, String password) {
    if (email == _adminUser.email) return false;
    if (_users.any((user) => user.email == email)) {
      return false;
    }

    final newUser = User(email: email, password: password, role: UserRole.user);
    _users.add(newUser);

    return true;
  }

  // --- Chức năng ĐĂNG NHẬP (Không đổi) ---
  bool login(String email, String password) {
    // 1. Kiểm tra tài khoản Admin trước
    if (email == _adminUser.email && password == _adminUser.password) {
      _currentUser = _adminUser;
      notifyListeners();
      return true;
    }

    // 2. Tìm trong danh sách User thường bằng vòng lặp FOR
    User? foundUser;
    for (final user in _users) {
      if (user.email == email && user.password == password) {
        foundUser = user;
        break;
      }
    }

    // 3. Đăng nhập nếu tìm thấy
    if (foundUser != null) {
      _currentUser = foundUser;
      notifyListeners();
      return true;
    }

    return false; // Đăng nhập thất bại
  }

  // --- Chức năng ĐĂNG XUẤT (Không đổi) ---
  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
