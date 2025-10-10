import 'package:flutter/foundation.dart';
import 'package:ungdungbansach/models/user.dart';

class AuthProvider extends ChangeNotifier {
  // Tài khoản Admin
  static const User _adminUser = User(
    email: 'admin@book.com',
    password: 'admin123',
    role: UserRole.admin,
  );

  // Khởi tạo danh sách người dùng với tài khoản mặc định
  final List<User> _users = [
    const User(email: 'user@book.com', password: 'password123', role: UserRole.user),
  ];

  User? _currentUser;

  bool get isAuthenticated => _currentUser != null;

  bool get isAdmin => _currentUser?.role == UserRole.admin;

  // --- Chức năng ĐĂNG KÝ ---
  bool register(String email, String password) {
    // Không cho phép đăng ký tài khoản trùng với admin
    if (email == _adminUser.email) return false;

    // Kiểm tra email đã tồn tại chưa
    if (_users.any((user) => user.email == email)) {
      return false;
    }

    final newUser = User(email: email, password: password, role: UserRole.user);
    _users.add(newUser);

    // Bổ sung: Nếu đăng ký thành công, tự động đăng nhập người dùng này
    _currentUser = newUser;
    notifyListeners();

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
    // Sử dụng firstWhere với orElse để trả về null thay vì ném lỗi (an toàn hơn)
    final user = _users.firstWhereOrNull(
      (user) => user.email == email && user.password == password,
    );
    
    // Nếu tìm thấy, đăng nhập thành công
    if (user != null) {
      _currentUser = user;
      notifyListeners();
      return true;
    } else {
      // Nếu không tìm thấy user, trả về false
      return false;
    }
  }

  // --- Chức năng ĐĂNG XUẤT ---
  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}

// Thêm extension để sử dụng firstWhereOrNull một cách an toàn
extension IterableExtension<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E element) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
