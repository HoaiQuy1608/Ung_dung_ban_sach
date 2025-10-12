import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ungdungbansach/models/user.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Widget hiển thị khi người dùng CHƯA đăng nhập
  Widget _buildLoginPrompt(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            Icons.account_circle,
            size: 90,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 20),
          const Text(
            'Bạn chưa đăng nhập',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'Đăng nhập để xem thông tin cá nhân và lịch sử đơn hàng.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 40),

          ElevatedButton(
            onPressed: () {
              // Chuyển đến màn hình Đăng nhập
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('ĐĂNG NHẬP NGAY'),
          ),
        ],
      ),
    );
  }

  // HÀM ĐÃ SỬA: Xử lý Đăng xuất và thêm HỘP THOẠI XÁC NHẬN
  void _handleLogout(BuildContext context, AuthProvider authProvider) async {
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận Đăng xuất'),
          content: const Text('Bạn có muốn đăng xuất khỏi tài khoản không?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Hủy
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
      // Sau khi logout, ProfileScreen sẽ tự động rebuild và hiển thị LoginPrompt
      // Không cần Navigator.pop() ở đây trừ khi bạn muốn quay về Home ngay lập tức
      // Chúng ta sẽ giữ nguyên màn hình Profile (hiển thị lời nhắc đăng nhập)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        final isAuthenticated = authProvider.isAuthenticated;

        // Nếu CHƯA đăng nhập, hiển thị lời nhắc đăng nhập
        if (!isAuthenticated) {
          return Scaffold(
            appBar: AppBar(title: const Text('Tài Khoản')),
            body: _buildLoginPrompt(context),
          );
        }

        // Nếu ĐÃ đăng nhập, hiển thị thông tin và chức năng
        return Scaffold(
          appBar: AppBar(title: const Text('Trang Cá Nhân')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 1. Phần Avatar và Thông tin cơ bản
              const SizedBox(height: 12),
              Center(
                child: CircleAvatar(
                  radius: 44,
                  child: Icon(
                    Icons.person,
                    size: 44,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  // Hiển thị vai trò (Admin/User)
                  user?.role == UserRole.admin ? 'Quản trị viên' : 'Khách hàng',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              Center(
                child: Text(
                  // Hiển thị Email người dùng
                  user?.email ?? 'N/A',
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),

              // 2. Các Chức năng chính
              ListTile(
                leading: const Icon(Icons.receipt_long_outlined),
                title: const Text('Đơn hàng của tôi'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.favorite_border),
                title: const Text('Sách yêu thích'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('Cài đặt ứng dụng'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              const SizedBox(height: 20),

              // 3. Nút Đăng xuất
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Đăng xuất'),
                onTap: () =>
                    _handleLogout(context, authProvider), // GỌI HÀM XÁC NHẬN
              ),
            ],
          ),
        );
      },
    );
  }
}
