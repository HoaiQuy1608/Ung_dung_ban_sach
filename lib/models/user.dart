enum UserRole { user, admin } // Định nghĩa vai trò

class User {
  final String email;
  final String password;
  final UserRole role; // Thuộc tính bắt buộc

  const User({
    required this.email,
    required this.password,
    this.role = UserRole.user, // Giá trị mặc định
  });
}
