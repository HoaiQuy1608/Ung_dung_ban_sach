import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toastification/toastification.dart';

class BookManagementScreen extends StatefulWidget {
  const BookManagementScreen({super.key});

  @override
  State<BookManagementScreen> createState() => _BookManagementScreenState();
}

class _BookManagementScreenState extends State<BookManagementScreen> {
  final DatabaseReference _bookRef = FirebaseDatabase.instance.ref('books');
  final DatabaseReference _categoryRef = FirebaseDatabase.instance.ref('categories');

  List<String> _categories = [];
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedCategory;
  File? _pickedImage;
  bool _isEditing = false;
  String? _editingKey;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  /// Load categories
  void _loadCategories() {
    _categoryRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null && data is Map) {
        setState(() {
          _categories = data.values.map((cat) => cat['name'].toString()).toList();
        });
      } else {
        setState(() => _categories = []);
      }
    });
  }

  /// Convert image to base64
  Future<String> _convertImageToBase64(File image) async {
    final bytes = await image.readAsBytes();
    return base64Encode(bytes);
  }

  /// Show toast
  void _showToast(String message, {bool success = true}) {
    toastification.show(
      context: context,
      title: Text(message),
      autoCloseDuration: const Duration(seconds: 2),
      type: success ? ToastificationType.success : ToastificationType.error,
      style: ToastificationStyle.fillColored,
    );
  }

  /// Open add/edit book form
  void _openBookForm({bool edit = false, Map<String, dynamic>? bookData}) {
    if (edit && bookData != null) {
      _titleController.text = bookData['title'];
      _priceController.text = bookData['price'].toString();
      _descriptionController.text = bookData['description'];
      _selectedCategory = bookData['category'];
      _isEditing = true;
      _editingKey = bookData['key'];
      _pickedImage = null; // reset image to choose new if needed
    } else {
      _titleController.clear();
      _priceController.clear();
      _descriptionController.clear();
      _selectedCategory = null;
      _pickedImage = null;
      _isEditing = false;
      _editingKey = null;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
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
                    onTap: () async {
                      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
                      if (pickedFile != null) {
                        setModalState(() => _pickedImage = File(pickedFile.path));
                      }
                    },
                    child: _pickedImage == null && !edit
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
                            child: _pickedImage != null
                                ? Image.file(_pickedImage!, height: 150, width: double.infinity, fit: BoxFit.cover)
                                : (bookData?['imageBase64'] ?? '').isEmpty
                                    ? Container(
                                        height: 150,
                                        color: Colors.grey[200],
                                        child: const Center(child: Icon(Icons.image)),
                                      )
                                    : Image.memory(
                                        base64Decode(bookData!['imageBase64']),
                                        height: 150,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                          ),
                  ),
                  const SizedBox(height: 15),
                  TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Tên sách')),
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
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Thể loại',
                      border: OutlineInputBorder(),
                    ),
                    items: _categories
                        .map((category) => DropdownMenuItem(value: category, child: Text(category)))
                        .toList(),
                    onChanged: (value) => setModalState(() => _selectedCategory = value),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      minimumSize: const Size(double.infinity, 45),
                    ),
                    onPressed: () async {
                      if (_titleController.text.isEmpty ||
                          _priceController.text.isEmpty ||
                          _descriptionController.text.isEmpty ||
                          _selectedCategory == null) {
                        _showToast('Vui lòng nhập đầy đủ thông tin', success: false);
                        return;
                      }

                      String? imageBase64;
                      if (_pickedImage != null) {
                        imageBase64 = await _convertImageToBase64(_pickedImage!);
                      }

                      final bookDataToSave = {
                        'title': _titleController.text,
                        'price': double.tryParse(_priceController.text) ?? 0.0,
                        'description': _descriptionController.text,
                        'imageBase64': imageBase64 ?? bookData?['imageBase64'] ?? '',
                        'category': _selectedCategory,
                      };

                      try {
                        if (_isEditing && _editingKey != null) {
                          await _bookRef.child(_editingKey!).update(bookDataToSave);
                          _showToast('Cập nhật sách thành công ✅');
                        } else {
                          await _bookRef.push().set(bookDataToSave);
                          _showToast('Thêm sách thành công ✅');
                        }
                      } catch (e) {
                        _showToast('Lỗi lưu sách: $e', success: false);
                      }

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
      ),
    );
  }

  /// Delete book
  void _deleteBook(String key) async {
    try {
      await _bookRef.child(key).remove();
      _showToast('Xoá sách thành công 🗑');
    } catch (e) {
      _showToast('Lỗi xoá sách: $e', success: false);
    }
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
      body: StreamBuilder<DatabaseEvent>(
        stream: _bookRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.snapshot.value;
          List<Map<String, dynamic>> books = [];

          if (data != null && data is Map) {
            data.forEach((key, value) {
              books.add({
                'key': key,
                'title': value['title'] ?? '',
                'price': value['price'] ?? 0.0,
                'description': value['description'] ?? '',
                'imageBase64': value['imageBase64'] ?? '',
                'category': value['category'] ?? '',
              });
            });
          }

          if (books.isEmpty) {
            return const Center(child: Text('Chưa có sách nào được thêm'));
          }

          return Padding(
            padding: const EdgeInsets.all(10),
            child: GridView.builder(
              itemCount: books.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.65,
              ),
              itemBuilder: (context, index) {
                final book = books[index];
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          child: (book['imageBase64'] ?? '').isEmpty
                              ? Container(
                                  color: Colors.grey[200],
                                  child: const Center(child: Icon(Icons.image, size: 50)),
                                )
                              : Image.memory(
                                  base64Decode(book['imageBase64']),
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(book['title'], style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                            Text('${book['price']} VNĐ', style: const TextStyle(color: Colors.redAccent)),
                            Text(book['category'], style: const TextStyle(fontSize: 12, color: Colors.blueGrey), overflow: TextOverflow.ellipsis),
                            Text(book['description'], style: const TextStyle(fontSize: 12, color: Colors.black54), maxLines: 2, overflow: TextOverflow.ellipsis),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _openBookForm(edit: true, bookData: book)),
                                IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteBook(book['key'])),
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
