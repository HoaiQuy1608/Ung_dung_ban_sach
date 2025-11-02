import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';
import '../providers/auth_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final String? userId = authProvider.currentUser?.id;
    if (userId != null) {
      Provider.of<NotificationProvider>(
        context,
        listen: false,
      ).fetchNotifications(userId);
    }
  }

  IconData _getIcon(String iconType) {
    switch (iconType) {
      case 'offer':
        return Icons.local_offer;
      case 'shipping':
        return Icons.local_shipping;
      case 'success':
        return Icons.check_circle;
      default:
        return Icons.notifications;
    }
  }

  String _formatTime(DateTime time) {
    return DateFormat('dd/MM/yyyy HH:mm').format(time);
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(title: const SizedBox()),
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          final notifications = provider.notifications;
          return notifications.isEmpty
              ? const Center(child: Text('Không có thông báo mới.'))
              : ListView.separated(
                  padding: EdgeInsets.fromLTRB(
                    16.0,
                    topPadding + 10,
                    16.0,
                    16.0,
                  ),
                  itemCount: notifications.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1, indent: 60),
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.1),
                        child: Icon(
                          _getIcon(notification.iconType),
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      title: Text(
                        notification.title,
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      subtitle: Text(
                        notification.message,
                        style: GoogleFonts.roboto(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      trailing: Text(
                        _formatTime(notification.time),
                        style: const TextStyle(color: Colors.grey),
                      ),
                      onTap: () {},
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      tileColor: Theme.of(context).cardColor,
                    );
                  },
                );
        },
      ),
    );
  }
}
