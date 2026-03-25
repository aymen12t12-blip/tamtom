class ApiConfig {
  static const String baseUrl =
      'https://tamtomsture.onrender.com/';

  static const Duration timeout = Duration(seconds: 30);

  static const String restaurants = '/api/restaurants';
  static const String categories = '/api/categories';
  static const String search = '/api/search';
  static const String orders = '/api/orders';
  static const String deliveryFees = '/api/delivery-fees/calculate';
  static const String validateCoupon = '/api/coupons/validate';
  static const String authLogin = '/api/auth/login';
  static const String authRegister = '/api/auth/register';
  static const String authValidate = '/api/auth/validate';
  static const String authLogout = '/api/auth/logout';
  static const String specialOffers = '/api/special-offers';
  static const String uiSettings = '/api/ui-settings';
  static const String featuredProducts = '/api/products/featured';
  static const String products = '/api/products';
}
