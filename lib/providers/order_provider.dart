import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/order.dart';
import '../models/cart_model.dart';

class OrderProvider with ChangeNotifier {
  final DatabaseReference _ordersRef = FirebaseDatabase.instance.ref('orders');

  List<Order> _orders = [];
  List<Order> get orders => _orders;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void fetchOrders(String userId) {
    _ordersRef.orderByChild('userId').equalTo(userId).onValue.listen((event) {
      final snapshot = event.snapshot;
      if (snapshot.exists && snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        final List<Order> loadedOrders = [];
        data.forEach((key, orderData) {
          final orderSnapshot = snapshot.child(key);
          loadedOrders.add(Order.fromSnapshot(orderSnapshot));
        });
        loadedOrders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
        _orders = loadedOrders;
      } else {
        _orders = [];
      }
      notifyListeners();
    });
  }

  Future<void> addOrder({
    required String userId,
    required double totalAmount,
    required List<CartItem> items,
    required String name,
    required String phone,
    required String address,
  }) async {
    final newOrder = Order(
      orderId: '',
      userId: userId,
      totalAmount: totalAmount,
      items: items,
      name: name,
      phone: phone,
      address: address,
      orderDate: DateTime.now(),
    );

    try {
      await _ordersRef.push().set(newOrder.toMap());
    } catch (error) {
      print('Lỗi khi lưu đơn hàng: $error');
      // Ném lỗi ra để UI (CheckoutScreen) bắt được
      rethrow;
    }
  }

  String formatDate(DateTime date) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');
    return formatter.format(date);
  }
}
