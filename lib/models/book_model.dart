class Book {
  final String id;
  final String title;
  final String author;
  final List<String> genres;
  final String imageUrl;
  final double price;
  final String description;
  final double rating;

  Book({
    required this.id,
    required this.title,
    required this.genres,
    required this.author,
    required this.imageUrl,
    required this.price,
    required this.description,
    required this.rating,
  });
}
