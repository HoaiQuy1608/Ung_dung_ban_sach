import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toastification/toastification.dart';

class BookManagementScreen extends StatefulWidget {
  const BookManagementScreen({super.key});

  @override
  State<BookManagementScreen> createState() => _BookManagementScreenState();
}

class _BookManagementScreenState extends State<BookManagementScreen> {
  final List<Map<String, dynamic>> _books = [];

  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  File? _pickedImage;
  bool _isEditing = false;
  int? _editingIndex;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  void _showToast(String message, {bool success = true}) {
    toastification.show(
      context: context,
      title: Text(message),
      autoCloseDuration: const Duration(seconds: 2),
      type: success ? ToastificationType.success : ToastificationType.error,
      style: ToastificationStyle.fillColored,
    );
  }

  void _openBookForm({bool edit = false, int? index}) {
    if (edit && index != null) {
      _titleController.text = _books[index]['title'];
      _priceController.text = _books[index]['price'].toString();
      _descriptionController.text = _books[index]['description'];
      _pickedImage = _books[index]['image'];
      _isEditing = true;
      _editingIndex = index;
    } else {
      _titleController.clear();
      _priceController.clear();
      _descriptionController.clear();
      _pickedImage = null;
      _isEditing = false;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isEditing ? 'Chỉnh sửa sách' : 'Thêm sách mới',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                GestureDetector(
                  onTap: _pickImage,
                  child: _pickedImage == null
                      ? Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(child: Text('Chọn ảnh bìa sách')),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            _pickedImage!,
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Tên sách'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Giá (VNĐ)'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Mô tả sách'),
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    minimumSize: const Size(double.infinity, 45),
                  ),
                  onPressed: () {
                    if (_titleController.text.isEmpty ||
                        _priceController.text.isEmpty ||
                        _descriptionController.text.isEmpty ||
                        _pickedImage == null) {
                      _showToast('Vui lòng nhập đầy đủ thông tin', success: false);
                      return;
                    }

                    final book = {
                      'title': _titleController.text,
                      'price': double.tryParse(_priceController.text) ?? 0.0,
                      'description': _descriptionController.text,
                      'image': _pickedImage,
                    };

                    setState(() {
                      if (_isEditing && _editingIndex != null) {
                        _books[_editingIndex!] = book;
                        _showToast('Cập nhật sách thành công ✅');
                      } else {
                        _books.add(book);
                        _showToast('Thêm sách thành công ✅');
                      }
                    });

                    Navigator.pop(context);
                  },
                  child: Text(_isEditing ? 'Lưu thay đổi' : 'Thêm sách'),
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
        );
      },
    );
  }

  void _deleteBook(int index) {
    setState(() {
      _books.removeAt(index);
      _showToast('Xoá sách thành công 🗑');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý sách'),
        backgroundColor: Colors.redAccent,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        onPressed: () => _openBookForm(),
        child: const Icon(Icons.add),
      ),
      body: _books.isEmpty
          ? const Center(
              child: Text('Chưa có sách nào được thêm'),
            )
          : Padding(
              padding: const EdgeInsets.all(10),
              child: GridView.builder(
                itemCount: _books.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.65,
                ),
                itemBuilder: (context, index) {
                  final book = _books[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            child: Image.file(
                              book['image'],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                book['title'],
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${book['price']} VNĐ',
                                style: const TextStyle(color: Colors.redAccent),
                              ),
                              Text(
                                book['description'],
                                style: const TextStyle(fontSize: 12, color: Colors.black54),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () => _openBookForm(edit: true, index: index),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteBook(index),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}
