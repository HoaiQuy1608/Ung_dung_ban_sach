// lib/providers/order_provider.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import '../models/order.dart';
import '../models/cart_model.dart';

class OrderProvider with ChangeNotifier {
  final DatabaseReference _ordersRef = FirebaseDatabase.instance.ref('orders');
  final DatabaseReference _notificationsRef = FirebaseDatabase.instance.ref(
    'notifications',
  );
  final DatabaseReference _booksRef = FirebaseDatabase.instance.ref('books');

  List<Order> _orders = [];
  bool _isLoading = false;

  StreamSubscription<DatabaseEvent>? _userOrdersSub;
  StreamSubscription<DatabaseEvent>? _allOrdersSub;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;

  // ------------------ Fetch (one-time) ------------------
  Future<void> fetchOrders(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final snap = await _ordersRef
          .orderByChild('userId')
          .equalTo(userId)
          .get();
      final List<Order> loaded = [];
      for (final child in snap.children) loaded.add(Order.fromSnapshot(child));
      _orders = loaded.reversed.toList();
    } catch (e, st) {
      debugPrint('fetchOrders error: $e\n$st');
      _orders = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllOrders() async {
    try {
      _isLoading = true;
      notifyListeners();

      final snap = await _ordersRef.get();
      final List<Order> loaded = [];
      for (final child in snap.children) loaded.add(Order.fromSnapshot(child));
      _orders = loaded.reversed.toList();
    } catch (e, st) {
      debugPrint('fetchAllOrders error: $e\n$st');
      _orders = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ------------------ Realtime listeners ------------------
  void startListenUserOrders(String userId) {
    _userOrdersSub?.cancel();
    _userOrdersSub = _ordersRef
        .orderByChild('userId')
        .equalTo(userId)
        .onValue
        .listen((event) {
          final snapshot = event.snapshot;
          if (snapshot.exists && snapshot.value != null) {
            final List<Order> loaded = [];
            for (final child in snapshot.children)
              loaded.add(Order.fromSnapshot(child));
            _orders = loaded.reversed.toList();
          } else {
            _orders = [];
          }
          notifyListeners();
        }, onError: (err) => debugPrint('startListenUserOrders err: $err'));
  }

  void startListenAllOrders() {
    _allOrdersSub?.cancel();
    _allOrdersSub = _ordersRef.onValue.listen((event) {
      final snapshot = event.snapshot;
      if (snapshot.exists && snapshot.value != null) {
        final List<Order> loaded = [];
        for (final child in snapshot.children)
          loaded.add(Order.fromSnapshot(child));
        _orders = loaded.reversed.toList();
      } else {
        _orders = [];
      }
      notifyListeners();
    }, onError: (err) => debugPrint('startListenAllOrders err: $err'));
  }

  Future<void> stopAllListeners() async {
    await _userOrdersSub?.cancel();
    _userOrdersSub = null;
    await _allOrdersSub?.cancel();
    _allOrdersSub = null;
  }

  Future<void> addOrder({
    required String userId,
    required double totalAmount,
    required List<CartItem> items,
    required String name,
    required String phone,
    required String address,
  }) async {
    // 1. check stock first
    final Map<String, int> currentStocks = {};
    for (var item in items) {
      final snap = await _booksRef.child(item.book.id).child('stock').get();
      final stock = snap.value as int? ?? 0;
      if (stock < item.quantity) {
        throw Exception('Sách "${item.book.title}" chỉ còn $stock cuốn!');
      }
      currentStocks[item.book.id] = stock;
    }

    // 2. build multiPath update
    final Map<String, dynamic> multiPath = {};
    final newOrderKey = _ordersRef.push().key;
    if (newOrderKey == null) throw Exception('Không thể tạo Order key');

    final newOrder = Order(
      orderId: newOrderKey,
      userId: userId,
      totalAmount: totalAmount,
      items: items,
      name: name,
      phone: phone,
      address: address,
      status: 'Đang chờ',
      orderDate: DateTime.now(),
    );

    multiPath['/orders/$newOrderKey'] = newOrder.toMap();

    // decrement stock for each book
    for (var item in items) {
      final newStock = currentStocks[item.book.id]! - item.quantity;
      multiPath['/books/${item.book.id}/stock'] = newStock;
    }

    // notification
    final notifKey = _notificationsRef.push().key;
    if (notifKey != null) {
      multiPath['/notifications/$notifKey'] = {
        'userId': userId,
        'title': 'Đã nhận đơn hàng!',
        'message': 'Chúng tôi đã nhận đơn hàng của bạn và đang chờ xử lý.',
        'timestamp': ServerValue.timestamp,
        'isRead': false,
      };
    }

    // 3. update atomically
    try {
      await FirebaseDatabase.instance.ref().update(multiPath);
      // reflect locally (prepend)
      _orders.insert(0, newOrder);
      notifyListeners();
    } catch (e, st) {
      debugPrint('addOrder atomic update error: $e\n$st');
      rethrow;
    }
  }

  // ------------------ Update Status (admin) ------------------
  /// Updates status and sends notification. If status == 'Cancelled' and previous != 'Cancelled',
  /// it will restock items (via transactions).
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      final orderSnap = await _ordersRef.child(orderId).get();
      if (!orderSnap.exists)
        throw Exception('Không tìm thấy đơn hàng $orderId');
      final orderData = orderSnap.value as Map<dynamic, dynamic>;
      final userId = orderData['userId'] as String? ?? '';
      final currentStatus = orderData['status'] as String? ?? 'Đang chờ';

      final Map<String, dynamic> multiPath = {};
      multiPath['/orders/$orderId/status'] = newStatus;

      if (newStatus == 'Đã hủy' && currentStatus != 'Đã hủy') {
        // restock each item via transactions (to be safe in concurrent env)
        final itemsList = (orderData['items'] as List<dynamic>? ?? []);
        for (var itemMap in itemsList) {
          final ci = CartItem.fromMap(itemMap as Map<dynamic, dynamic>);
          final bookId = ci.book.id;
          final qty = ci.quantity;
          final stockRef = _booksRef.child(bookId).child('stock');
          final trx = await stockRef.runTransaction((current) {
            final prev = (current as int? ?? 0);
            return Transaction.success(prev + qty);
          });
          if (!trx.committed) {
            debugPrint('Restock failed for $bookId');
          }
        }
      }

      // prepare notification content
      String title = 'Đơn hàng của bạn đã được cập nhật';
      String message =
          'Đơn #${orderId.substring(orderId.length - 6)} đã đổi trạng thái thành $newStatus.';
      String iconType = 'default';
      switch (newStatus) {
        case 'Đã xác nhận':
          title = 'Đơn hàng đã được Xác nhận!';
          message = 'Shop đang chuẩn bị hàng của bạn. Cảm ơn bạn!';
          iconType = 'success';
          break;
        case 'Đang giao':
          title = 'Đơn hàng đang Giao!';
          message = 'Đơn hàng của bạn đang trên đường tới bạn.';
          iconType = 'shipping';
          break;
        case 'Đã giao':
          title = 'Đã giao hàng Thành công!';
          message = 'Cảm ơn bạn đã mua hàng tại cửa hàng!';
          iconType = 'success';
          break;
        case 'Đã hủy':
          title = 'Đơn hàng đã bị Hủy.';
          message = 'Rất tiếc, đơn hàng của bạn đã bị hủy.';
          iconType = 'offer';
          break;
      }

      // apply status update
      await FirebaseDatabase.instance.ref().update(multiPath);

      // send notification
      final notifKey = _notificationsRef.push().key;
      if (notifKey != null) {
        await _notificationsRef.child(notifKey).set({
          'userId': userId,
          'title': title,
          'message': message,
          'iconType': iconType,
          'timestamp': ServerValue.timestamp,
          'isRead': false,
        });
      }

      // update local cache if present
      final idx = _orders.indexWhere((o) => o.orderId == orderId);
      if (idx != -1) {
        final old = _orders[idx];
        _orders[idx] = Order(
          orderId: old.orderId,
          userId: old.userId,
          totalAmount: old.totalAmount,
          items: old.items,
          name: old.name,
          phone: old.phone,
          address: old.address,
          status: newStatus,
          orderDate: old.orderDate,
        );
        notifyListeners();
      }
    } catch (e, st) {
      debugPrint('updateOrderStatus error: $e\n$st');
      rethrow;
    }
  }

  // ------------------ User cancel with 30-minute rule ------------------
  Future<void> userCancelOrder(String orderId, String userId) async {
    final orderSnap = await _ordersRef.child(orderId).get();
    if (!orderSnap.exists) throw Exception('Không tìm thấy đơn hàng');
    final data = orderSnap.value as Map<dynamic, dynamic>;
    if ((data['userId'] as String? ?? '') != userId)
      throw Exception('Bạn không có quyền hủy đơn hàng này');
    final status = data['status'] as String? ?? 'Đang chờ';
    if (status != 'Đang chờ')
      throw Exception(
        'Không thể hủy đơn hàng đã được xác nhận hoặc đang giao!',
      );
    final orderTimeMillis = data['orderDate'] as int? ?? 0;
    final orderTime = DateTime.fromMillisecondsSinceEpoch(orderTimeMillis);
    final passed = DateTime.now().difference(orderTime).inMinutes;
    if (passed > 30)
      throw Exception('Đã quá 30 phút, không thể tự động hủy đơn hàng!');

    await updateOrderStatus(orderId, 'Đã hủy');
  }

  // ------------------ Helpers ------------------
  String formatDate(DateTime date) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');
    return formatter.format(date);
  }

  List<Order> filterOrdersByStatus(String status) {
    if (status.toLowerCase() == 'all') return List.unmodifiable(_orders);
    return _orders
        .where((o) => o.status.toLowerCase() == status.toLowerCase())
        .toList();
  }

  Order? findById(String id) {
    try {
      return _orders.firstWhere((o) => o.orderId == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> refresh({String? userId}) async {
    if (userId != null)
      await fetchOrders(userId);
    else
      await fetchAllOrders();
  }

  @override
  void dispose() {
    stopAllListeners();
    super.dispose();
  }
}
