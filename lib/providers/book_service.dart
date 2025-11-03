// providers/book_service.dart
import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/book_model.dart';

class BookService extends ChangeNotifier {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child('books');
  final DatabaseReference _userRef = FirebaseDatabase.instance.ref().child('users'); // ⭐️ node user
  final List<Book> _books = [];
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  List<Book> get books => List.unmodifiable(_books);

  List<Book> _searchResults = [];
  bool _isSearching = false;
  List<Book> get searchResults => List.unmodifiable(_searchResults);
  bool get isSearching => _isSearching;

  /// --- Load sách ---
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
      if (kDebugMode) print('⚠️ Lỗi khi tải sách: $e');
      _books.clear();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// --- Toggle favorite cho user riêng ---
  Future<void> toggleFavorite(String bookId, String userId) async {
    final userFavRef = _userRef.child(userId).child('favorites');

    try {
      final snapshot = await userFavRef.get();
      Set<String> favorites = {};
      if (snapshot.exists && snapshot.value != null) {
        final favMap = Map<String, dynamic>.from(snapshot.value as Map);
        favorites = favMap.keys.map((e) => e.toString()).toSet();
      }

      if (favorites.contains(bookId)) {
        favorites.remove(bookId);
      } else {
        favorites.add(bookId);
      }

      // Lưu lại vào Firebase
      final Map<String, bool> favToSave = { for (var id in favorites) id: true };
      await userFavRef.set(favToSave);

      // Cập nhật local isFavorite cho từng book (dùng để UI rebuild)
      for (int i = 0; i < _books.length; i++) {
        _books[i] = _books[i].copyWith(isFavorite: favorites.contains(_books[i].id));
      }
      for (int i = 0; i < _searchResults.length; i++) {
        _searchResults[i] = _searchResults[i].copyWith(isFavorite: favorites.contains(_searchResults[i].id));
      }

      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('⚠️ Lỗi toggle favorite: $e');
    }
  }

  /// --- Lấy danh sách sách yêu thích của user ---
  Future<List<Book>> getFavoriteBooks(String userId) async {
    final userFavRef = _userRef.child(userId).child('favorites');
    try {
      final snapshot = await userFavRef.get();
      Set<String> favorites = {};
      if (snapshot.exists && snapshot.value != null) {
        final favMap = Map<String, dynamic>.from(snapshot.value as Map);
        favorites = favMap.keys.map((e) => e.toString()).toSet();
      }
      return _books.where((b) => favorites.contains(b.id)).toList();
    } catch (e) {
      if (kDebugMode) print('⚠️ Lỗi load favorite books: $e');
      return [];
    }
  }

  /// --- Hàm search ---
  Future<void> searchBooks(String query, String category) async {
    if (query.isEmpty && category == 'All') {
      _searchResults = [];
      _isSearching = false;
      notifyListeners();
      return;
    }

    _isSearching = true;
    _searchResults = [];
    notifyListeners();

    try {
      Query queryRef = _dbRef;
      if (category != 'All') queryRef = queryRef.orderByChild('genre').equalTo(category);

      final snapshot = await queryRef.get();
      final List<Book> results = [];

      if (snapshot.exists && snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        final q = query.toLowerCase().trim();
        data.forEach((key, value) {
          final book = Book.fromJson(key, Map<String, dynamic>.from(value));
          if (q.isEmpty || book.title.toLowerCase().contains(q) || book.author.toLowerCase().contains(q)) {
            results.add(book);
          }
        });
      }

      _searchResults = results;
    } catch (e) {
      if (kDebugMode) print('⚠️ Lỗi tìm kiếm: $e');
      _searchResults = [];
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _searchResults.clear();
    _isSearching = false;
    notifyListeners();
  }

  /// --- Thêm sách mới (Admin) ---
  Future<void> addBook(Book book) async {
    try {
      final newRef = _dbRef.push();
      final newId = newRef.key!;
      final newBook = book.copyWith(id: newId);
      await newRef.set(newBook.toJson());
      _books.add(newBook);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('⚠️ Lỗi thêm sách: $e');
    }
  }

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
