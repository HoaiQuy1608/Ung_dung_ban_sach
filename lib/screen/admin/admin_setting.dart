import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/theme_provider.dart'; // 👈 Dùng chung provider
import '/providers/auth_provider.dart';
import '../login_screen.dart';

class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  // Xử lý đăng xuất
  Future<void> _confirmLogout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận Đăng xuất'),
          content: const Text(
            'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản Quản trị viên không?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(false), // Không đăng xuất
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Đăng xuất
              child: const Text(
                'Đăng xuất',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      authProvider.logout();
      // Về thẳng LoginScreen và xóa hết lịch sử
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lắng nghe ThemeProvider để cập nhật UI
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      // AppBar sẽ tự động có màu theo theme
      appBar: AppBar(
        title: const Text('Cài đặt Quản trị'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- Chức năng đổi Theme ---
          ListTile(
            leading: Icon(
              themeProvider.themeMode == ThemeMode.dark
                  ? Icons.dark_mode_outlined
                  : Icons.light_mode_outlined,
              color: Theme.of(context).colorScheme.secondary,
            ),
            title: const Text('Chế độ nền tối'),
            subtitle: const Text('Đồng bộ với cài đặt của người dùng'),
            trailing: Switch(
              value: themeProvider.themeMode == ThemeMode.dark,
              onChanged: (value) {
                // Thay đổi theme cho toàn bộ ứng dụng (cả User và Admin)
                Provider.of<ThemeProvider>(
                  context,
                  listen: false,
                ).setTheme(value);
              },
            ),
          ),
          const Divider(),
          // --- Nút Đăng xuất ---
          ListTile(
            leading: Icon(Icons.logout, color: Theme.of(context).colorScheme.error),
            title: Text(
              'Đăng xuất',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            onTap: () => _confirmLogout(context),
          ),
        ],
      ),
    );
  }
}
