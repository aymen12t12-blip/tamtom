import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();

  User? _user;
  bool _isAuthenticated = false;
  bool _loading = true;

  User? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool get loading => _loading;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    try {
      final session = await _authService.validateStoredToken();
      if (session != null) {
        _user = User.fromJson(session['user']);
        _isAuthenticated = true;
        _apiService.setToken(session['token']);
      }
    } catch (_) {}
    _loading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> login(String identifier, String password) async {
    final result = await _authService.login(identifier, password);
    if (result['success']) {
      _user = User.fromJson(result['user']);
      _isAuthenticated = true;
      _apiService.setToken(result['token']);
      notifyListeners();
    }
    return result;
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String phone,
    required String password,
    String? country,
  }) async {
    final result = await _authService.register(
      name: name,
      phone: phone,
      password: password,
      country: country,
    );
    if (result['success']) {
      _user = User.fromJson(result['user']);
      _isAuthenticated = true;
      _apiService.setToken(result['token']);
      notifyListeners();
    }
    return result;
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _isAuthenticated = false;
    _apiService.setToken(null);
    notifyListeners();
  }
}
