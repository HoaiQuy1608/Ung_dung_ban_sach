// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:ungdungbansach/providers/auth_provider.dart';
import 'package:ungdungbansach/screen/admin/admin_book.dart';
import 'package:ungdungbansach/providers/book_service.dart'; // THÊM IMPORT BOOK SERVICE
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
      // CẬP NHẬT: Đăng ký cả AuthProvider và BookService
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(
          create: (context) => BookService(),
        ), // ĐĂNG KÝ BOOK SERVICE
      ],
      child: MaterialApp(
        title: 'Bookify',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(Brightness.light),
        darkTheme: _buildTheme(Brightness.dark),
        themeMode: ThemeMode.system,
        builder: EasyLoading.init(),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // AuthWrapper lắng nghe thay đổi từ AuthProvider
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isAuthenticated) {
      if (authProvider.isAdmin) {
        return const AdminDashboardScreen();
      } else {
        // Sau khi người dùng thường đăng nhập thành công, chuyển đến HomeScreen
        return const HomeScreen();
      }
    } else {
      // Nếu chưa đăng nhập, chuyển đến màn hình Login
      return const LoginScreen();
    }
  }
}

// App theme for Bookify using Material 3, Nunito, and brand colors
ThemeData _buildTheme(Brightness brightness) {
  final Color seed = const Color(0xFF6C63FF); // Primary
  final Color accent = const Color(0xFFFFA500); // Accent
  final ColorScheme baseScheme = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: brightness,
  ).copyWith(tertiary: accent);

  final textTheme = GoogleFonts.nunitoTextTheme();

  return ThemeData(
    useMaterial3: true,
    colorScheme: baseScheme,
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      centerTitle: true,
      backgroundColor: baseScheme.primary,
      foregroundColor: baseScheme.onPrimary,
    ),
    scaffoldBackgroundColor: brightness == Brightness.dark
        ? const Color(0xFF111315)
        : Colors.white,
    snackBarTheme: SnackBarThemeData(
      backgroundColor: baseScheme.primary,
      contentTextStyle: textTheme.bodyMedium?.copyWith(
        color: baseScheme.onPrimary,
      ),
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}
