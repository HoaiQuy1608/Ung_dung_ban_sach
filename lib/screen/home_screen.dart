import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/book_service.dart';
import '../widgets/book_card.dart';
import 'book_detail_screen.dart';
import 'search_screen.dart';
import 'cart_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';

// Chuyển sang StatefulWidget để sử dụng initState
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

  @override
  Widget build(BuildContext context) {
    // Lấy ra AuthProvider để sử dụng hàm logout
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Lắng nghe trạng thái sách
    final bookService = Provider.of<BookService>(context);

    final List<Widget> pages = [
      // Home grid
      Padding(
        padding: const EdgeInsets.all(12.0),
        child: bookService.isLoading
            ? const Center(child: CircularProgressIndicator())
            : LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth > 900
                      ? 6
                      : constraints.maxWidth > 600
                      ? 4
                      : 2;
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.6,
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
      ),
      const SearchScreen(),
      const CartScreen(),
      const NotificationsScreen(),
      const ProfileScreen(),
    ];

    String titleForIndex(int i) {
      switch (i) {
        case 0:
          return 'Home';
        case 1:
          return 'Search Books';
        case 2:
          return 'My Cart';
        case 3:
          return 'Notifications';
        case 4:
          return 'Profile';
        default:
          return 'Bookify';
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(titleForIndex(_currentIndex)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authProvider.logout(),
            tooltip: 'Đăng xuất',
          ),
        ],
      ),
      body: IndexedStack(index: _currentIndex, children: pages),
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
