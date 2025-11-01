import 'package:firebase_database/firebase_database.dart';
import 'cart_model.dart';

class Order {
  final String orderId;
  final String userId;
  final double totalAmount;
  final List<CartItem> items;
  final String name;
  final String phone;
  final String address;
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

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'totalAmount': totalAmount,
      'items': items.map((item) => item.toMap()).toList(),
      'name': name,
      'phone': phone,
      'address': address,
      'status': status,
      'orderDate': ServerValue.timestamp,
    };
  }

  factory Order.fromSnapshot(DataSnapshot snapshot) {
    final data = snapshot.value as Map<dynamic, dynamic>? ?? {};

    return Order(
      orderId: snapshot.key ?? '',
      userId: data['userId'] as String? ?? '',
      totalAmount: (data['totalAmount'] as num? ?? 0.0).toDouble(),
      orderDate: DateTime.fromMillisecondsSinceEpoch(
        data['orderDate'] as int? ?? 0,
      ),
      items: (data['items'] as List<dynamic>? ?? [])
          .map((itemMap) => CartItem.fromMap(itemMap as Map<dynamic, dynamic>))
          .toList(),
      name: data['name'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      address: data['address'] as String? ?? '',
      status: data['status'] as String? ?? 'Pending',
    );
  }
}
