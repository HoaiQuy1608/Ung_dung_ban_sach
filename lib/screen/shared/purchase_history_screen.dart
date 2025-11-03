import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/order_provider.dart';
import '/providers/cart_provider.dart';
import '/providers/auth_provider.dart';
import '/utils/app_theme.dart';
import '/models/order.dart';

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
      final String? userId = authProvider.currentUser?.id;
      if (userId != null) {
        orderProvider.fetchOrders(userId);
      }
    }
  }

  Future<void> _confirmCancelOrder(BuildContext context, Order order) async {
    final bool? didConfirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Xác nhận Hủy Đơn'),
          content: Text(
            'Bạn có chắc chắn muốn hủy đơn hàng #${order.orderId.substring(order.orderId.length - 6)} không?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(false), // Bấm "Không"
              child: const Text('Không'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.errorRed, // Dùng theme
              ),
              onPressed: () =>
                  Navigator.of(dialogContext).pop(true), // Bấm "Có, Hủy"
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
      // ⭐️ [SỬA] Xóa AppBar nếu là Admin (vì đã có AppBar chung)
      // Chỉ giữ lại AppBar cho User
      appBar: widget.isAdmin
          ? null
          : AppBar(
              title: const Text('Lịch sử mua hàng'),
              // ⭐️ [XÓA] Xóa màu, để AppBar tự nhận màu theo Theme
              // backgroundColor: widget.isAdmin ? Colors.redAccent : null,
            ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          final orders = orderProvider.orders;
          if (orderProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return orders.isEmpty
              ? const Center(
                  // ... (Phần UI trống giữ nguyên) ...
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
                          // ⭐️ [SỬA] Thêm tên nếu là Admin
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
                                // ⭐️ [SỬA] Chỉ hiển thị nếu là Admin
                                if (widget.isAdmin)
                                  Text(
                                    'SĐT: ${order.phone}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                Text(
                                  'Địa chỉ: ${order.address}',
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
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
                                const Divider(),
                                if (widget.isAdmin)
                                  _buildAdminStatusSelector(
                                    context,
                                    order,
                                    orderProvider,
                                  )
                                else
                                  _buildUserStatusView(context, order),
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
    bool canCancel = order.status == 'Pending';

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
    // (Code này giữ nguyên)
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
              .map(
                (status) =>
                    DropdownMenuItem(value: status, child: Text(status)),
              )
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
