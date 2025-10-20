import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ungdungbansach/widgets/cart_item_tile.dart';
import 'package:ungdungbansach/providers/cart_provider.dart';
import 'package:ungdungbansach/providers/auth_provider.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  // Hộp thoại xác nhận đặt hàng (UX)
  Future<bool> _confirmCheckout(BuildContext context, double total) async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final String formattedTotal = cartProvider.formatPrice(total);

    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Xác nhận Đặt hàng'),
            content: Text(
              'Bạn có chắc chắn muốn đặt đơn hàng trị giá $formattedTotal không?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text('Đặt hàng'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _handleCheckout(BuildContext context, CartProvider cartProvider) async {
    final total = cartProvider.totalPrice;
    final cartItems = cartProvider.items;

    if (cartItems.isEmpty) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (!authProvider.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng nhập để tiến hành thanh toán.'),
          backgroundColor: Colors.deepPurple,
        ),
      );
      return;
    }

    final confirmed = await _confirmCheckout(context, total);

    if (confirmed) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CheckoutScreen(
            itemsToBuy: cartItems,
            source: CheckoutSource.cart,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final colorScheme = Theme.of(context).colorScheme;
        final cartItems = cartProvider.items;
        final total = cartProvider.totalPrice;

        return Scaffold(
          // APPBAR GỌN GÀNG NHẤT: Không có chiều cao, không có tiêu đề.
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(0),
            child: AppBar(
              title: const SizedBox(),
              automaticallyImplyLeading: false,
            ),
          ),
          body: Column(
            children: [
              // TIÊU ĐỀ ĐÃ ĐƯỢC XÓA Ở ĐÂY!
              // Trước đó có một Padding chứa Row và Text('Giỏ Hàng...') đã bị xóa.

              // 1. Danh sách sản phẩm
              // Thêm padding cho nội dung để nó không bị dính vào Status Bar
              Expanded(
                child: cartItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              size: 80,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Giỏ hàng của bạn đang trống.',
                              style: GoogleFonts.nunito(fontSize: 18),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: EdgeInsets.fromLTRB(
                          12,
                          MediaQuery.of(context).padding.top + 10,
                          12,
                          12,
                        ),
                        itemCount: cartItems.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final line = cartItems[index];
                          return CartItemTile(
                            book: line.book,
                            quantity: line.quantity,
                            onQuantityChanged: (q) {
                              if (q > line.quantity) {
                                cartProvider.increaseQuantity(line.book.id);
                              } else if (q < line.quantity) {
                                cartProvider.decreaseQuantity(line.book.id);
                              }
                            },
                            onDelete: () =>
                                cartProvider.removeItem(line.book.id),
                          );
                        },
                      ),
              ),

              // 2. Khu vực Tổng tiền và Thanh toán
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
                            'Tổng tiền',
                            style: GoogleFonts.nunito(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            cartProvider.formatPrice(total),
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
                      onPressed: cartItems.isEmpty
                          ? null
                          : () => _handleCheckout(context, cartProvider),
                      icon: const Icon(Icons.payment),
                      label: const Text('Thanh toán'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
