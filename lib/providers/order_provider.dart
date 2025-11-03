import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/order.dart';
import '../models/cart_model.dart';
import '../models/notification_model.dart';
import '../models/book_model.dart';

class OrderProvider with ChangeNotifier {
  final DatabaseReference _ordersRef = FirebaseDatabase.instance.ref('orders');
  final DatabaseReference _notificationsRef = FirebaseDatabase.instance.ref(
    'notifications',
  );
  final DatabaseReference _booksRef = FirebaseDatabase.instance.ref('books');

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

  void fetchAllOrders() {
    _ordersRef.onValue.listen((event) {
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
    Map<String, int> currentStocks = {};
    for (var item in items) {
      final snapshot = await _booksRef.child(item.book.id).child('stock').get();
      final stock = snapshot.value as int? ?? 0;
      if (stock < item.quantity) {
        throw Exception('Sách "${item.book.title}" chỉ còn $stock cuốn!');
      }
      currentStocks[item.book.id] = stock;
    }

    final Map<String, dynamic> multiPathUpdate = {};
    final newOrderKey = _ordersRef.push().key;
    final newOrder = Order(
      orderId: newOrderKey!,
      userId: userId,
      totalAmount: totalAmount,
      items: items,
      name: name,
      phone: phone,
      address: address,
      orderDate: DateTime.now(),
      status: 'Pending',
    );
    multiPathUpdate['/orders/$newOrderKey'] = newOrder.toMap();
    for (var item in items) {
      final newStock = currentStocks[item.book.id]! - item.quantity;
      multiPathUpdate['/books/${item.book.id}/stock'] = newStock;
    }
    final notification = NotificationItem(
      id: '',
      userId: userId,
      iconType: 'success',
      title: 'Đã nhận đơn hàng!',
      message: 'Chúng tôi đã nhận được đơn hàng của bạn và đang chờ xử lý.',
      time: DateTime.now(),
    );
    final newNotifKey = _notificationsRef.push().key;
    multiPathUpdate['/notifications/$newNotifKey'] = notification.toMap();

    try {
      await FirebaseDatabase.instance.ref().update(multiPathUpdate);
    } catch (error) {
      print('Lỗi khi lưu đơn hàng (atomic): $error');
      rethrow;
    }
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      // Lấy thông tin đơn hàng
      final orderSnapshot = await _ordersRef.child(orderId).get();
      if (!orderSnapshot.exists) {
        throw Exception('Không tìm thấy đơn hàng');
      }
      final orderData = orderSnapshot.value as Map<dynamic, dynamic>;
      final userId = orderData['userId'] as String? ?? '';
      final currentStatus = orderData['status'] as String? ?? 'Pending';

      if (userId.isEmpty) {
        throw Exception('Đơn hàng $orderId bị thiếu userId');
      }

      final Map<String, dynamic> multiPathUpdate = {};

      multiPathUpdate['/orders/$orderId/status'] = newStatus;

      if (newStatus == 'Cancelled' && currentStatus != 'Cancelled') {
        final itemsList = (orderData['items'] as List<dynamic>? ?? []);

        for (var itemMap in itemsList) {
          final item = CartItem.fromMap(itemMap as Map<dynamic, dynamic>);
          final bookId = item.book.id;
          final quantityToRestock = item.quantity;
          final stockRef = _booksRef.child(bookId).child('stock');
          final transactionResult = await stockRef.runTransaction((
            Object? currentStock,
          ) {
            final stock = (currentStock as int? ?? 0);
            return Transaction.success(stock + quantityToRestock);
          });

          if (!transactionResult.committed) {
            print('Hoàn kho thất bại cho sách $bookId');
          }
        }
      }
      String title = 'Đơn hàng của bạn đã được cập nhật';
      String message =
          'Đơn hàng #${orderId.substring(orderId.length - 6)} đã đổi trạng thái thành $newStatus.';
      String iconType = 'default';

      switch (newStatus) {
        case 'Confirmed':
          title = 'Đơn hàng đã được Xác nhận!';
          message = 'Shop đang chuẩn bị hàng của bạn. Cảm ơn bạn!';
          iconType = 'success';
          break;
        case 'Shipping':
          title = 'Đơn hàng đang Giao!';
          message = 'Đơn hàng của bạn đang trên đường tới bạn.';
          iconType = 'shipping';
          break;
        case 'Delivered':
          title = 'Đã giao hàng Thành công!';
          message = 'Cảm ơn bạn đã mua hàng tại Bookify!';
          iconType = 'success';
          break;
        case 'Cancelled':
          title = 'Đơn hàng đã bị Hủy.';
          message = 'Rất tiếc, đơn hàng của bạn đã bị hủy.';
          iconType = 'offer';
          break;
      }
      final notification = NotificationItem(
        id: '',
        userId: userId,
        iconType: iconType,
        title: title,
        message: message,
        time: DateTime.now(),
      );
      final newNotifKey = _notificationsRef.push().key;
      multiPathUpdate['/notifications/$newNotifKey'] = notification.toMap();

      await FirebaseDatabase.instance.ref().update(multiPathUpdate);
    } catch (e) {
      print('Lỗi khi cập nhật trạng thái đơn hàng: $e');
      rethrow;
    }
  }

  Future<void> userCancelOrder(String orderId, String userId) async {
    final orderSnapshot = await _ordersRef.child(orderId).get();
    if (!orderSnapshot.exists) {
      throw Exception('Không tìm thấy đơn hàng');
    }

    final orderData = orderSnapshot.value as Map<dynamic, dynamic>;

    if (orderData['userId'] != userId) {
      throw Exception('Bạn không có quyền hủy đơn hàng này');
    }

    if (orderData['status'] != 'Pending') {
      throw Exception(
        'Không thể hủy đơn hàng đã được xác nhận hoặc đang giao!',
      );
    }

    final orderTime = DateTime.fromMillisecondsSinceEpoch(
      orderData['orderDate'] as int? ?? 0,
    );
    final minutesPassed = DateTime.now().difference(orderTime).inMinutes;

    if (minutesPassed > 30) {
      throw Exception('Đã quá 30 phút, không thể tự động hủy đơn hàng!');
    }

    await updateOrderStatus(orderId, 'Cancelled');
  }

  String formatDate(DateTime date) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');
    return formatter.format(date);
  }
}
