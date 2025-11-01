import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/book_model.dart';

class BookService extends ChangeNotifier {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child('books');

  final List<Book> _books = [];
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  List<Book> get books => List.unmodifiable(_books);

  /// ✅ Lấy danh sách sách từ Firebase Realtime Database
  Future<void> fetchBooks() async {
    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await _dbRef.get();
      if (snapshot.exists && snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        _books
          ..clear()
          ..addAll(data.entries.map((e) {
            final id = e.key.toString();
            final json = Map<String, dynamic>.from(e.value);
            return Book.fromJson(id, json);
          }));
      } else {
        _books.clear();
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Lỗi khi tải sách từ Firebase: $e');
      }
      _books.clear();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ✅ Đảo trạng thái yêu thích và cập nhật trực tiếp lên Firebase
  Future<void> toggleFavorite(String bookId) async {
    final index = _books.indexWhere((book) => book.id == bookId);
    if (index == -1) return;

    final current = _books[index];
    final newStatus = !current.isFavorite;
    _books[index] = current.copyWith(isFavorite: newStatus);
    notifyListeners();

    try {
      await _dbRef.child(bookId).update({'isFavorite': newStatus});
    } catch (e) {
      if (kDebugMode) print('⚠️ Lỗi cập nhật favorite: $e');
      // Nếu thất bại, rollback lại
      _books[index] = current;
      notifyListeners();
    }
  }

  /// ✅ Lấy danh sách sách yêu thích
  List<Book> get favoriteBooks =>
      _books.where((book) => book.isFavorite).toList();

  /// ✅ Thêm sách mới vào Firebase
  Future<void> addBook(Book book) async {
    try {
      await _dbRef.child(book.id).set(book.toJson());
      _books.add(book);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('⚠️ Lỗi thêm sách: $e');
    }
  }

  /// ✅ Cập nhật sách hiện có
  Future<void> updateBook(Book book) async {
    final index = _books.indexWhere((b) => b.id == book.id);
    if (index == -1) return;

    try {
      await _dbRef.child(book.id).update(book.toJson());
      _books[index] = book;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('⚠️ Lỗi cập nhật sách: $e');
    }
  }

  /// ✅ Xóa sách
  Future<void> deleteBook(String bookId) async {
    final index = _books.indexWhere((b) => b.id == bookId);
    if (index == -1) return;

    try {
      await _dbRef.child(bookId).remove();
      _books.removeAt(index);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('⚠️ Lỗi xóa sách: $e');
    }
  }
}
