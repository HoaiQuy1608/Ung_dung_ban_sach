import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:toastification/toastification.dart';
import '/models/category_model.dart'; // 👈 import model

class AdminCategory extends StatefulWidget {
  const AdminCategory({Key? key}) : super(key: key);

  @override
  State<AdminCategory> createState() => _AdminCategoryState();
}

class _AdminCategoryState extends State<AdminCategory> {
  late final DatabaseReference _dbRef;

  @override
  void initState() {
    super.initState();
    _dbRef = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: 'https://book-store-app-66820-default-rtdb.firebaseio.com',
    ).ref().child('categories');
  }

  // 🧾 Thêm / sửa thể loại
  void _showCategoryDialog({CategoryModel? category}) {
    final controller = TextEditingController(text: category?.name ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(category == null ? 'Thêm thể loại' : 'Chỉnh sửa thể loại'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Nhập tên thể loại',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () async {
                final newName = controller.text.trim();
                if (newName.isEmpty) return;

                try {
                  if (category == null) {
                    // Thêm mới
                    final newCat = CategoryModel(id: '', name: newName);
                    await _dbRef.push().set(newCat.toJson());
                    toastification.show(
                      context: context,
                      title: const Text('Thêm thể loại thành công'),
                      type: ToastificationType.success,
                      autoCloseDuration: const Duration(seconds: 2),
                    );
                  } else {
                    // Cập nhật
                    await _dbRef.child(category.id).update({'name': newName});
                    toastification.show(
                      context: context,
                      title: const Text('Cập nhật thể loại thành công'),
                      type: ToastificationType.success,
                      autoCloseDuration: const Duration(seconds: 2),
                    );
                  }
                } catch (e) {
                  debugPrint('❌ Lỗi khi lưu thể loại: $e');
                  toastification.show(
                    context: context,
                    title: const Text('Lỗi khi lưu thể loại'),
                    type: ToastificationType.error,
                    autoCloseDuration: const Duration(seconds: 2),
                  );
                }

                if (mounted) Navigator.pop(context);
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  // 🗑 Xóa thể loại
  void _deleteCategory(CategoryModel category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận'),
        content: Text('Bạn có chắc muốn xóa thể loại "${category.name}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              try {
                await _dbRef.child(category.id).remove();
                toastification.show(
                  context: context,
                  title: const Text('Đã xóa thể loại'),
                  type: ToastificationType.info,
                  autoCloseDuration: const Duration(seconds: 2),
                );
              } catch (e) {
                debugPrint('❌ Lỗi khi xóa thể loại: $e');
                toastification.show(
                  context: context,
                  title: const Text('Lỗi khi xóa thể loại'),
                  type: ToastificationType.error,
                  autoCloseDuration: const Duration(seconds: 2),
                );
              }
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Xóa'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quản lý thể loại sách'),
          backgroundColor: Colors.deepPurple,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showCategoryDialog(),
          backgroundColor: Colors.deepPurple,
          child: const Icon(Icons.add),
        ),
        body: StreamBuilder<DatabaseEvent>(
          stream: _dbRef.onValue,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Lỗi: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
              return const Center(child: Text('Chưa có thể loại nào'));
            }

            final raw = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
            final categories = raw.entries
                .map((e) => CategoryModel.fromJson(e.key, e.value))
                .toList();

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final item = categories[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.category, color: Colors.deepPurple),
                    title: Text(item.name),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showCategoryDialog(category: item),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteCategory(item),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
