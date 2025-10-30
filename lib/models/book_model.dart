enum BookStatus { available, pending, sold }

class Book {
  final String id;
  final String title;
  final String author;
  final List<String> genres;
  final String imageUrl;
  final double price;
  final String description;
  final double rating;
  bool isFavorite;

  Book({
    required this.id,
    required this.title,
    required this.genres,
    required this.author,
    required this.imageUrl,
    required this.price,
    required this.description,
    required this.rating,
    this.isFavorite = false,
  });

  Book copyWith({
    String? id,
    String? title,
    String? author,
    List<String>? genres,
    String? imageUrl,
    double? price,
    String? description,
    double? rating,
    bool? isFavorite,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      genres: genres ?? this.genres,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      description: description ?? this.description,
      rating: rating ?? this.rating,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
