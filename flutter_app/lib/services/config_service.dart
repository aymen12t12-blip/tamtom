import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  final bool splashEnabled;
  final String splashImageUrl;
  final String splashImageUrl2;
  final String splashTitle;
  final String splashSubtitle;
  final String splashBackgroundColor;
  final int splashDuration;
  final String appName;
  final String appVersion;
  final String primaryColor;
  final String secondaryColor;
  final String accentColor;
  final String logoUrl;
  final String webAppUrl;
  final String storeStatus;
  final String privacyPolicyText;

  AppConfig({
    this.splashEnabled = true,
    this.splashImageUrl = '',
    this.splashImageUrl2 = '',
    this.splashTitle = 'طمطوم',
    this.splashSubtitle = 'متجر الخضار والفواكه',
    this.splashBackgroundColor = '#FFFFFF',
    this.splashDuration = 3000,
    this.appName = 'طمطوم',
    this.appVersion = '1.0.0',
    this.primaryColor = '#4CAF50',
    this.secondaryColor = '#FF9800',
    this.accentColor = '#2196F3',
    this.logoUrl = '',
    this.webAppUrl = 'https://tamtomsture.onrender.com',
    this.storeStatus = 'open',
    this.privacyPolicyText = '',
  });

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    final c = json['config'] ?? json;
    return AppConfig(
      splashEnabled: c['splashEnabled'] ?? true,
      splashImageUrl: c['splashImageUrl'] ?? '',
      splashImageUrl2: c['splashImageUrl2'] ?? '',
      splashTitle: c['splashTitle'] ?? 'طمطوم',
      splashSubtitle: c['splashSubtitle'] ?? 'متجر الخضار والفواكه',
      splashBackgroundColor: c['splashBackgroundColor'] ?? '#FFFFFF',
      splashDuration: c['splashDuration'] ?? 3000,
      appName: c['appName'] ?? 'طمطوم',
      appVersion: c['appVersion'] ?? '1.0.0',
      primaryColor: c['primaryColor'] ?? '#4CAF50',
      secondaryColor: c['secondaryColor'] ?? '#FF9800',
      accentColor: c['accentColor'] ?? '#2196F3',
      logoUrl: c['logoUrl'] ?? '',
      webAppUrl: c['webAppUrl'] ?? 'https://tamtomsture.onrender.com',
      storeStatus: c['storeStatus'] ?? 'open',
      privacyPolicyText: c['privacyPolicyText'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'splashEnabled': splashEnabled,
    'splashImageUrl': splashImageUrl,
    'splashImageUrl2': splashImageUrl2,
    'splashTitle': splashTitle,
    'splashSubtitle': splashSubtitle,
    'splashBackgroundColor': splashBackgroundColor,
    'splashDuration': splashDuration,
    'appName': appName,
    'appVersion': appVersion,
    'primaryColor': primaryColor,
    'secondaryColor': secondaryColor,
    'accentColor': accentColor,
    'logoUrl': logoUrl,
    'webAppUrl': webAppUrl,
    'storeStatus': storeStatus,
    'privacyPolicyText': privacyPolicyText,
  };
}

class ConfigService {
  static const String _baseUrl = 'https://tamtomsture.onrender.com';
  static const String _cacheKey = 'app_config_cache';
  static AppConfig? _cachedConfig;

  static AppConfig get defaultConfig => AppConfig();

  static Future<AppConfig> fetchConfig() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/api/flutter/app-config'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final config = AppConfig.fromJson(data);
        _cachedConfig = config;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_cacheKey, jsonEncode(data));
        return config;
      }
    } catch (e) {
      print('Config fetch error: $e');
    }

    // Try loading from cache
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_cacheKey);
      if (cached != null) {
        final data = jsonDecode(cached);
        return AppConfig.fromJson(data);
      }
    } catch (e) {
      print('Cache load error: $e');
    }

    return defaultConfig;
  }

  static AppConfig get current => _cachedConfig ?? defaultConfig;

  static int hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return int.parse(hex, radix: 16);
  }
}
