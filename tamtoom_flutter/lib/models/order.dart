class Order {
  final String id;
  final String? orderNumber;
  final String? customerName;
  final String? customerPhone;
  final String? deliveryAddress;
  final String status;
  final List<dynamic> items;
  final double? subtotal;
  final double? deliveryFee;
  final double? total;
  final String? restaurantName;
  final String? driverName;
  final String? driverPhone;
  final String? estimatedTime;
  final DateTime? createdAt;

  Order({
    required this.id,
    this.orderNumber,
    this.customerName,
    this.customerPhone,
    this.deliveryAddress,
    required this.status,
    required this.items,
    this.subtotal,
    this.deliveryFee,
    this.total,
    this.restaurantName,
    this.driverName,
    this.driverPhone,
    this.estimatedTime,
    this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id']?.toString() ?? '',
      orderNumber: json['orderNumber'],
      customerName: json['customerName'],
      customerPhone: json['customerPhone'],
      deliveryAddress: json['deliveryAddress'],
      status: json['status'] ?? 'pending',
      items: json['items'] ?? [],
      subtotal: double.tryParse(json['subtotal']?.toString() ?? ''),
      deliveryFee: double.tryParse(json['deliveryFee']?.toString() ?? ''),
      total: double.tryParse(
          (json['totalAmount'] ?? json['total'])?.toString() ?? ''),
      restaurantName: json['restaurantName'],
      driverName: json['driverName'],
      driverPhone: json['driverPhone'],
      estimatedTime: json['estimatedTime'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'في الانتظار';
      case 'confirmed':
        return 'تم التأكيد';
      case 'preparing':
        return 'قيد التحضير';
      case 'on_way':
        return 'في الطريق';
      case 'delivered':
        return 'تم التوصيل';
      case 'cancelled':
        return 'ملغي';
      default:
        return status;
    }
  }
}
