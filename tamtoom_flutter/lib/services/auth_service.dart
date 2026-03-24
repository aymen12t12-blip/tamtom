import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/user.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';

  Uri _uri(String path) => Uri.parse('${ApiConfig.baseUrl}$path');

  Map<String, String> get _headers => {'Content-Type': 'application/json'};

  // تسجيل الدخول
  Future<Map<String, dynamic>> login(
      String identifier, String password) async {
    try {
      final response = await http
          .post(
            _uri(ApiConfig.authLogin),
            headers: _headers,
            body: jsonEncode({
              'identifier': identifier,
              'password': password,
              'userType': 'customer',
            }),
          )
          .timeout(ApiConfig.timeout);

      final data = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && data['token'] != null) {
        await _saveSession(data['token'], data['user']);
        return {'success': true, 'user': data['user'], 'token': data['token']};
      }

      return {
        'success': false,
        'message': data['message'] ?? 'خطأ في تسجيل الدخول'
      };
    } catch (e) {
      return {'success': false, 'message': 'تعذر الاتصال بالسيرفر'};
    }
  }

  // إنشاء حساب جديد
  Future<Map<String, dynamic>> register({
    required String name,
    required String phone,
    required String password,
    String? country,
  }) async {
    try {
      final response = await http
          .post(
            _uri(ApiConfig.authRegister),
            headers: _headers,
            body: jsonEncode({
              'name': name,
              'phone': phone,
              'username': phone,
              'password': password,
              'country': country ?? '',
              'userType': 'customer',
            }),
          )
          .timeout(ApiConfig.timeout);

      final data = jsonDecode(utf8.decode(response.bodyBytes));

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data['token'] != null) {
        await _saveSession(data['token'], data['user']);
        return {'success': true, 'user': data['user'], 'token': data['token']};
      }

      return {
        'success': false,
        'message': data['message'] ?? 'خطأ في إنشاء الحساب'
      };
    } catch (e) {
      return {'success': false, 'message': 'تعذر الاتصال بالسيرفر'};
    }
  }

  // التحقق من الرمز المحفوظ
  Future<Map<String, dynamic>?> validateStoredToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      if (token == null) return null;

      final response = await http
          .post(
            _uri(ApiConfig.authValidate),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return {'token': token, 'user': data['user']};
      }

      await clearSession();
      return null;
    } catch (e) {
      return null;
    }
  }

  // تسجيل الخروج
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      if (token != null) {
        await http.post(
          _uri(ApiConfig.authLogout),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      }
    } catch (_) {}
    await clearSession();
  }

  Future<void> _saveSession(String token, Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(userData));
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  Future<User?> getCachedUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      if (userJson != null) {
        return User.fromJson(jsonDecode(userJson));
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
