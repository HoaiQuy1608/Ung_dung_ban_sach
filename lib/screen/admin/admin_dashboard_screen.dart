import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ungdungbansach/providers/auth_provider.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.redAccent,
        actions: [
          // Nút Đăng xuất cho Admin
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authProvider.logout(),
            tooltip: 'Đăng xuất',
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Đăng nhập ADMIN thành công.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, color: Colors.red),
        ),
      ),
    );
  }
}
