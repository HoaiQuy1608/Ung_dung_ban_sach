import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ungdungbansach/models/book_model.dart';
import 'package:url_launcher/url_launcher.dart'; // Thư viện URL Launcher

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

  @override
  Widget build(BuildContext context) {
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
                      book.imageUrl.replaceAll('w=150', 'w=300').replaceAll('h=200', 'h=400'),
                      height: 350,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(
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
                      Text('${book.rating} / 5.0', style: const TextStyle(fontSize: 16)),
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
                        onPressed: () => _launchUrl('https://google.com/search?q=${book.author}'), // Mở liên kết tìm kiếm tác giả
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'GIÁ BÁN:',
                    style: GoogleFonts.openSans(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${book.price.toStringAsFixed(0)} VNĐ',
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
        child: ElevatedButton.icon(
          onPressed: () {
            // Logic thêm vào giỏ hàng
          },
          icon: const Icon(Icons.shopping_cart, size: 24),
          label: const Text('THÊM VÀO GIỎ HÀNG'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepOrange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            textStyle: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
