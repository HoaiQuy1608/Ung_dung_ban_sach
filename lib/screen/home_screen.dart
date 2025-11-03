import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
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
      Provider.of<BookService>(context, listen: false).fetchBooks();
    });
  }

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

  @override
  Widget build(BuildContext context) {
    final bookService = Provider.of<BookService>(context);

    final List<Widget> pages = [
      LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = constraints.maxWidth > 900
              ? 6
              : constraints.maxWidth > 600
              ? 4
              : 2;

          const double safeAspectRatio = 0.55;

          if (bookService.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (bookService.books.isEmpty) {
            return const Center(
              child: Text('Không có sách nào trong hệ thống.'),
            );
          }

          return GridView.builder(
            key: const PageStorageKey('homeGrid'),
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentIndex == 0 ? 'Bookify' : titleForIndex(_currentIndex),
        ),
        actions: const [],
      ),
      body: SafeArea(
        child: IndexedStack(index: _currentIndex, children: pages),
      ),
      bottomNavigationBar: ConvexAppBar(
        initialActiveIndex: _currentIndex,
        backgroundColor: Theme.of(context).colorScheme.primary,
        color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
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
