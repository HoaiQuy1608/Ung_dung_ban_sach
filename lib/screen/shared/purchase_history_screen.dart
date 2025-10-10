import 'package:flutter/material.dart';

class PurchaseHistoryScreen extends StatelessWidget {
  final bool isAdmin;

  const PurchaseHistoryScreen({super.key, this.isAdmin = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isAdmin ? 'Lịch sử mua hàng (Admin)' : 'Lịch sử mua hàng'),
        backgroundColor: isAdmin ? Colors.redAccent : Colors.blue,
      ),
      body: ListView.builder(
        itemCount: 10, // ví dụ dữ liệu giả
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Đơn hàng #$index'),
            subtitle: Text('Ngày: 01/01/2025'),
            trailing: isAdmin
                ? IconButton(
                    icon: const Icon(Icons.info),
                    onPressed: () {
                      // admin có thể xem chi tiết
                    },
                  )
                : null,
          );
        },
      ),
    );
  }
}
