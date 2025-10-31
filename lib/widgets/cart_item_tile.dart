import 'package:flutter/material.dart';
import 'package:ungdungbansach/models/book_model.dart';

class CartItemTile extends StatelessWidget {
  final Book book;
  final int quantity;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onDelete;
  const CartItemTile({
    super.key,
    required this.book,
    required this.quantity,
    required this.onQuantityChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                book.imageBase64,
                width: 64,
                height: 86,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox(
                  width: 64,
                  height: 86,
                  child: Icon(Icons.broken_image),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${book.price.toStringAsFixed(0)} ₫',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: quantity > 1
                            ? () => onQuantityChanged(quantity - 1)
                            : null,
                      ),
                      Text('$quantity'),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => onQuantityChanged(quantity + 1),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Remove',
            ),
          ],
        ),
      ),
    );
  }
}
