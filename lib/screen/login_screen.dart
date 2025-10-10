import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart'; // Thư viện Google Fonts
import 'package:ungdungbansach/providers/auth_provider.dart';
import 'package:ungdungbansach/screen/register_screen.dart';

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

  void _handleLogin() {
    setState(() {
      _errorMessage = null; // Xóa lỗi cũ
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!success) {
      setState(() {
        _errorMessage = 'Email hoặc Mật khẩu không đúng. Vui lòng thử lại.';
      });
    } else {
      // Đăng nhập thành công, AuthWrapper tự chuyển hướng
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
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Tiêu đề & Logo (Icon sách lớn)
              Icon(
                Icons.menu_book_rounded,
                color: Colors.blue.shade700,
                size: 80,
              ),
              const SizedBox(height: 10),
              Text(
                'BOOKSTORE',
                textAlign: TextAlign.center,
                style: GoogleFonts.merriweather(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: Colors.blue.shade900,
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
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade300),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold),
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
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
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
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
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
                  backgroundColor: Colors.deepPurple.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  'ĐĂNG NHẬP',
                  style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.bold),
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
                  style: GoogleFonts.inter(color: Colors.blue.shade700, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
