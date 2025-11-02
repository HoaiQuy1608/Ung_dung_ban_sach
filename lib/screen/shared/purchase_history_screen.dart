import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/order_provider.dart';
import '/providers/cart_provider.dart';
import '/providers/auth_provider.dart';

// 1. Chuyển thành StatefulWidget
class PurchaseHistoryScreen extends StatefulWidget {
  final bool isAdmin;
  const PurchaseHistoryScreen({super.key, this.isAdmin = false});

  @override
  State<PurchaseHistoryScreen> createState() => _PurchaseHistoryScreenState();
}

class _PurchaseHistoryScreenState extends State<PurchaseHistoryScreen> {
  @override
  void initState() {
    super.initState();
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    if (widget.isAdmin) {
      orderProvider.fetchAllOrders();
    } else {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final String? userId = authProvider.currentUser?.id; // Dùng uid
      if (userId != null) {
        orderProvider.fetchOrders(userId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isAdmin ? 'Quản lý Đơn hàng' : 'Lịch sử mua hàng'),
        backgroundColor: widget.isAdmin ? Colors.redAccent : null,
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          final orders = orderProvider.orders;

          return orders.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 80,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Không có đơn hàng nào.',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    final formattedDate = orderProvider.formatDate(
                      order.orderDate,
                    );
                    final formattedTotal = cartProvider.formatPrice(
                      order.totalAmount,
                    );

                    return Card(
                      margin: const EdgeInsets.only(bottom: 15),
                      child: ExpansionTile(
                        initiallyExpanded: index == 0,
                        title: Text(
                          'Đơn hàng #${order.orderId.substring(order.orderId.length - 6)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('Ngày đặt: $formattedDate'),
                        trailing: Text(
                          formattedTotal,
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 16,
                              right: 16,
                              bottom: 10,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (widget.isAdmin)
                                  Text(
                                    'Người mua: ${order.name} - ${order.phone}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                Text(
                                  'Địa chỉ: ${order.address}',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                const Divider(),
                                ...order.items
                                    .map(
                                      (item) => Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 4.0,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                '${item.book.title} x ${item.quantity}',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              cartProvider.formatPrice(
                                                item.book.price * item.quantity,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
        },
      ),
    );
  }
}
