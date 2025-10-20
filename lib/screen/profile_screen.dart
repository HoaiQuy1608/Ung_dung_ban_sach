import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ungdungbansach/models/user.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Widget hiển thị khi người dùng CHƯA đăng nhập
  Widget _buildLoginPrompt(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Padding(
      padding: EdgeInsets.fromLTRB(24.0, topPadding + 20, 24.0, 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // TIÊU ĐỀ ĐÃ ĐƯỢC XÓA Ở ĐÂY
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

  // Hàm xử lý Đăng xuất và thêm HỘP THOẠI XÁC NHẬN
  void _handleLogout(BuildContext context, AuthProvider authProvider) async {
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận Đăng xuất'),
          content: const Text('Bạn có muốn đăng xuất khỏi tài khoản không?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
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
    }
  }

  // Widget hiển thị thông tin cá nhân (Đã đăng nhập)
  Widget _buildUserInfoSection(
    BuildContext context,
    User user,
    AuthProvider authProvider,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // TIÊU ĐỀ ĐÃ ĐƯỢC XÓA Ở ĐÂY
          const SizedBox(height: 30), // Giữ lại khoảng cách cho phần Avartar
          Center(
            child: CircleAvatar(
              radius: 44,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Icon(
                Icons.person,
                size: 44,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              user.role == UserRole.admin ? 'Quản trị viên' : 'Khách hàng',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          Center(
            child: Text(user.email, style: const TextStyle(color: Colors.grey)),
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
            onTap: () => _handleLogout(context, authProvider),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        final isAuthenticated = authProvider.isAuthenticated;

        return Scaffold(
          // APPBAR TỐI GIẢN (Để tránh tiêu đề thừa)
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(0),
            child: AppBar(title: const SizedBox()),
          ),

          // BODY
          body: SingleChildScrollView(
            child: isAuthenticated
                ? _buildUserInfoSection(context, user!, authProvider)
                : _buildLoginPrompt(context),
          ),
        );
      },
    );
  }
}
