// lib/screens/home_screen.dart (Đã cập nhật)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart'; // Import AuthProvider

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy ra AuthProvider để sử dụng hàm logout
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang Chủ 🏠'),
        centerTitle: true,
        actions: [
          // Nút Đăng xuất
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Gọi hàm logout()
              authProvider.logout();
              // AuthWrapper sẽ tự động nhận biết trạng thái thay đổi
              // và chuyển hướng người dùng về LoginScreen
            },
            tooltip: 'Đăng xuất',
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Bạn đã đăng nhập thành công!\nNhấn icon Đăng xuất để thoát.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, color: Colors.blueGrey),
        ),
      ),
    );
  }
}
