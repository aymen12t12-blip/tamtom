class ApiConfig {
  // قم بتغيير هذا العنوان إلى عنوان السيرفر الخاص بك
  // للتطوير المحلي: http://10.0.2.2:5000 (محاكي أندرويد)
  // للإنتاج: https://your-domain.replit.app
  static const String baseUrl =
      'https://99b4d7e9-c93f-45c5-b450-66829a4d2865-00-lubjf8dozjuc.sisko.replit.dev';

  static const Duration timeout = Duration(seconds: 30);

  // API Endpoints
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
  static const String systemSettings = '/api/system-settings';
}
