// wishlist_screen.dart
import 'dart:convert'; // 👈 [SỬA] Thêm import để dùng base64Decode
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ungdungbansach/providers/auth_provider.dart';
import 'book_detail_screen.dart';
import 'package:ungdungbansach/providers/book_service.dart';
import 'package:ungdungbansach/models/book_model.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  Widget _buildBookImage(String base64String) {
    try {
      final imageBytes = base64Decode(base64String);
      return Image.memory(
        imageBytes,
        fit: BoxFit.cover,
        width: 50,
        height: 70,
        errorBuilder: (context, error, stackTrace) => _imageError(),
      );
    } catch (e) {
      return _imageError();
    }
  }

  Widget _imageError() {
    return Container(
      width: 50,
      height: 70,
      color: Colors.grey[200],
      child: const Icon(Icons.broken_image, color: Colors.grey),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, BookService>(
      builder: (context, authProvider, bookProvider, _) {
        if (!authProvider.isAuthenticated) {
          return const Scaffold(
            body: Center(
              child: Text('Vui lòng đăng nhập để xem danh sách yêu thích.'),
            ),
          );
        }

        // Lấy danh sách sách yêu thích từ BookService + favorites của user
        final favBookIds = authProvider.currentUser!.favorites;
        final favoriteBooks = bookProvider.books
            .where((book) => favBookIds.contains(book.id))
            .toList();

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
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: SizedBox(
                          width: 50,
                          height: 70,
                          child: _buildBookImage(book.imageBase64),
                        ),
                        title: Text(book.title),
                        subtitle: Text(book.author),
                        trailing: IconButton(
                          icon: const Icon(Icons.favorite, color: Colors.red),
                          onPressed: () async {
                            // Toggle favorite
                            await bookProvider.toggleFavorite(book.id, authProvider.currentUser!.id);

                            // Cập nhật local user favorites
                            final updatedUser = authProvider.currentUser!.copyWith(
                              favorites: Set.from(authProvider.currentUser!.favorites)
                                ..remove(book.id),
                            );
                            authProvider.setCurrentUser(updatedUser);
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
                    );
                  },
                ),
        );
      },
    );
  }
}

