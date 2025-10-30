import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/order.dart';
import '../models/cart_model.dart';

class OrderProvider with ChangeNotifier {
  final List<Order> _orders = [];

  List<Order> get orders => _orders;

  void addOrder({
    required String userId,
    required double totalAmount,
    required List<CartItem> items,
    required String name,
    required String phone,
    required String address,
  }) {
    final newOrder = Order(
      orderId: DateTime.now().toIso8601String(),
      userId: userId,
      totalAmount: totalAmount,
      items: items,
      name: name,
      phone: phone,
      address: address,
      orderDate: DateTime.now(),
    );
    _orders.insert(0, newOrder);
    notifyListeners();
  }

  String formatDate(DateTime date) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');
    return formatter.format(date);
  }
}
