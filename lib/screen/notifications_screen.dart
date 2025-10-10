import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _Notif(
        icon: Icons.local_offer,
        title: 'Flash Sale!',
        message: 'Up to 40% off on bestsellers',
        time: '2h',
      ),
      _Notif(
        icon: Icons.local_shipping,
        title: 'Order Shipped',
        message: 'Your order #1245 is on the way',
        time: '1d',
      ),
      _Notif(
        icon: Icons.new_releases,
        title: 'New Arrivals',
        message: 'Check out the latest programming books',
        time: '3d',
      ),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemBuilder: (context, index) {
          final it = items[index];
          return ListTile(
            leading: CircleAvatar(child: Icon(it.icon)),
            title: Text(
              it.title,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(it.message),
            trailing: Text(it.time, style: const TextStyle(color: Colors.grey)),
            onTap: () {},
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            tileColor: Theme.of(context).cardColor,
          );
        },
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemCount: items.length,
      ),
    );
  }
}

class _Notif {
  final IconData icon;
  final String title;
  final String message;
  final String time;
  _Notif({
    required this.icon,
    required this.title,
    required this.message,
    required this.time,
  });
}
