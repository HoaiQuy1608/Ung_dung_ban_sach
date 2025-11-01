import 'book_model.dart';

class CartItem {
  final Book book;
  int quantity;

  CartItem({required this.book, this.quantity = 1});

  Map<String, dynamic> toMap() {
    return {
      'bookId': book.id,
      'quantity': quantity,
      'title': book.title,
      'price': book.price,
      'author': book.author,
      'genre': book.genre,
      'imageBase64': book.imageBase64,
    };
  }

  factory CartItem.fromMap(Map<dynamic, dynamic> map) {
    final tempBook = Book(
      id: map['bookId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      price: (map['price'] as num? ?? 0.0).toDouble(),
      imageBase64: map['imageBase64'] as String? ?? '',
      author: map['author'] as String? ?? '',
      genre: map['genre'] as String? ?? '',
      description: '',
      rating: 0.0,
    );

    return CartItem(book: tempBook, quantity: map['quantity'] as int? ?? 1);
  }
}
