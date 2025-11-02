import 'package:firebase_database/firebase_database.dart';

class NotificationItem {
  final String id;
  final String userId;
  final String iconType;
  final String title;
  final String message;
  final DateTime time;
  final bool isRead;

  NotificationItem({
    required this.id,
    required this.userId,
    required this.iconType,
    required this.title,
    required this.message,
    required this.time,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'iconType': iconType,
      'title': title,
      'message': message,
      'time': ServerValue.timestamp,
      'isRead': isRead,
    };
  }

  factory NotificationItem.fromSnapshot(DataSnapshot snapshot) {
    final data = snapshot.value as Map<dynamic, dynamic>? ?? {};
    return NotificationItem(
      id: snapshot.key ?? '',
      userId: data['userId'] as String? ?? '',
      iconType: data['iconType'] as String? ?? 'default',
      title: data['title'] as String? ?? '',
      message: data['message'] as String? ?? '',
      time: DateTime.fromMillisecondsSinceEpoch(data['time'] as int? ?? 0),
      isRead: data['isRead'] as bool? ?? false,
    );
  }
}
