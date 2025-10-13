import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // BẮT BUỘC
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart'; // IMPORT CART PROVIDER
import 'package:ungdungbansach/models/book_model.dart';

class BookDetailScreen extends StatelessWidget {
  final Book book;
  const BookDetailScreen({super.key, required this.book});

  // Hàm mở URL (giả lập liên kết tác giả)
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  void _addToCart(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng nhập để thêm sản phẩm vào giỏ hàng.'),
          backgroundColor: Colors.deepPurple,
        ),
      );
      return;
    }
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.addItem(book);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã thêm "${book.title}" vào giỏ hàng.'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Lấy provider để sử dụng formatPrice (nếu cần)
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final formattedPrice = cartProvider.formatPrice(book.price);

    return Scaffold(
      appBar: AppBar(
        title: Text(book.title, style: GoogleFonts.merriweather()),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Phần Header và Ảnh
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.teal.shade50,
              width: double.infinity,
              child: Center(
                child: Hero(
                  tag: 'book-${book.id}', // Hero animation
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      book.imageUrl
                          .replaceAll('w=150', 'w=300')
                          .replaceAll('h=200', 'h=400'),
                      height: 350,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 350,
                        width: 250,
                        color: Colors.grey.shade300,
                        child: const Center(child: Text('Lỗi tải ảnh')),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Phần Chi tiết
            Padding(
              padding: const EdgeInsets.all(20.0),
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
                    formattedPrice, // SỬ DỤNG GIÁ ĐÃ FORMAT
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
                  const SizedBox(height: 100), // Khoảng trống cuối trang
                ],
              ),
            ),
          ],
        ),
      ),

      // BOTTOM BAR CHO NÚT THÊM VÀO GIỎ HÀNG
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
        child: ElevatedButton.icon(
          onPressed: () => _addToCart(context), // <--- KẾT NỐI HÀM THÊM VÀO GIỎ
          icon: const Icon(Icons.shopping_cart, size: 24),
          label: const Text('THÊM VÀO GIỎ HÀNG'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepOrange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            textStyle: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
