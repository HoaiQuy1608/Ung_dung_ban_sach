import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';

import '/providers/auth_provider.dart';
import '/providers/book_service.dart';
import '/widgets/book_card.dart';
import 'book_detail_screen.dart';
import 'search_screen.dart';
import 'cart_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Giả định BookService có tồn tại và fetchBooks là hàm lấy dữ liệu
      Provider.of<BookService>(context, listen: false).fetchBooks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookService = Provider.of<BookService>(context);

    // List các trang ứng với Bottom Bar
    final List<Widget> pages = [
      // Home grid
      LayoutBuilder(
        builder: (context, constraints) {
          // Logic responsive cho số cột
          final crossAxisCount = constraints.maxWidth > 900
              ? 6
              : constraints.maxWidth > 600
              ? 4
              : 2;

          // Tỉ lệ khung hình an toàn nhất cho GridView 2 cột (0.58-0.60)
          const double safeAspectRatio = 0.55;

          return GridView.builder(
            // Áp dụng padding trực tiếp và chỉ sử dụng một cuộn (an toàn)
            padding: const EdgeInsets.all(12.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: safeAspectRatio,
            ),
            itemCount: bookService.books.length,
            itemBuilder: (context, index) {
              final book = bookService.books[index];
              return BookCard(
                book: book,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BookDetailScreen(book: book),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      const SearchScreen(),
      const CartScreen(),
      const NotificationsScreen(),
      const ProfileScreen(),
    ];

    String titleForIndex(int i) {
      switch (i) {
        case 0:
          return 'Trang chủ';
        case 1:
          return 'Tìm kiếm';
        case 2:
          return 'Giỏ hàng';
        case 3:
          return 'Thông báo';
        case 4:
          return 'Tài khoản';
        default:
          return 'Bookify';
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(titleForIndex(_currentIndex)),
        actions: const [],
      ),
      // Bọc IndexedStack bằng SafeArea để tránh tràn viền hệ thống
      body: SafeArea(
        child: IndexedStack(index: _currentIndex, children: pages),
      ),
      bottomNavigationBar: ConvexAppBar(
        initialActiveIndex: _currentIndex,
        backgroundColor: Theme.of(context).colorScheme.primary,
        color: Colors.white70,
        activeColor: Theme.of(context).colorScheme.onPrimary,
        items: const [
          TabItem(icon: Icons.home, title: 'Home'),
          TabItem(icon: Icons.search, title: 'Search'),
          TabItem(icon: Icons.shopping_cart, title: 'Cart'),
          TabItem(icon: Icons.notifications, title: 'Alerts'),
          TabItem(icon: Icons.person, title: 'Profile'),
        ],
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}
