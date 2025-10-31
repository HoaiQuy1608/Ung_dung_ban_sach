import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/order_provider.dart';
import '../providers/cart_provider.dart'; // Cần để format giá

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final orders = orderProvider.orders;

    return Scaffold(
      appBar: AppBar(title: const Text('Lịch Sử Đơn Hàng'), centerTitle: true),
      body: orders.isEmpty
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
                    'Bạn chưa có đơn hàng nào.',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[orders.length - 1 - index];
                final formattedDate = orderProvider.formatDate(order.orderDate);
                final formattedTotal = cartProvider.formatPrice(
                  order.totalAmount,
                );

                return Card(
                  margin: const EdgeInsets.only(bottom: 15),
                  child: ExpansionTile(
                    initiallyExpanded: index == 0,
                    tilePadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    title: Text(
                      'Đơn hàng #${order.orderId.substring(order.orderId.length - 4)}',
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
                      // Chi tiết sản phẩm trong đơn hàng
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: 10,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Địa chỉ: ${order.address}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const Divider(),
                            // Map qua danh sách sản phẩm đã mua
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
            ),
    );
  }
}
