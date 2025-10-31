import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ungdungbansach/models/book_model.dart';
import 'package:ungdungbansach/widgets/book_card.dart';
import '/providers/book_service.dart';
import 'package:ungdungbansach/screen/book_detail_screen.dart';
import 'package:ungdungbansach/widgets/cart_icon_badge.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;
  String _query = '';
  String _selectedCategory = 'All';

  final List<String> _categories = const [
    'All',
    'Programming',
    'History',
    'Science',
    'Fiction',
    'Business',
  ];

  // 🔍 Hàm lọc sách
  List<Book> _getFilteredBooks(BookService bookService) {
    final allBooks = bookService.books;
    if (allBooks.isEmpty) return [];

    final q = _query.toLowerCase().trim();

    return allBooks.where((book) {
      final matchesQuery =
          q.isEmpty ||
          book.title.toLowerCase().contains(q) ||
          book.author.toLowerCase().contains(q);

      final matchesCategory =
          _selectedCategory == 'All' ||
          book.genre.toLowerCase() == _selectedCategory.toLowerCase();

      return matchesQuery && matchesCategory;
    }).toList();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) {
        setState(() => _query = value.trim());
      }
    });
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
      if (_controller.text.trim().isEmpty) {
        _query = '';
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
  void initState() {
    super.initState();
    _query = '';
  }

  @override
  Widget build(BuildContext context) {
    final bookService = Provider.of<BookService>(context);
    final filteredBooks = _getFilteredBooks(bookService);

    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          height: 40,
          child: TextField(
            controller: _controller,
            onChanged: _onQueryChanged,
            decoration: InputDecoration(
              hintText: 'Tìm kiếm theo tên sách hoặc tác giả...',
              prefixIcon: const Icon(Icons.search, size: 20),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        actions: const [CartIconBadge(), SizedBox(width: 8)],
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),

      body: Column(
        children: [
          // 🎯 Thanh chọn danh mục
          SizedBox(
            height: 45,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (_) => _onCategorySelected(category),
                    selectedColor: Theme.of(context).colorScheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // 📚 Danh sách sách
          Expanded(
            child: bookService.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredBooks.isEmpty && _query.isEmpty && _selectedCategory == 'All'
                    ? Center(
                        child: Text(
                          'Bắt đầu nhập để tìm kiếm sách hoặc chọn danh mục.',
                          style: GoogleFonts.nunito(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final crossAxisCount = constraints.maxWidth > 900
                              ? 6
                              : constraints.maxWidth > 600
                                  ? 4
                                  : 2;

                          if (filteredBooks.isEmpty) {
                            return Center(
                              child: Text(
                                'Không tìm thấy kết quả phù hợp.',
                                style: GoogleFonts.nunito(
                                  color: Colors.grey.shade700,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            );
                          }

                          return GridView.builder(
                            padding: const EdgeInsets.all(12.0),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.55,
                            ),
                            itemCount: filteredBooks.length,
                            itemBuilder: (context, index) {
                              final book = filteredBooks[index];
                              return BookCard(
                                book: book,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          BookDetailScreen(book: book),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
