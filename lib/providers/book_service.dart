// providers/book_service.dart
import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/book_model.dart';

class BookService extends ChangeNotifier {
  // --- [GIỮ NGUYÊN] Các thuộc tính hiện có ---
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child('books');
  final List<Book> _books = [];
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  List<Book> get books => List.unmodifiable(_books);
  
  // --- ⭐️ [THÊM MỚI] State dành riêng cho tìm kiếm ---
  List<Book> _searchResults = [];
  bool _isSearching = false;

  // --- ⭐️ [THÊM MỚI] Getters cho state tìm kiếm ---
  List<Book> get searchResults => List.unmodifiable(_searchResults);
  bool get isSearching => _isSearching;

  /// --- [GIỮ NGUYÊN] Hàm tải sách cho Trang chủ ---
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

  // --- ⭐️ [THÊM MỚI] Hàm tìm kiếm (GỌI TỪ SEARCH_SCREEN) ---
  /// Giải thích logic:
  /// Firebase Realtime Database không hỗ trợ query "contains" (chứa).
  /// Vì vậy, chúng ta sẽ:
  /// 1. Lọc bằng `category` (nếu có) bằng Firebase Query (yêu cầu indexOn "genre").
  /// 2. Lấy kết quả về.
  /// 3. Lọc tiếp bằng `query` (title/author) ở phía client (trong Dart).
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
      // 1. Tạo query Firebase cơ bản
      Query queryRef = _dbRef;

      // 2. Lọc bằng category (Firebase làm)
      if (category != 'All') {
        // Yêu cầu bạn phải set indexOn trong Rules của Firebase:
        // { "rules": { "books": { ".indexOn": "genre" } } }
        queryRef = queryRef.orderByChild('genre').equalTo(category);
      }
      
      final snapshot = await queryRef.get();
      final List<Book> results = [];

      if (snapshot.exists && snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        
        data.forEach((key, value) {
          final book = Book.fromJson(key, Map<String, dynamic>.from(value));
          final q = query.toLowerCase().trim();

          // 3. Lọc bằng query (Client làm)
          if (q.isEmpty ||
              book.title.toLowerCase().contains(q) ||
              book.author.toLowerCase().contains(q)) {
            results.add(book);
          }
        });
      }
      _searchResults = results;

    } catch (e) {
      if (kDebugMode) print('⚠️ Lỗi khi tìm kiếm: $e');
      _searchResults = [];
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  /// ⭐️ [THÊM MỚI] Hàm dọn dẹp kết quả tìm kiếm
  void clearSearch() {
    _searchResults.clear();
    _isSearching = false;
    notifyListeners();
  }


  /// --- ⭐️ [SỬA ĐỔI] Cập nhật hàm toggleFavorite ---
  /// Hàm này cần cập nhật cả 2 danh sách: _books (Trang chủ)
  /// và _searchResults (Trang tìm kiếm) để UI đồng bộ
  Future<void> toggleFavorite(String bookId) async {
    final indexInBooks = _books.indexWhere((book) => book.id == bookId);
    final indexInSearch = _searchResults.indexWhere((book) => book.id == bookId);

    if (indexInBooks == -1 && indexInSearch == -1) return;

    // Lấy trạng thái hiện tại (ưu tiên lấy từ _books nếu có)
    final current = (indexInBooks != -1) ? _books[indexInBooks] : _searchResults[indexInSearch];
    final newStatus = !current.isFavorite;
    
    // Tạo sách mới với trạng thái đã cập nhật
    final updatedBook = current.copyWith(isFavorite: newStatus);

    // Cập nhật trạng thái tạm thời trên UI
    if (indexInBooks != -1) _books[indexInBooks] = updatedBook;
    if (indexInSearch != -1) _searchResults[indexInSearch] = updatedBook;
    notifyListeners();

    try {
      // Gọi Firebase
      await _dbRef.child(bookId).update({'isFavorite': newStatus});
    } catch (e) {
      if (kDebugMode) print('⚠️ Lỗi cập nhật favorite: $e');
      
      // Nếu thất bại, rollback lại
      if (indexInBooks != -1) _books[indexInBooks] = current;
      if (indexInSearch != -1) _searchResults[indexInSearch] = current;
      notifyListeners();
    }
  }

  /// --- [GIỮ NGUYÊN] Các hàm còn lại ---
  
  /// Lấy danh sách sách yêu thích (từ danh sách _books chính)
  List<Book> get favoriteBooks =>
      _books.where((book) => book.isFavorite).toList();

  /// Thêm sách mới vào Firebase (Dùng cho Admin)
  Future<void> addBook(Book book) async {
    try {
      // Tạo một key mới bằng push() và gán ID cho sách
      final newRef = _dbRef.push();
      final newId = newRef.key!;
      final newBook = book.copyWith(id: newId);
      
      await newRef.set(newBook.toJson());
      _books.add(newBook); // Cập nhật list local
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('⚠️ Lỗi thêm sách: $e');
    }
  }

  /// Cập nhật sách hiện có (Dùng cho Admin)
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

  /// Xóa sách (Dùng cho Admin)
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