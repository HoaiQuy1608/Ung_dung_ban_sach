class CategoryModel {
  final String id;
  final String name;

  CategoryModel({required this.id, required this.name});

  factory CategoryModel.fromJson(String id, Map<dynamic, dynamic> json) {
    return CategoryModel(id: id, name: json['name'] ?? 'Không rõ tên');
  }

  Map<String, dynamic> toJson() {
    return {'name': name};
  }
}
