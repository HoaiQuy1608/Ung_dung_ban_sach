import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart';

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

  /// -----------------------------
  /// 🔹 Đăng ký (email + password)
  /// -----------------------------
  Future<bool> register(String email, String password) async {
    final usersRef = _database.child('users');
    final snapshot = await usersRef.orderByChild('email').equalTo(email).get();

    if (snapshot.exists) return false; // Email đã tồn tại

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

  /// -----------------------------
  /// 🔹 Đăng nhập (email + password)
  /// -----------------------------
  Future<bool> login(String email, String password) async {
    // Kiểm tra admin mặc định
    if (email == _adminUser.email && password == _adminUser.password) {
      _currentUser = _adminUser;
      notifyListeners();
      return true;
    }

    final usersRef = _database.child('users');
    final snapshot = await usersRef.orderByChild('email').equalTo(email).get();

    if (snapshot.exists) {
      final userMap =
          Map<String, dynamic>.from(snapshot.children.first.value as Map);
      final user = User.fromMap(userMap);
      if (user.password == password) {
        _currentUser = user;
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  /// -----------------------------
  /// 🔹 Đăng nhập bằng Google
  /// -----------------------------
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  Future<bool> loginWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return false; // Người dùng hủy

      final email = googleUser.email;
      final displayName = googleUser.displayName ?? 'Người dùng Google';
      final photoUrl = googleUser.photoUrl ?? '';

      final usersRef = _database.child('users');
      final snapshot = await usersRef.orderByChild('email').equalTo(email).get();

      User user;

      if (snapshot.exists) {
        // 🔹 Người dùng đã tồn tại trong DB
        final userMap =
            Map<String, dynamic>.from(snapshot.children.first.value as Map);
        user = User.fromMap(userMap);
      } else {
        // 🔹 Người dùng mới → tạo mới
        final id = _uuid.v4();
        user = User(
          id: id,
          email: email,
          password: '', // không cần mật khẩu cho Google
          role: UserRole.user,
          name: displayName,
        );

        await usersRef.child(id).set(user.toMap());
      }

      _currentUser = user;
      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) print('Lỗi đăng nhập Google: $e');
      return false;
    }
  }

  /// -----------------------------
  /// 🔹 Đăng xuất
  /// -----------------------------
  Future<void> logout() async {
    _currentUser = null;
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    notifyListeners();
  }

  /// -----------------------------
  /// 🔹 Cập nhật hồ sơ
  /// -----------------------------
  Future<void> updateProfile(String name, String phone, String address) async {
    if (_currentUser == null) return;

    final updates = {'name': name, 'phone': phone, 'address': address};

    try {
      await _database.child('users').child(_currentUser!.id).update(updates);
      _currentUser = _currentUser!.copyWith(
        name: name,
        phone: phone,
        address: address,
      );
      notifyListeners();
    } catch (error) {
      if (kDebugMode) print('Lỗi khi cập nhật hồ sơ: $error');
      rethrow;
    }
  }
}
