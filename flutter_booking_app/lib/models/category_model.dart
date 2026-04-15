// lib/models/category_model.dart

class Category {
  final String id;
  final String name;
  final String? description;
  final String? icon;
  final bool isActive;

  Category({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    this.isActive = true,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id:          json['id']?.toString() ?? '',
      name:        json['name'] ?? '',
      description: json['description'],
      icon:        json['icon'],
      isActive:    json['isActive'] ?? true,
    );
  }
}
