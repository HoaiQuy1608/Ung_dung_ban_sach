import 'package:flutter/material.dart';
import 'package:ungdungbansach/models/book_model.dart';

class BookService extends ChangeNotifier {
  final List<Book> _books = [
    Book(
      id: 'b1',
      title: 'Nhà Giả Kim',
      author: 'Paulo Coelho',
      genre: 'Fiction',
      imageBase64:
          'https://images.unsplash.com/photo-1544947950-fa07a98d237f?q=80&w=150&h=200&fit=crop',
      price: 99000,
      description:
          'Tiểu thuyết kinh điển về hành trình theo đuổi ước mơ. Đã bán hàng triệu bản trên toàn thế giới.',
      rating: 4.8,
    ),
    Book(
      id: 'b2',
      title: 'Đắc Nhân Tâm',
      author: 'Dale Carnegie',
      genre: 'Business',
      imageBase64:
          'https://images.unsplash.com/photo-1592496431122-2349e0fbc666?q=80&w=150&h=200&fit=crop',
      price: 120000,
      description:
          'Tuyệt tác nghệ thuật đối nhân xử thế, giúp bạn thành công trong giao tiếp và cuộc sống.',
      rating: 4.9,
    ),
    Book(
      id: 'b3',
      title: 'Tư Duy Nhanh và Chậm',
      author: 'Daniel Kahneman',
      genre: 'Business',
      imageBase64:
          'https://images.unsplash.com/photo-1589998059171-988d880ad7d6?q=80&w=150&h=200&fit=crop',
      price: 185000,
      description:
          'Khám phá hai hệ thống chi phối cách chúng ta suy nghĩ, từ người đạt giải Nobel Kinh tế.',
      rating: 4.7,
    ),
    Book(
      id: 'b4',
      title: '7 Thói Quen Của Người Thành Đạt',
      author: 'Stephen Covey',
      genre: 'Business',
      imageBase64:
          'https://images.unsplash.com/photo-1550794537-88da1e21b767?q=80&w=150&h=200&fit=crop',
      price: 150000,
      description:
          'Cẩm nang xây dựng nhân cách và hiệu suất cá nhân đỉnh cao.',
      rating: 4.6,
    ),
  ];

  bool _isLoading = true;

  bool get isLoading => _isLoading;
  List<Book> get books => [..._books];

  /// Giả lập quá trình load dữ liệu (vd: từ Firebase)
  Future<void> fetchBooks() async {
    _isLoading = true;
    notifyListeners();

    // Giả lập độ trễ khi load dữ liệu
    await Future.delayed(const Duration(seconds: 2));

    _isLoading = false;
    notifyListeners();
  }

  /// Đảo trạng thái yêu thích của sách
  void toggleFavoriteStatus(String bookId) {
    final index = _books.indexWhere((book) => book.id == bookId);
    if (index >= 0) {
      final existingBook = _books[index];
      _books[index] = existingBook.copyWith(
        isFavorite: !existingBook.isFavorite,
      );
      notifyListeners();
    }
  }

  /// Danh sách sách yêu thích
  List<Book> get favoriteBooks {
    return _books.where((book) => book.isFavorite).toList();
  }
}
