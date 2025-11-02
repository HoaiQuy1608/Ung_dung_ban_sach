import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/notification_model.dart';

class NotificationProvider with ChangeNotifier {
  final DatabaseReference _notificationsRef = FirebaseDatabase.instance.ref(
    'notifications',
  );

  List<NotificationItem> _notifications = [];
  List<NotificationItem> get notifications => _notifications;

  void fetchNotifications(String userId) {
    _notificationsRef.orderByChild('userId').equalTo(userId).onValue.listen((
      event,
    ) {
      final snapshot = event.snapshot;
      if (snapshot.exists && snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        final List<NotificationItem> loadedItems = [];
        data.forEach((key, itemData) {
          loadedItems.add(NotificationItem.fromSnapshot(snapshot.child(key)));
        });
        loadedItems.sort((a, b) => b.time.compareTo(a.time));
        _notifications = loadedItems;
      } else {
        _notifications = [];
      }
      notifyListeners();
    });
  }
}
