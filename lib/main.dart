// lib/main.dart (Đã sửa để LUÔN khởi động ở chế độ sáng)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:ungdungbansach/providers/auth_provider.dart';
import 'package:ungdungbansach/providers/book_service.dart';
import 'package:ungdungbansach/screen/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // Đăng ký AuthProvider và BookService
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => BookService()),
      ],
      child: MaterialApp(
        title: 'Bookify',
        debugShowCheckedModeBanner: false,
        // SỬA ĐỔI: Chỉ gọi theme sáng
        theme: _buildTheme(Brightness.light),

        // darkTheme và themeMode đã được loại bỏ/bỏ qua
        builder: EasyLoading.init(),
        home: const HomeScreen(),
      ),
    );
  }
}

// Hàm theme không cần thay đổi logic bên trong
ThemeData _buildTheme(Brightness brightness) {
  final Color seed = const Color(0xFF6C63FF);
  final Color accent = const Color(0xFFFFA500);
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
    scaffoldBackgroundColor: Colors.white, // ĐẢM BẢO MÀU TRẮNG
    snackBarTheme: SnackBarThemeData(
      backgroundColor: baseScheme.primary,
      contentTextStyle: textTheme.bodyMedium?.copyWith(
        color: baseScheme.onPrimary,
      ),
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}
