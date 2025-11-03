// lib/providers/book_service.dart
import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/book_model.dart';

class BookService extends ChangeNotifier {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child(
    'books',
  );
  final DatabaseReference _userRef = FirebaseDatabase.instance.ref().child(
    'users',
  );
  final List<Book> _books = [];
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  List<Book> get books => List.unmodifiable(_books);

  List<Book> _searchResults = [];
  bool _isSearching = false;
  List<Book> get searchResults => List.unmodifiable(_searchResults);
  bool get isSearching => _isSearching;

  Future<void> fetchBooks() async {
    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await _dbRef.get();
      if (snapshot.exists && snapshot.value != null) {
        _books
          ..clear()
          ..addAll(snapshot.children.map((child) => Book.fromSnapshot(child)));
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

      final Map<String, bool> favToSave = {for (var id in favorites) id: true};
      await userFavRef.set(favToSave);

      for (int i = 0; i < _books.length; i++) {
        _books[i] = _books[i].copyWith(
          isFavorite: favorites.contains(_books[i].id),
        );
      }
      for (int i = 0; i < _searchResults.length; i++) {
        _searchResults[i] = _searchResults[i].copyWith(
          isFavorite: favorites.contains(_searchResults[i].id),
        );
      }

      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('⚠️ Lỗi toggle favorite: $e');
    }
  }

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
      if (category != 'All')
        queryRef = queryRef.orderByChild('genre').equalTo(category);

      final snapshot = await queryRef.get();
      final List<Book> results = [];

      if (snapshot.exists && snapshot.value != null) {
        final q = query.toLowerCase().trim();
        for (final child in snapshot.children) {
          final book = Book.fromSnapshot(child);
          if (q.isEmpty ||
              book.title.toLowerCase().contains(q) ||
              book.author.toLowerCase().contains(q)) {
            results.add(book);
          }
        }
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
