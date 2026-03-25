import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/category.dart';
import '../models/restaurant.dart';
import '../models/menu_item.dart';
import '../models/order.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _authToken;

  void setToken(String? token) {
    _authToken = token;
  }

  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  Uri _uri(String path, [Map<String, String>? params]) {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    if (params != null) return uri.replace(queryParameters: params);
    return uri;
  }

  String resolveImageUrl(String? image) {
    if (image == null || image.isEmpty) return '';
    if (image.startsWith('http')) return image;
    return '${ApiConfig.baseUrl}$image';
  }

  // =================== الفئات ===================
  Future<List<Category>> getCategories() async {
    try {
      final response = await http
          .get(_uri(ApiConfig.categories), headers: _headers)
          .timeout(ApiConfig.timeout);
      if (response.statusCode == 200) {
        final List data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.map((j) => Category.fromJson(j)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // =================== المطاعم ===================
  Future<List<Restaurant>> getRestaurants() async {
    try {
      final response = await http
          .get(_uri(ApiConfig.restaurants), headers: _headers)
          .timeout(ApiConfig.timeout);
      if (response.statusCode == 200) {
        final List data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.map((j) => Restaurant.fromJson(j)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Restaurant?> getRestaurant(String id) async {
    try {
      final response = await http
          .get(_uri('${ApiConfig.restaurants}/$id'), headers: _headers)
          .timeout(ApiConfig.timeout);
      if (response.statusCode == 200) {
        return Restaurant.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // =================== المنتجات ===================
  Future<List<MenuItem>> getFeaturedProducts() async {
    try {
      final response = await http
          .get(_uri(ApiConfig.featuredProducts), headers: _headers)
          .timeout(ApiConfig.timeout);
      if (response.statusCode == 200) {
        final List data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.map((j) => MenuItem.fromJson(j)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<MenuItem>> getProductsByCategory(String categoryName) async {
    try {
      final response = await http
          .get(_uri(ApiConfig.products, {'category': categoryName}),
              headers: _headers)
          .timeout(ApiConfig.timeout);
      if (response.statusCode == 200) {
        final List data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.map((j) => MenuItem.fromJson(j)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<MenuItem?> getProduct(String id) async {
    try {
      final response = await http
          .get(_uri('${ApiConfig.products}/$id'), headers: _headers)
          .timeout(ApiConfig.timeout);
      if (response.statusCode == 200) {
        return MenuItem.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // =================== قائمة الطعام ===================
  Future<List<MenuItem>> getMenuItems(String restaurantId) async {
    try {
      final response = await http
          .get(_uri('${ApiConfig.restaurants}/$restaurantId/menu'),
              headers: _headers)
          .timeout(ApiConfig.timeout);
      if (response.statusCode == 200) {
        final List data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.map((j) => MenuItem.fromJson(j)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // =================== البحث ===================
  Future<Map<String, dynamic>> search(String query) async {
    try {
      final response = await http
          .get(_uri(ApiConfig.search, {'q': query}), headers: _headers)
          .timeout(ApiConfig.timeout);
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
      return {'categories': [], 'menuItems': []};
    } catch (e) {
      return {'categories': [], 'menuItems': []};
    }
  }

  // =================== رسوم التوصيل ===================
  Future<Map<String, dynamic>?> calculateDeliveryFee({
    required double customerLat,
    required double customerLng,
    required String restaurantId,
    required double orderSubtotal,
  }) async {
    try {
      final response = await http
          .post(
            _uri(ApiConfig.deliveryFees),
            headers: _headers,
            body: jsonEncode({
              'customerLat': customerLat,
              'customerLng': customerLng,
              'restaurantId': restaurantId,
              'orderSubtotal': orderSubtotal,
            }),
          )
          .timeout(ApiConfig.timeout);
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // =================== كوبون ===================
  Future<Map<String, dynamic>?> validateCoupon({
    required String code,
    required double orderValue,
  }) async {
    try {
      final response = await http
          .post(
            _uri(ApiConfig.validateCoupon),
            headers: _headers,
            body: jsonEncode({
              'code': code.toUpperCase(),
              'orderValue': orderValue,
            }),
          )
          .timeout(ApiConfig.timeout);
      return jsonDecode(utf8.decode(response.bodyBytes));
    } catch (e) {
      return null;
    }
  }

  // =================== الطلبات ===================
  Future<Map<String, dynamic>?> placeOrder(
      Map<String, dynamic> orderData) async {
    try {
      final response = await http
          .post(
            _uri(ApiConfig.orders),
            headers: _headers,
            body: jsonEncode(orderData),
          )
          .timeout(ApiConfig.timeout);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Order?> getOrderByNumber(String orderNumber) async {
    try {
      final response = await http
          .get(_uri('/api/orders/number/$orderNumber'), headers: _headers)
          .timeout(ApiConfig.timeout);
      if (response.statusCode == 200) {
        return Order.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Order?> getOrderById(String orderId) async {
    try {
      final response = await http
          .get(_uri('/api/orders/$orderId'), headers: _headers)
          .timeout(ApiConfig.timeout);
      if (response.statusCode == 200) {
        return Order.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<Order>> getOrdersByPhone(String phone) async {
    try {
      final response = await http
          .get(_uri('/api/orders/customer/$phone'), headers: _headers)
          .timeout(ApiConfig.timeout);
      if (response.statusCode == 200) {
        final List data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.map((j) => Order.fromJson(j)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // =================== المفضلة ===================
  Future<List<MenuItem>> getFavorites(String userId) async {
    try {
      final response = await http
          .get(_uri('/api/favorites/products/$userId'), headers: _headers)
          .timeout(ApiConfig.timeout);
      if (response.statusCode == 200) {
        final List data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.map((j) => MenuItem.fromJson(j)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> addFavorite(
      String userId, String menuItemId, String restaurantId) async {
    try {
      final response = await http
          .post(
            _uri('/api/favorites'),
            headers: _headers,
            body: jsonEncode({
              'userId': userId,
              'menuItemId': menuItemId,
              'restaurantId': restaurantId,
            }),
          )
          .timeout(ApiConfig.timeout);
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeFavorite(String userId, String menuItemId) async {
    try {
      final response = await http
          .delete(
            _uri('/api/favorites/$userId/$menuItemId'),
            headers: _headers,
          )
          .timeout(ApiConfig.timeout);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // =================== إعدادات واجهة المستخدم ===================
  Future<Map<String, dynamic>> getUiSettings() async {
    try {
      final response = await http
          .get(_uri(ApiConfig.uiSettings), headers: _headers)
          .timeout(ApiConfig.timeout);
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data is List) {
          final Map<String, dynamic> result = {};
          for (final item in data) {
            if (item['key'] != null) {
              result[item['key']] = item['value'] ?? item;
            }
          }
          return result;
        }
        return data is Map<String, dynamic> ? data : {};
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  // =================== العروض الخاصة ===================
  Future<List<dynamic>> getSpecialOffers() async {
    try {
      final response = await http
          .get(_uri(ApiConfig.specialOffers), headers: _headers)
          .timeout(ApiConfig.timeout);
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // =================== العناوين ===================
  Future<List<dynamic>> getAddresses(String userId) async {
    try {
      final response = await http
          .get(_uri('/api/customer/$userId/addresses'), headers: _headers)
          .timeout(ApiConfig.timeout);
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> addAddress(String userId, Map<String, dynamic> address) async {
    try {
      final response = await http
          .post(
            _uri('/api/customer/$userId/addresses'),
            headers: _headers,
            body: jsonEncode(address),
          )
          .timeout(ApiConfig.timeout);
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteAddress(String userId, String addressId) async {
    try {
      final response = await http
          .delete(
            _uri('/api/customer/$userId/addresses/$addressId'),
            headers: _headers,
          )
          .timeout(ApiConfig.timeout);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // =================== تقييم الطلب ===================
  Future<bool> submitReview({
    required String orderId,
    required double restaurantRating,
    required double driverRating,
    String? comment,
  }) async {
    try {
      final response = await http
          .post(
            _uri('/api/customer/orders/$orderId/review'),
            headers: _headers,
            body: jsonEncode({
              'restaurantRating': restaurantRating,
              'driverRating': driverRating,
              'comment': comment ?? '',
            }),
          )
          .timeout(ApiConfig.timeout);
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}
