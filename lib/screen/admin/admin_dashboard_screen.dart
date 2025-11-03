import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/auth_provider.dart';
import 'admin_book.dart';
import 'admin_category.dart';
import 'admin_setting.dart'; // 👈 [THÊM] Import file cài đặt mới
import '../shared/purchase_history_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0; // 👈 Chỉ số của tab hiện tại

  // ⭐️ [SỬA] Cập nhật danh sách 5 màn hình
  // Thêm AdminSettingsScreen() vào cuối
  static const List<Widget> _screens = [
    DashboardHome(), // Tab 0
    BookManagementScreen(), // Tab 1
    AdminCategory(), // Tab 2
    PurchaseHistoryScreen(isAdmin: true), // Tab 3
    AdminSettingsScreen(), // Tab 4
  ];

  // ⭐️ [SỬA] Cập nhật danh sách 5 tiêu đề
  static const List<String> _screenTitles = [
    'Tổng quan',
    'Quản lý Sách',
    'Quản lý Thể loại',
    'Quản lý Đơn hàng',
    'Cài đặt'
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Lấy màu primary từ theme hiện tại (Light/Dark)
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_screenTitles[_selectedIndex]), // 👈 Tiêu đề thay đổi theo tab
        // ⭐️ [SỬA] Màu AppBar sẽ tự động theo theme
        // Không cần nút Logout ở đây nữa vì đã chuyển vào Cài đặt
        actions: [
          // Bạn có thể thêm nút thông báo cho Admin ở đây nếu muốn
          // IconButton(
          //   icon: const Icon(Icons.notifications_none),
          //   onPressed: () {},
          // ),
        ],
      ),
      // ⭐️ [SỬA] Hiển thị các màn hình dùng IndexedStack để giữ state
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      // ⭐️ [SỬA] Cập nhật BottomNavigationBar
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // 👈 Luôn hiển thị label
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        // ⭐️ [SỬA] Màu sắc lấy từ theme
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Tổng quan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            activeIcon: Icon(Icons.book),
            label: 'Sách',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category_outlined),
            activeIcon: Icon(Icons.category),
            label: 'Thể loại',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Đơn hàng',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Cài đặt',
          ),
        ],
      ),
    );
  }
}

// --- ⭐️ [SỬA] Giao diện DashboardHome mới ---
// Giao diện này tập trung vào thống kê, hữu ích hơn cho Admin
class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy theme
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // TODO: Thay thế dữ liệu giả này bằng Provider của bạn
    const int totalOrders = 58;
    const double totalRevenue = 12500000;
    const int totalUsers = 120;
    const int totalBooks = 75;
    final cartProvider = Provider.of<AuthProvider>(context, listen: false);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thống kê Nhanh',
            style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // 4 thẻ thống kê
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true, // 👈 Bắt buộc trong SingleChildScrollView
            physics: const NeverScrollableScrollPhysics(), // 👈 Không cho grid cuộn
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5, // 👈 Điều chỉnh tỉ lệ thẻ
            children: [
              _buildStatCard(
                context,
                icon: Icons.receipt_long,
                label: 'Tổng Đơn hàng',
                value: totalOrders.toString(),
                color: colorScheme.primary,
              ),
              _buildStatCard(
                context,
                icon: Icons.attach_money,
                label: 'Tổng Doanh thu',
                // value: cartProvider.formatPrice(totalRevenue), // 👈 Dùng formatter của bạn
                value: "12,500,000 đ", // Dùng tạm
                color: colorScheme.tertiary,
              ),
              _buildStatCard(
                context,
                icon: Icons.people,
                label: 'Tổng Người dùng',
                value: totalUsers.toString(),
                color: colorScheme.secondary,
              ),
              _buildStatCard(
                context,
                icon: Icons.book,
                label: 'Tổng Sách',
                value: totalBooks.toString(),
                color: Colors.orange,
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Danh sách đơn hàng gần đây
          Text(
            'Đơn hàng Gần đây',
            style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          // TODO: Thay bằng ListView.builder từ OrderProvider
          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: const Text('Đơn hàng #12345'),
              subtitle: const Text('Nguyễn Văn A - 3 sản phẩm'),
              trailing: const Text(
                '550,000 đ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                // TODO: Điều hướng đến chi tiết đơn hàng
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: const Text('Đơn hàng #12344'),
              subtitle: const Text('Trần Thị B - 1 sản phẩm'),
              trailing: const Text(
                '120,000 đ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }

  // Widget helper cho thẻ thống kê
  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: color.withOpacity(0.1), // 👈 Màu nền mờ
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 32, color: color), // 👈 Icon với màu chính
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color, // 👈 Giá trị với màu chính
                      ),
                ),
                Text(label, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
