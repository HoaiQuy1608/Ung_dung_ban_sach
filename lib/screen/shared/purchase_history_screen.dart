// lib/screen/shared/purchase_history_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/order_provider.dart';
import '/providers/cart_provider.dart';
import '/providers/auth_provider.dart';
import '/utils/app_theme.dart';
import '/models/order.dart';

class PurchaseHistoryScreen extends StatefulWidget {
  final bool isAdmin;
  const PurchaseHistoryScreen({Key? key, this.isAdmin = false})
    : super(key: key);

  @override
  State<PurchaseHistoryScreen> createState() => _PurchaseHistoryScreenState();
}

class _PurchaseHistoryScreenState extends State<PurchaseHistoryScreen> {
  @override
  void initState() {
    super.initState();
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    if (widget.isAdmin) {
      orderProvider.startListenAllOrders();
    } else {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final String? userId = authProvider.currentUser?.id;
      if (userId != null) orderProvider.startListenUserOrders(userId);
    }
  }

  Future<void> _confirmCancelOrder(BuildContext context, Order order) async {
    final bool? didConfirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Xác nhận Hủy Đơn'),
          content: Text(
            'Bạn có chắc chắn muốn hủy đơn hàng #${order.orderId.substring(order.orderId.length - 6)} không?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Không'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(foregroundColor: AppColors.errorRed),
              child: const Text('Hủy Đơn'),
            ),
          ],
        );
      },
    );
    if (didConfirm == true && context.mounted) {
      await _handleUserCancelOrder(order);
    }
  }

  Future<void> _handleUserCancelOrder(Order order) async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser?.id;
    if (userId == null) return;
    try {
      await orderProvider.userCancelOrder(order.orderId, userId);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đã hủy đơn hàng #${order.orderId.substring(order.orderId.length - 6)}',
          ),
          backgroundColor: AppColors.successGreen,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi hủy: $e'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: widget.isAdmin
          ? AppBar(title: const Text('Quản lý đơn hàng'))
          : AppBar(title: const Text('Lịch sử mua hàng')),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, _) {
          final orders = orderProvider.orders;
          if (orderProvider.isLoading)
            return const Center(child: CircularProgressIndicator());
          if (orders.isEmpty)
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 10),
                  Text('Không có đơn hàng nào.'),
                ],
              ),
            );

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final formattedDate = orderProvider.formatDate(order.orderDate);
              final formattedTotal = cartProvider.formatPrice(
                order.totalAmount,
              );
              return Card(
                margin: const EdgeInsets.only(bottom: 15),
                child: ExpansionTile(
                  initiallyExpanded: index == 0,
                  title: Text(
                    widget.isAdmin
                        ? 'ĐH #${order.orderId.substring(order.orderId.length - 6)} - ${order.name}'
                        : 'Đơn hàng #${order.orderId.substring(order.orderId.length - 6)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Ngày đặt: $formattedDate'),
                  trailing: Text(
                    formattedTotal,
                    style: TextStyle(
                      color: colorScheme.tertiary,
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
                              'SĐT: ${order.phone}',
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
                                          style: const TextStyle(fontSize: 14),
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
                          const Divider(),
                          widget.isAdmin
                              ? _buildAdminStatusSelector(
                                  context,
                                  order,
                                  orderProvider,
                                )
                              : _buildUserStatusView(context, order),
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

  Widget _buildUserStatusView(BuildContext context, Order order) {
    final bool canCancel = order.status == 'Pending';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trạng thái:',
              style: TextStyle(color: Theme.of(context).colorScheme.outline),
            ),
            Text(
              order.status,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: order.status == 'Cancelled'
                    ? AppColors.errorRed
                    : AppColors.successGreenDark,
              ),
            ),
          ],
        ),
        if (canCancel)
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.errorRed),
            onPressed: () => _confirmCancelOrder(context, order),
            child: const Text('Hủy đơn hàng'),
          ),
      ],
    );
  }

  Widget _buildAdminStatusSelector(
    BuildContext context,
    Order order,
    OrderProvider orderProvider,
  ) {
    final List<String> statuses = [
      'Pending',
      'Confirmed',
      'Shipping',
      'Delivered',
      'Cancelled',
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Quản lý Trạng thái:'),
        DropdownButton<String>(
          value: order.status,
          items: statuses
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          onChanged: (newStatus) {
            if (newStatus != null && newStatus != order.status) {
              orderProvider.updateOrderStatus(order.orderId, newStatus);
            }
          },
        ),
      ],
    );
  }
}
