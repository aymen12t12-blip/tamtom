class Category {
  final String id;
  final String name;
  final String? icon;
  final String? image;
  final int? sortOrder;

  Category({
    required this.id,
    required this.name,
    this.icon,
    this.image,
    this.sortOrder,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      icon: json['icon'],
      image: json['image'],
      sortOrder: json['sortOrder'],
    );
  }
}
