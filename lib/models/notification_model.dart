import 'package:flutter/material.dart';

class NotificationItem {
  final IconData icon;
  final String title;
  final String message;
  final String time;

  const NotificationItem({
    required this.icon,
    required this.title,
    required this.message,
    required this.time,
  });
}
