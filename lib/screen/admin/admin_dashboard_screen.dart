import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ungdungbansach/providers/auth_provider.dart';

import 'admin_book.dart';
import 'admin_category.dart';
import 'package:ungdungbansach/screen/shared/purchase_history_screen.dart';


class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    // Gán các màn hình bạn muốn điều hướng
    _screens = const [
      DashboardHome(),
      BookManagementScreen(),
      AdminCategory(),
      PurchaseHistoryScreen()
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.redAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authProvider.logout(),
            tooltip: 'Đăng xuất',
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.redAccent,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Sách',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Thể loại',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Lịch sử',
          ),
        ],
      ),
    );
  }
}

class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Đăng nhập ADMIN thành công.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18, color: Colors.red),
      ),
    );
  }
}
