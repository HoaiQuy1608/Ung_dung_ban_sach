import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'book_detail_screen.dart';
import 'package:ungdungbansach/providers/book_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ungdungbansach/models/book_model.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bookProvider = Provider.of<BookService>(context);
    final favoriteBooks = bookProvider.favoriteBooks;

    return Scaffold(
      appBar: AppBar(title: const Text('Sách Yêu Thích'), centerTitle: true),
      body: favoriteBooks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Bạn chưa có sách yêu thích nào',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hãy thêm sách vào danh sách yêu thích của bạn!',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: favoriteBooks.length,
              itemBuilder: (context, index) {
                final book = favoriteBooks[index];
                return Dismissible(
                  key: ValueKey(book.id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    bookProvider.toggleFavoriteStatus(book.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Đã xóa "${book.title}" khỏi sách yêu thích.',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: SizedBox(
                        width: 50,
                        height: 70,
                        child: CachedNetworkImage(
                          imageUrl: book.imageBase64,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              Container(color: Colors.grey[200]),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.broken_image),
                        ),
                      ),
                      title: Text(book.title),
                      subtitle: Text(book.author),
                      trailing: IconButton(
                        icon: const Icon(Icons.favorite, color: Colors.red),
                        onPressed: () {
                          bookProvider.toggleFavoriteStatus(book.id);
                        },
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => BookDetailScreen(book: book),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
