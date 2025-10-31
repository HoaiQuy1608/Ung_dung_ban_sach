import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:toastification/toastification.dart';

class AdminCategory extends StatefulWidget {
  const AdminCategory({Key? key}) : super(key: key);

  @override
  State<AdminCategory> createState() => _AdminCategoryState();
}

class _AdminCategoryState extends State<AdminCategory> {
  final DatabaseReference _dbRef =
      FirebaseDatabase.instance.ref().child('categories');

  List<Map<String, dynamic>> categories = [];

  @override
  void initState() {
    super.initState();
    _ensureCategoryNodeExists(); // ✅ Kiểm tra & tạo nhánh nếu chưa có
    _listenToCategories();       // 👂 Lắng nghe dữ liệu thay đổi
  }

  // 🧱 Hàm đảm bảo luôn có nhánh "categories" trong DB
  void _ensureCategoryNodeExists() async {
    final snapshot = await _dbRef.get();
    if (!snapshot.exists) {
      await _dbRef.set({}); // Tạo nhánh rỗng
      debugPrint("✅ Đã tạo nhánh 'categories' rỗng trong Firebase");
    }
  }

  // 👂 Lắng nghe dữ liệu từ Firebase theo thời gian thực
  void _listenToCategories() {
    _dbRef.onValue.listen((event) {
      final snapshotValue = event.snapshot.value;

      if (snapshotValue == null) {
        // Không có dữ liệu
        setState(() => categories = []);
        return;
      }

      if (snapshotValue is Map) {
        // Dữ liệu đúng định dạng
        final newList = snapshotValue.entries.map((e) {
          final value = e.value;
          if (value is Map && value['name'] != null) {
            return {
              'id': e.key,
              'name': value['name'].toString(),
            };
          } else {
            return {
              'id': e.key,
              'name': 'Không rõ tên',
            };
          }
        }).toList();

        setState(() => categories = newList);
      } else if (snapshotValue is List) {
        // Dữ liệu bị ghi sai dạng (List thay vì Map)
        final newList = <Map<String, dynamic>>[];
        for (int i = 0; i < snapshotValue.length; i++) {
          final item = snapshotValue[i];
          if (item != null && item is Map && item['name'] != null) {
            newList.add({'id': i.toString(), 'name': item['name']});
          }
        }
        setState(() => categories = newList);
      } else {
        setState(() => categories = []);
      }
    });
  }

  // 🧩 Dialog thêm / sửa thể loại
  void _showCategoryDialog({String? currentName, String? id}) {
    final controller = TextEditingController(text: currentName ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(id == null ? 'Thêm thể loại' : 'Chỉnh sửa thể loại'),
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
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newName = controller.text.trim();
                if (newName.isEmpty) return;

                if (id == null) {
                  // ➕ Thêm mới
                  await _dbRef.push().set({'name': newName});
                  toastification.show(
                    context: context,
                    title: const Text('Thêm thể loại thành công'),
                    type: ToastificationType.success,
                    autoCloseDuration: const Duration(seconds: 2),
                  );
                } else {
                  // ✏️ Cập nhật
                  await _dbRef.child(id).update({'name': newName});
                  toastification.show(
                    context: context,
                    title: const Text('Cập nhật thể loại thành công'),
                    type: ToastificationType.success,
                    autoCloseDuration: const Duration(seconds: 2),
                  );
                }

                Navigator.pop(context);
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  // 🗑️ Xóa thể loại
  void _deleteCategory(String id, String name) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xác nhận'),
          content: Text('Bạn có chắc muốn xóa thể loại "$name"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _dbRef.child(id).remove();
                Navigator.pop(context);
                toastification.show(
                  context: context,
                  title: const Text('Đã xóa thể loại'),
                  type: ToastificationType.info,
                  autoCloseDuration: const Duration(seconds: 2),
                );
              },
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }

  // 🖥️ Giao diện hiển thị danh sách thể loại
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
        body: categories.isEmpty
            ? const Center(child: Text('Chưa có thể loại nào'))
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final item = categories[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.category,
                          color: Colors.deepPurple),
                      title: Text(item['name']),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showCategoryDialog(
                              currentName: item['name'],
                              id: item['id'],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () =>
                                _deleteCategory(item['id'], item['name']),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
