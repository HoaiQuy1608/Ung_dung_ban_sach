import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class AdminCategory extends StatefulWidget {
  const AdminCategory({Key? key}) : super(key: key);

  @override
  State<AdminCategory> createState() => _AdminCategoryState();
}

class _AdminCategoryState extends State<AdminCategory> {
  late DatabaseReference _dbRef;
  List<Map<String, dynamic>> categories = [];

  @override
  void initState() {
    super.initState();
    _dbRef = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: 'https://book-store-app-66820-default-rtdb.firebaseio.com',
    ).ref().child('categories');

    _listenToCategories();
  }

  void _listenToCategories() {
    _dbRef.onValue.listen((event) {
      final snapshotValue = event.snapshot.value;
      List<Map<String, dynamic>> newList = [];

      if (snapshotValue != null) {
        if (snapshotValue is Map) {
          newList = snapshotValue.entries.map((e) {
            final value = e.value;
            return {
              'id': e.key,
              'name': (value is Map && value['name'] != null)
                  ? value['name'].toString()
                  : 'Không rõ tên',
            };
          }).toList();
        } else if (snapshotValue is List) {
          for (int i = 0; i < snapshotValue.length; i++) {
            final item = snapshotValue[i];
            if (item != null && item is Map && item['name'] != null) {
              newList.add({'id': i.toString(), 'name': item['name']});
            }
          }
        }
      }

      if (mounted) {
        setState(() {
          categories = newList;
        });
      }
    }, onError: (error) {
      debugPrint("❌ Lỗi khi lắng nghe dữ liệu: $error");
    });
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
          onPressed: () {},
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
                      leading:
                          const Icon(Icons.category, color: Colors.deepPurple),
                      title: Text(item['name']),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
