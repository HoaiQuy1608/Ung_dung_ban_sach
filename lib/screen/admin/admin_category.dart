import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class AdminCategory extends StatefulWidget {
  const AdminCategory({Key? key}) : super(key: key);

  @override
  State <AdminCategory> createState() => _AdminCategoryState();
}

class _AdminCategoryState extends State<AdminCategory> {
List<String> categories = [
  'Tiểu thuyết',
  'Kinh tế',
];

void _showCategoryDialog({String? currentName, int? index}){
  final TextEditingController controller = 
    TextEditingController(text: currentName ?? '');
  showDialog(
    context: context,
    builder: (context){
      return AlertDialog(
        title: Text(currentName == null ? 'Thêm thể loại' : 'Chỉnh sửa thể loại'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Nhập tên thể loại',
            border : OutlineInputBorder(),
          ),
        ),
        actions : [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: (){
              final newName = controller.text.trim();
              if (newName.isEmpty) return;

              setState(() {
                if (index != null) {
                  categories[index] = newName;
                  toastification.show(
                    context: context,
                    title: const Text('Cập nhật thể loại thành công'),
                    type : ToastificationType.success,
                    autoCloseDuration: const Duration(seconds: 2),
                  );
                }else {
                  categories.add(newName);
                  toastification.show(
                    context: context,
                    title: const Text('Thêm thể loại thành công'),
                    type: ToastificationType.success,
                    autoCloseDuration: const Duration(seconds: 2),
                  );
                }
              });

              Navigator.pop(context);
            },
            child: const Text('Lưu'),
          ),
        ],
      );
    },
    );
}

void _deleteCategory(int index){
  showDialog(
    context: context, 
    builder: (context) {
      return AlertDialog(
        title: const Text('Xác nhận'),
        content: Text('Bạn có chắc muốn xóa thể loại "${categories[index]}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: (){
              setState(() {
                categories.removeAt(index);
              });

              toastification.show(
                context: context,
                title: const Text('Đã xóa thể loại'),
                type: ToastificationType.info,
                autoCloseDuration: const Duration(seconds: 2),
              );

              Navigator.pop(context);
            },
            child: const Text('Xóa'),
          ),
        ],
      );
    },
  );
}

@override
Widget build(BuildContext context){
  return ToastificationWrapper(
    child : Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý thể loại sách'),
        backgroundColor: Colors.deepPurple,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryDialog(),
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add)
      ),
      body: categories.isEmpty
      ? const Center(child:Text('Chưa có thể loại nào'))
      : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: categories.length,
        itemBuilder: (context, index){
          return Card(
            child: ListTile(
              title: Text(categories[index]),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color:Colors.blue),
                    onPressed: () => _showCategoryDialog(
                      currentName: categories[index],
                      index: index,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color:Colors.red),
                    onPressed: () => _deleteCategory(index),
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