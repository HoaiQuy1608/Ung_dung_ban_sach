class CategoryModel {
  final String id;
  final String name;

  CategoryModel({required this.id, required this.name});

  // Chuyển từ Firebase JSON → object
  factory CategoryModel.fromJson(String id, Map<dynamic, dynamic> json) {
    return CategoryModel(id: id, name: json['name'] ?? 'Không rõ tên');
  }

  // Chuyển object → JSON để lưu lên Firebase
  Map<String, dynamic> toJson() {
    return {'name': name};
  }
}
