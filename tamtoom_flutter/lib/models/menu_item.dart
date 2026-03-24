class MenuItem {
  final String id;
  final String name;
  final String? description;
  final double price;
  final String? image;
  final String? category;
  final bool isAvailable;
  final String? restaurantId;
  final bool? isFeatured;
  final String? unit;

  MenuItem({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.image,
    this.category,
    this.isAvailable = true,
    this.restaurantId,
    this.isFeatured,
    this.unit,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0,
      image: json['image'],
      category: json['category'],
      isAvailable: json['isAvailable'] ?? true,
      restaurantId: json['restaurantId']?.toString(),
      isFeatured: json['isFeatured'],
      unit: json['unit'],
    );
  }
}
