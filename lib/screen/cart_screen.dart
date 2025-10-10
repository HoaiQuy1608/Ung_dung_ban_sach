import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ungdungbansach/widgets/cart_item_tile.dart';
import 'package:ungdungbansach/models/book_model.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Mock cart items
  final List<_CartLine> _lines = [
    _CartLine(
      book: Book(
        id: 'c1',
        title: 'The Pragmatic Programmer',
        author: 'Andrew Hunt',
        imageUrl:
            'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?q=80&w=300&h=400&fit=crop',
        price: 420000,
        description: 'Journey to mastery.',
        rating: 4.7,
      ),
      qty: 1,
    ),
    _CartLine(
      book: Book(
        id: 'c2',
        title: 'Refactoring',
        author: 'Martin Fowler',
        imageUrl:
            'https://images.unsplash.com/photo-1513475382585-d06e58bcb0ea?q=80&w=300&h=400&fit=crop',
        price: 380000,
        description: 'Improving the design of existing code.',
        rating: 4.8,
      ),
      qty: 2,
    ),
  ];

  double get _total => _lines.fold(0, (sum, l) => sum + l.book.price * l.qty);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('My Cart')),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: _lines.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final line = _lines[index];
                return CartItemTile(
                  book: line.book,
                  quantity: line.qty,
                  onQuantityChanged: (q) =>
                      setState(() => _lines[index] = line.copyWith(qty: q)),
                  onDelete: () => setState(() => _lines.removeAt(index)),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Price',
                        style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${_total.toStringAsFixed(0)} ₫',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: _lines.isEmpty ? null : () {},
                  icon: const Icon(Icons.payment),
                  label: const Text('Checkout'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CartLine {
  final Book book;
  final int qty;
  _CartLine({required this.book, required this.qty});
  _CartLine copyWith({Book? book, int? qty}) =>
      _CartLine(book: book ?? this.book, qty: qty ?? this.qty);
}
