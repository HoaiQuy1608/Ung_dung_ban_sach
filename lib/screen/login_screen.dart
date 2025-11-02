import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ungdungbansach/providers/auth_provider.dart';
import 'package:ungdungbansach/screen/register_screen.dart';
import 'package:ungdungbansach/screen/admin/admin_dashboard_screen.dart';
import '../screen/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;
  bool _isPasswordVisible = false;

  Future<void> _handleLogin() async {
    setState(() {
      _errorMessage = null;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Hiển thị loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final success = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      Navigator.of(context).pop(); // Đóng loading

      if (success) {
        if (authProvider.isAdmin) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
            (_) => false,
          );
        } else {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (_) => false,
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Email hoặc mật khẩu không đúng.';
        });
      }
    } catch (e) {
      Navigator.of(context).pop();
      setState(() {
        _errorMessage = 'Đã xảy ra lỗi khi đăng nhập: $e';
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Lấy ColorScheme từ theme
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface, // Nền sáng
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Tiêu đề & Logo (Icon sách lớn)
              Icon(
                Icons.menu_book_rounded,
                color: colorScheme.primary, // Dùng màu primary từ theme
                size: 80,
              ),
              const SizedBox(height: 10),
              Text(
                'BOOKSTORE',
                textAlign: TextAlign.center,
                style: GoogleFonts.merriweather(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: colorScheme.primary, // Dùng màu primary từ theme
                ),
              ),
              const SizedBox(height: 50),

              // Thông báo lỗi
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(
                        12,
                      ), // Bo góc mềm mại hơn
                      border: Border.all(color: colorScheme.error),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: colorScheme.onErrorContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              // Trường Email
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Nhập email của bạn',
                  prefixIcon: Icon(
                    Icons.email,
                    color: colorScheme.secondary,
                  ), // Màu secondary
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      12,
                    ), // Bo góc mềm mại hơn
                  ),
                  focusedBorder: OutlineInputBorder(
                    // Viền khi focus
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Trường Mật khẩu
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu',
                  hintText: 'Nhập mật khẩu',
                  prefixIcon: Icon(
                    Icons.lock,
                    color: colorScheme.secondary,
                  ), // Màu secondary
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      12,
                    ), // Bo góc mềm mại hơn
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: colorScheme.onSurfaceVariant, // Màu icon
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                obscureText: !_isPasswordVisible,
              ),
              const SizedBox(height: 40),

              // Nút Đăng nhập
              ElevatedButton(
                onPressed: _handleLogin,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  backgroundColor: colorScheme.primary, // Dùng màu primary
                  foregroundColor:
                      colorScheme.onPrimary, // Chữ trắng trên primary
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  'ĐĂNG NHẬP',
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Nút chuyển trang Đăng ký
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const RegisterScreen(),
                    ),
                  );
                },
                child: Text(
                  'Chưa có tài khoản? Đăng ký ngay!',
                  style: GoogleFonts.inter(
                    color: colorScheme.secondary,
                    fontSize: 16,
                  ), // Dùng màu secondary
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
