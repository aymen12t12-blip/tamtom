import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/menu_item.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  String? _restaurantId;
  String? _restaurantName;
  double _deliveryFee = 0;
  double _couponDiscount = 0;
  String? _couponCode;

  List<CartItem> get items => List.unmodifiable(_items);
  String? get restaurantId => _restaurantId;
  String? get restaurantName => _restaurantName;
  double get deliveryFee => _deliveryFee;
  double get couponDiscount => _couponDiscount;
  String? get couponCode => _couponCode;
  int get itemCount => _items.fold(0, (sum, i) => sum + i.quantity);

  double get subtotal =>
      _items.fold(0, (sum, i) => sum + i.menuItem.price * i.quantity);

  double get total => subtotal + _deliveryFee - _couponDiscount;

  bool get isEmpty => _items.isEmpty;

  void addItem(MenuItem item, String restaurantId, String restaurantName) {
    // إذا كانت المطعم مختلفة، امسح السلة أولاً
    if (_restaurantId != null && _restaurantId != restaurantId) {
      clearCart();
    }

    _restaurantId = restaurantId;
    _restaurantName = restaurantName;

    final index = _items.indexWhere((i) => i.menuItem.id == item.id);
    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(
        menuItem: item,
        quantity: 1,
        restaurantId: restaurantId,
        restaurantName: restaurantName,
      ));
    }
    notifyListeners();
  }

  void removeItem(String menuItemId) {
    _items.removeWhere((i) => i.menuItem.id == menuItemId);
    if (_items.isEmpty) clearCart();
    notifyListeners();
  }

  void updateQuantity(String menuItemId, int quantity) {
    if (quantity <= 0) {
      removeItem(menuItemId);
      return;
    }
    final index = _items.indexWhere((i) => i.menuItem.id == menuItemId);
    if (index >= 0) {
      _items[index].quantity = quantity;
      notifyListeners();
    }
  }

  int getQuantity(String menuItemId) {
    final index = _items.indexWhere((i) => i.menuItem.id == menuItemId);
    return index >= 0 ? _items[index].quantity : 0;
  }

  void setDeliveryFee(double fee) {
    _deliveryFee = fee;
    notifyListeners();
  }

  void applyCoupon(String code, double discount) {
    _couponCode = code;
    _couponDiscount = discount;
    notifyListeners();
  }

  void removeCoupon() {
    _couponCode = null;
    _couponDiscount = 0;
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _restaurantId = null;
    _restaurantName = null;
    _deliveryFee = 0;
    _couponDiscount = 0;
    _couponCode = null;
    notifyListeners();
  }

  List<Map<String, dynamic>> toOrderItems() {
    return _items
        .map((i) => {
              'id': i.menuItem.id,
              'name': i.menuItem.name,
              'price': i.menuItem.price,
              'quantity': i.quantity,
              'image': i.menuItem.image,
            })
        .toList();
  }
}
