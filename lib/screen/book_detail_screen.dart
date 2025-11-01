import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/book_service.dart';
import '../models/book_model.dart';
import '../models/cart_model.dart';
import 'checkout_screen.dart';

class BookDetailScreen extends StatelessWidget {
  final Book book;
  const BookDetailScreen({super.key, required this.book});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  void _addToCart(BuildContext context, AuthProvider authProvider, CartProvider cartProvider) {
    if (!authProvider.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng nhập để thêm sản phẩm vào giỏ hàng.'),
          backgroundColor: Colors.deepPurple,
        ),
      );
      return;
    }
    cartProvider.addItem(book);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã thêm "${book.title}" vào giỏ hàng.'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _buyNow(BuildContext context, AuthProvider authProvider) {
    if (!authProvider.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng nhập để tiến hành mua hàng.'),
          backgroundColor: Colors.deepPurple,
        ),
      );
      return;
    }
    final tempItem = CartItem(book: book, quantity: 1);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CheckoutScreen(
          itemsToBuy: [tempItem],
          source: CheckoutSource.quickBuy,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final formattedPrice = cartProvider.formatPrice(book.price);

    return Consumer<BookService>(
      builder: (context, bookProvider, _) {
        final currentBook = bookProvider.books.firstWhere((b) => b.id == book.id);
        final isFav = currentBook.isFavorite;

        // Decode Base64
        Uint8List? imageBytes;
        try {
          imageBytes = base64Decode(currentBook.imageBase64);
        } catch (_) {
          imageBytes = null;
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(book.title, style: GoogleFonts.merriweather()),
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.redAccent : Colors.white,
                ),
                onPressed: () async {
                  await bookProvider.toggleFavorite(currentBook.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isFav
                            ? 'Đã bỏ yêu thích ${book.title}'
                            : 'Đã thêm ${book.title} vào danh sách yêu thích',
                      ),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ảnh bìa
                Container(
                  padding: const EdgeInsets.all(20),
                  color: Colors.teal.shade50,
                  width: double.infinity,
                  child: Center(
                    child: Hero(
                      tag: 'book-${book.id}',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: imageBytes != null
                            ? Image.memory(
                                imageBytes,
                                height: 350,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                height: 350,
                                width: 250,
                                color: Colors.grey.shade300,
                                child: const Center(child: Text('Lỗi tải ảnh')),
                              ),
                      ),
                    ),
                  ),
                ),

                // Thông tin sách
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 5),
                          Text(
                            '${book.rating.toStringAsFixed(1)} / 5.0',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            icon: const Icon(Icons.person, size: 18),
                            label: Text(
                              'Tác giả: ${book.author}',
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                color: Colors.blue.shade700,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            onPressed: () => _launchUrl(
                              'https://google.com/search?q=${book.author}',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'GIÁ BÁN:',
                        style: GoogleFonts.openSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        formattedPrice,
                        style: GoogleFonts.inter(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: Colors.red.shade600,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 20),
                      Text(
                        'Tóm tắt nội dung',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        book.description,
                        style: GoogleFonts.roboto(fontSize: 16, height: 1.5),
                        textAlign: TextAlign.justify,
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),

          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _addToCart(context, authProvider, cartProvider),
                    icon: const Icon(Icons.shopping_cart, size: 24, color: Colors.deepOrange),
                    label: const Text('Thêm vào giỏ', style: TextStyle(color: Colors.deepOrange)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      side: const BorderSide(color: Colors.deepOrange),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _buyNow(context, authProvider),
                    icon: const Icon(Icons.payment, size: 24, color: Colors.white),
                    label: const Text('MUA NGAY'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      textStyle: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
