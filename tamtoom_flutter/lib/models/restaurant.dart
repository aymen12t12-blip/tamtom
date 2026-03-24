class Restaurant {
  final String id;
  final String name;
  final String? description;
  final String? image;
  final String? address;
  final String? phone;
  final double? rating;
  final int? reviewCount;
  final String? deliveryTime;
  final double? deliveryFee;
  final double? minimumOrder;
  final bool isOpen;
  final String? categoryId;
  final double? latitude;
  final double? longitude;
  final String? openingTime;
  final String? closingTime;

  Restaurant({
    required this.id,
    required this.name,
    this.description,
    this.image,
    this.address,
    this.phone,
    this.rating,
    this.reviewCount,
    this.deliveryTime,
    this.deliveryFee,
    this.minimumOrder,
    this.isOpen = true,
    this.categoryId,
    this.latitude,
    this.longitude,
    this.openingTime,
    this.closingTime,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      image: json['image'],
      address: json['address'],
      phone: json['phone'],
      rating: json['rating'] != null
          ? double.tryParse(json['rating'].toString())
          : null,
      reviewCount: json['reviewCount'],
      deliveryTime: json['deliveryTime'],
      deliveryFee: json['deliveryFee'] != null
          ? double.tryParse(json['deliveryFee'].toString())
          : null,
      minimumOrder: json['minimumOrder'] != null
          ? double.tryParse(json['minimumOrder'].toString())
          : null,
      isOpen: json['isOpen'] ?? true,
      categoryId: json['categoryId']?.toString(),
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      openingTime: json['openingTime'],
      closingTime: json['closingTime'],
    );
  }
}
