import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ungdungbansach/models/book_model.dart';
import 'package:ungdungbansach/widgets/book_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;
  String _query = '';

  // Mock catalog
  final List<Book> _allBooks = [
    Book(
      id: 's1',
      title: 'Flutter in Action',
      author: 'Eric Windmill',
      imageUrl:
          'https://images.unsplash.com/photo-1544947950-fa07a98d237f?q=80&w=300&h=400&fit=crop',
      price: 290000,
      description: 'Practical guide to building apps with Flutter.',
      rating: 4.6,
    ),
    Book(
      id: 's2',
      title: 'Clean Code',
      author: 'Robert C. Martin',
      imageUrl:
          'https://images.unsplash.com/photo-1553729459-efe14ef6055d?q=80&w=300&h=400&fit=crop',
      price: 350000,
      description: 'A Handbook of Agile Software Craftsmanship.',
      rating: 4.9,
    ),
    Book(
      id: 's3',
      title: 'Atomic Habits',
      author: 'James Clear',
      imageUrl:
          'https://images.unsplash.com/photo-1507842217343-583bb7270b66?q=80&w=300&h=400&fit=crop',
      price: 210000,
      description: 'Tiny changes, remarkable results.',
      rating: 4.8,
    ),
  ];

  List<Book> get _filteredBooks {
    if (_query.isEmpty) return [];
    final q = _query.toLowerCase();
    return _allBooks
        .where(
          (b) =>
              b.title.toLowerCase().contains(q) ||
              b.author.toLowerCase().contains(q),
        )
        .toList();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) {
        setState(() {
          _query = value.trim();
        });
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Books')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              onChanged: _onChanged,
              decoration: const InputDecoration(
                hintText: 'Search by title or author...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _query.isEmpty
                  ? Center(
                      child: Text(
                        'Start typing to search books',
                        style: GoogleFonts.nunito(color: Colors.grey),
                      ),
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final crossAxisCount = constraints.maxWidth > 900
                            ? 6
                            : constraints.maxWidth > 600
                            ? 4
                            : 2;
                        if (_filteredBooks.isEmpty) {
                          return Center(
                            child: Text(
                              'No results for "$_query"',
                              style: GoogleFonts.nunito(),
                            ),
                          );
                        }
                        return GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.6,
                              ),
                          itemCount: _filteredBooks.length,
                          itemBuilder: (context, index) =>
                              BookCard(book: _filteredBooks[index]),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
