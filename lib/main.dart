// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ungdungbansach/providers/auth_provider.dart';
import 'package:ungdungbansach/screen/admin/admin_book.dart';
import 'package:ungdungbansach/screen/home_screen.dart';
import 'package:ungdungbansach/screen/login_screen.dart';
import 'package:ungdungbansach/screen/admin/admin_dashboard_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // Đăng ký AuthProvider để toàn ứng dụng có thể truy cập trạng thái
      providers: [ChangeNotifierProvider(create: (context) => AuthProvider())],
      child: MaterialApp(
        title: 'Ứng dụng Bán Sách',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
        // AuthWrapper sẽ tự động chuyển hướng
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isAuthenticated) {
      if (authProvider.isAdmin) {
        return const AdminDashboardScreen();
      }
      return const HomeScreen();
    } else {
      return const LoginScreen();
    }
  }
}
