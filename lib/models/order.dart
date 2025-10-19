import 'cart_model.dart';

class Order {
  final String orderId;
  final String userId;
  final double totalAmount;
  final List<CartItem> items;

  // Thông tin giao hàng
  final String name;
  final String phone;
  final String address;

  // Trạng thái đơn hàng (Mô phỏng)
  final String status;
  final DateTime orderDate;

  Order({
    required this.orderId,
    required this.userId,
    required this.totalAmount,
    required this.items,
    required this.name,
    required this.phone,
    required this.address,
    this.status = 'Pending',
    required this.orderDate,
  });
}
