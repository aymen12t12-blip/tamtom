import 'menu_item.dart';

class CartItem {
  final MenuItem menuItem;
  int quantity;
  final String restaurantId;
  final String restaurantName;

  CartItem({
    required this.menuItem,
    required this.quantity,
    required this.restaurantId,
    required this.restaurantName,
  });

  double get totalPrice => menuItem.price * quantity;

  Map<String, dynamic> toJson() {
    return {
      'id': menuItem.id,
      'name': menuItem.name,
      'price': menuItem.price,
      'quantity': quantity,
      'image': menuItem.image,
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
    };
  }
}
