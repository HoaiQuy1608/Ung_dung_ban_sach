import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/cart_model.dart';
import '../models/book_model.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  //Tính Tổng tiền
  double get totalPrice {
    return _items.fold(
      0.0,
      (sum, item) => sum + (item.book.price * item.quantity),
    );
  }

  //Hàm thêm vào giỏ hàng
  void addItem(Book book) {
    final existingItemIndex = _items.indexWhere(
      (item) => item.book.id == book.id,
    );

    if (existingItemIndex >= 0) {
      _items[existingItemIndex].quantity += 1;
    } else {
      _items.add(CartItem(book: book));
    }
    notifyListeners();
  }

  //Hàm đặt hàng (mô phỏng)
  void placeOrder() {
    _items.clear();
    notifyListeners();
  }

  // Hàm xóa sản phẩm khỏi giỏ
  void removeItem(String bookId) {
    _items.removeWhere((item) => item.book.id == bookId);
    notifyListeners();
  }

  // Hàm tăng số lượng
  void increaseQuantity(String bookId) {
    _items.firstWhere((item) => item.book.id == bookId).quantity += 1;
    notifyListeners();
  }

  //Hàm giảm số lượng
  void decreaseQuantity(String bookId) {
    final existingItem = _items.firstWhere((item) => item.book.id == bookId);
    if (existingItem.quantity > 1) {
      existingItem.quantity -= 1;
    } else {
      removeItem(bookId);
    }
    notifyListeners();
  }

  //Định dạng giá tiền (package intl)
  String formatPrice(double price) {
    final formatter = NumberFormat('#,### VNĐ', 'vi_VN');
    return formatter.format(price);
  }
}
