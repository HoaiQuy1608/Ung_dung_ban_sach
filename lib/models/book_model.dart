import 'package:firebase_database/firebase_database.dart';

enum BookStatus { available, pending, sold }

class Book {
  final String id;
  final String title;
  final String author;
  final String genre; // ✅ chỉ 1 thể loại
  final String imageBase64; // ✅ ảnh base64
  final double price;
  final String description;
  final double rating;
  final BookStatus status;
  bool isFavorite;
  final int stock;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.genre,
    required this.imageBase64,
    required this.price,
    required this.description,
    required this.rating,
    this.status = BookStatus.available,
    this.isFavorite = false,
    this.stock = 0,
  });

  factory Book.fromSnapshot(DataSnapshot snapshot) {
    final json = snapshot.value as Map<dynamic, dynamic>? ?? {};
    return Book(
      id: snapshot.key ?? '',
      title: json['title'] as String? ?? '',
      author: json['author'] as String? ?? '',
      genre: json['genre'] as String? ?? '',
      imageBase64: json['imageBase64'] as String? ?? '',
      price: (json['price'] as num? ?? 0.0).toDouble(),
      description: json['description'] as String? ?? '',
      rating: (json['rating'] as num? ?? 0.0).toDouble(),
      status: BookStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String?),
        orElse: () => BookStatus.available,
      ),
      isFavorite: false,
      stock: json['stock'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'genre': genre,
      'imageBase64': imageBase64,
      'price': price,
      'description': description,
      'rating': rating,
      'status': status.name,
      'isFavorite': isFavorite,
      'stock': stock,
    };
  }

  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? genre,
    String? imageBase64,
    double? price,
    String? description,
    double? rating,
    BookStatus? status,
    bool? isFavorite,
    int? stock,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      genre: genre ?? this.genre,
      imageBase64: imageBase64 ?? this.imageBase64,
      price: price ?? this.price,
      description: description ?? this.description,
      rating: rating ?? this.rating,
      status: status ?? this.status,
      isFavorite: isFavorite ?? this.isFavorite,
      stock: stock ?? this.stock,
    );
  }
}
