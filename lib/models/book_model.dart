enum BookStatus { available, pending, sold }

class Book {
  final String id;
  final String title;
  final String author;
  final String genre; // ✅ chỉ 1 thể loại thôi
  final String imageBase64; // ✅ lưu ảnh dạng base64
  final double price;
  final String description;
  final double rating;
  final BookStatus status;
  bool isFavorite;

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
  });

  factory Book.fromJson(Map<String, dynamic> json, Map<String, dynamic> map) {
    return Book(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      genre: json['genre'] ?? '',
      imageBase64: json['imageBase64'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      status: BookStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => BookStatus.available,
      ),
      isFavorite: json['isFavorite'] ?? false,
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
    );
  }
}
