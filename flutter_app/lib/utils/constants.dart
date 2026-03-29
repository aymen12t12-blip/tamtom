// lib/utils/constants.dart
// الثوابت والإعدادات العامة

class AppConstants {
  // اسم التطبيق
  static const String appName = 'طمطوم';
  
  // رابط الموقع المراد عرضه
  static const String websiteUrl = 'https://tamtomsture.onrender.com';
  
  // دالة للتحقق من الروابط المسموح بها
  static bool isAllowedUrl(String url) {
    // السماح بجميع الروابط داخل نفس النطاق
    return url.contains('tamtomsture.onrender.com') ||
           url.contains('tamtomsture.onrender.com/');
  }
  
  // إذا أردت السماح بروابط إضافية، أضفها هنا
  // static bool isAllowedUrl(String url) {
  //   return url.contains('tamtomsture.onrender.com') ||
  //          url.contains('example.com') ||
  //          url.startsWith('https://');
  // }
}