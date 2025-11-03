import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ungdungbansach/models/user.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'wishlist_screen.dart';
import './shared/purchase_history_screen.dart';
import './edit_profile_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Widget _buildLoginPrompt(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Padding(
      padding: EdgeInsets.fromLTRB(24.0, topPadding + 20, 24.0, 24.0),
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

          // ✅ Nút đăng nhập thường
          ElevatedButton(
            onPressed: () {
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

          const SizedBox(height: 16),

          // ✅ Nút đăng nhập bằng Google
          /*OutlinedButton.icon(
            icon: Image.asset('assets/google_icon.png', height: 24), // nhớ thêm ảnh vào assets
            label: const Text('Đăng nhập với Google'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              side: BorderSide(color: Colors.grey.shade400),
            ),
            onPressed: () async {
              final authProvider =
                  Provider.of<AuthProvider>(context, listen: false);
              final success = await authProvider.loginWithGoogle();

              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đăng nhập Google thành công!')),
                );
              }
            },
          ),*/
        ],
      ),
    );
  }

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
      await authProvider.logout();
    }
  }

  Widget _buildUserInfoSection(
    BuildContext context,
    User user,
    AuthProvider authProvider,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const SizedBox(height: 30),
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
              user.name.isNotEmpty ? user.name : 'Người dùng',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Center(
            child: Text(
              user.role == UserRole.admin ? 'Quản trị viên' : 'Khách hàng',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          Center(
            child: Text(user.email, style: const TextStyle(color: Colors.grey)),
          ),
          const SizedBox(height: 24),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.receipt_long_outlined),
            title: const Text('Đơn hàng của tôi'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const PurchaseHistoryScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit_note_outlined),
            title: const Text('Chỉnh sửa Hồ sơ'),
            subtitle: const Text('Tên, SĐT, Địa chỉ'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite_border),
            title: const Text('Sách yêu thích'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const WishlistScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Cài đặt ứng dụng'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const SizedBox(height: 20),
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
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(0),
            child: AppBar(title: const SizedBox()),
          ),
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
