import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toastification/toastification.dart';
import '/models/book_model.dart';

class BookManagementScreen extends StatefulWidget {
  const BookManagementScreen({super.key});

  @override
  State<BookManagementScreen> createState() => _BookManagementScreenState();
}

class _BookManagementScreenState extends State<BookManagementScreen> {
  final _bookRef = FirebaseDatabase.instance.ref('books');
  final _categoryRef = FirebaseDatabase.instance.ref('categories');
  final _picker = ImagePicker();

  // Controllers
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  List<String> _categories = [];
  String? _selectedCategory;
  File? _pickedImage;

  bool _isEditing = false;
  String? _editingId;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  /// 🔹 Lấy danh sách thể loại từ Realtime Database
  Future<void> _loadCategories() async {
  final snapshot = await _categoryRef.get();
  if (snapshot.exists && snapshot.value is Map) {
    final data = snapshot.value as Map<dynamic, dynamic>;
    setState(() {
      _categories = data.values
          .whereType<Map>() // lọc object
          .map((e) => e['name']?.toString() ?? '')
          .where((name) => name.isNotEmpty)
          .toList();
    });
  }
}

  /// 🔹 Hiển thị thông báo
  void _showToast(String message, {bool success = true}) {
    toastification.show(
      context: context,
      title: Text(message),
      type: success ? ToastificationType.success : ToastificationType.error,
      autoCloseDuration: const Duration(seconds: 2),
    );
  }

  /// 🔹 Chuyển ảnh sang Base64
  Future<String> _convertToBase64(File file) async {
    final bytes = await file.readAsBytes();
    return base64Encode(bytes);
  }

  /// 🔹 Mở form thêm / sửa sách
  void _openBookForm({Book? book}) {
    if (book != null) {
      _titleController.text = book.title;
      _authorController.text = book.author;
      _priceController.text = book.price.toString();
      _descriptionController.text = book.description;
      _selectedCategory = book.genre;
      _isEditing = true;
      _editingId = book.id;
    } else {
      _titleController.clear();
      _authorController.clear();
      _priceController.clear();
      _descriptionController.clear();
      _pickedImage = null;
      _selectedCategory = null;
      _isEditing = false;
      _editingId = null;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    _isEditing ? 'Chỉnh sửa sách' : 'Thêm sách mới',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),

                  // Ảnh bìa
                  GestureDetector(
                    onTap: () async {
                      final picked = await _picker.pickImage(source: ImageSource.gallery);
                      if (picked != null) {
                        setModalState(() => _pickedImage = File(picked.path));
                      }
                    },
                    child: _pickedImage != null
                        ? Image.file(_pickedImage!,
                            height: 150, width: double.infinity, fit: BoxFit.cover)
                        : (book?.imageBase64.isNotEmpty ?? false)
                            ? Image.memory(base64Decode(book!.imageBase64),
                                height: 150, width: double.infinity, fit: BoxFit.cover)
                            : Container(
                                height: 150,
                                width: double.infinity,
                                color: Colors.grey[300],
                                child: const Center(child: Text('Chọn ảnh sách')),
                              ),
                  ),

                  const SizedBox(height: 15),
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Tên sách'),
                  ),
                  TextField(
                    controller: _authorController,
                    decoration: const InputDecoration(labelText: 'Tác giả'),
                  ),
                  TextField(
                    controller: _priceController,
                    decoration: const InputDecoration(labelText: 'Giá'),
                    keyboardType: TextInputType.number,
                  ),

                  /// Dropdown chọn thể loại
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Thể loại'),
                    value: _selectedCategory,
                    items: _categories
                        .map((cat) => DropdownMenuItem(
                              value: cat,
                              child: Text(cat),
                            ))
                        .toList(),
                    onChanged: (val) => setModalState(() => _selectedCategory = val),
                  ),

                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Mô tả'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () async {
                      if (_titleController.text.isEmpty ||
                          _priceController.text.isEmpty ||
                          _selectedCategory == null) {
                        _showToast('Vui lòng nhập đủ thông tin', success: false);
                        return;
                      }

                      String base64Image = book?.imageBase64 ?? '';
                      if (_pickedImage != null) {
                        base64Image = await _convertToBase64(_pickedImage!);
                      }

                      final newBook = Book(
                        id: _editingId ?? '',
                        title: _titleController.text.trim(),
                        author: _authorController.text.trim(),
                        genre: _selectedCategory!,
                        imageBase64: base64Image,
                        price: double.tryParse(_priceController.text) ?? 0.0,
                        description: _descriptionController.text.trim(),
                        rating: book?.rating ?? 0,
                      );

                      try {
                        if (_isEditing && _editingId != null) {
                          await _bookRef.child(_editingId!).update(newBook.toJson());
                          _showToast('Cập nhật thành công ✅');
                        } else {
                          final newRef = _bookRef.push();
                          await newRef.set(newBook.copyWith(id: newRef.key).toJson());
                          _showToast('Thêm thành công ✅');
                        }
                      } catch (e) {
                        _showToast('Lỗi: $e', success: false);
                      }

                      if (context.mounted) Navigator.pop(context);
                    },
                    child: Text(_isEditing ? 'Lưu thay đổi' : 'Thêm sách'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// 🔹 Xoá sách
  Future<void> _deleteBook(String id) async {
    try {
      await _bookRef.child(id).remove();
      _showToast('Đã xoá sách 🗑');
    } catch (e) {
      _showToast('Lỗi xoá: $e', success: false);
    }
  }

  /// 🔹 Hiển thị danh sách sách
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
      body: StreamBuilder(
        stream: _bookRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: Text('Chưa có sách nào'));
          }

          final rawData = snapshot.data!.snapshot.value;

if (rawData is! Map) {
  return const Center(child: Text('Dữ liệu sách không hợp lệ'));
}

final data = rawData as Map<dynamic, dynamic>;
final books = data.entries.map((e) {
  final value = e.value;
  if (value is Map) {
    return Book.fromJson(e.key, Map<String, dynamic>.from(value));
  } else {
    debugPrint('⚠️ Dòng dữ liệu không hợp lệ: $value');
    return null;
  }
}).whereType<Book>().toList();


          return GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.65,
            ),
            itemCount: books.length,
            itemBuilder: (context, i) {
              final book = books[i];
              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius:
                            const BorderRadius.vertical(top: Radius.circular(10)),
                        child: (book.imageBase64.isNotEmpty)
                          ? Image.memory(base64Decode(book.imageBase64), fit: BoxFit.cover)
                          : Container(
                              color: Colors.grey[200],
                              child: const Center(child: Icon(Icons.book, size: 50, color: Colors.grey)),
                            ),

                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(book.title,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis),
                          Text('${book.price} VNĐ',
                              style: const TextStyle(color: Colors.redAccent)),
                          Text(book.author,
                              style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          Text(book.genre,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.blueAccent)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _openBookForm(book: book),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteBook(book.id),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
