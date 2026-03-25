class Category {
  final String id;
  final String name;
  final String? icon;
  final String? image;
  final String? description;
  final int? sortOrder;

  Category({
    required this.id,
    required this.name,
    this.icon,
    this.image,
    this.description,
    this.sortOrder,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      icon: json['icon'],
      image: json['image'],
      description: json['description'],
      sortOrder: json['sortOrder'],
    );
  }
}
