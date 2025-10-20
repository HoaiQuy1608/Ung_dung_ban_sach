import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ungdungbansach/models/notification_model.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  // Dữ liệu giả (mock data) cho danh sách thông báo
  final List<NotificationItem> _mockNotifications = const [
    NotificationItem(
      icon: Icons.local_offer,
      title: 'Khuyến mãi Flash Sale!',
      message: 'Giảm 40% cho các sách Bán Chạy nhất trong 48h.',
      time: '2h trước',
    ),
    NotificationItem(
      icon: Icons.local_shipping,
      title: 'Đơn hàng đã được Giao',
      message: 'Đơn hàng #1245 đã được chuyển tới đơn vị vận chuyển.',
      time: '1 ngày trước',
    ),
    NotificationItem(
      icon: Icons.new_releases,
      title: 'Sách mới về',
      message: 'Kiểm tra các sách lập trình mới về hôm nay.',
      time: '3 ngày trước',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Lấy padding trên cùng để nội dung không bị dính vào Status Bar
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      // SỬA CHỮA LỚN: Sử dụng AppBar trống rỗng để tránh tiêu đề trùng lặp
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(title: const SizedBox()),
      ),
      body: _mockNotifications.isEmpty
          ? const Center(child: Text('Không có thông báo mới.'))
          : ListView.separated(
              // Thêm padding động để nội dung bắt đầu dưới Status Bar
              padding: EdgeInsets.fromLTRB(16.0, topPadding + 10, 16.0, 16.0),
              itemCount: _mockNotifications.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, indent: 60),
              itemBuilder: (context, index) {
                final notification = _mockNotifications[index];

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                    child: Icon(
                      notification.icon,
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
                    notification.time,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Xem chi tiết: ${notification.title}'),
                      ),
                    );
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  tileColor: Theme.of(context).cardColor,
                );
              },
            ),
    );
  }
}
