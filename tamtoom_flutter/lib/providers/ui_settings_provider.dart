import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class UiSettingsProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  Map<String, dynamic> _settings = {};
  bool _loaded = false;

  bool get loaded => _loaded;

  UiSettingsProvider() {
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await _api.getUiSettings();
      _settings = data;
    } catch (_) {}
    _loaded = true;
    notifyListeners();
  }

  String getSetting(String key, [String defaultValue = '']) {
    final val = _settings[key];
    if (val == null) return defaultValue;
    if (val is Map) return val['value']?.toString() ?? defaultValue;
    return val.toString();
  }

  bool isFeatureEnabled(String key, [bool defaultValue = true]) {
    final val = getSetting(key, defaultValue ? 'true' : 'false');
    return val != 'false' && val != '0';
  }

  String get appName => getSetting('app_name', 'طمطوم');
  String get headerLogoUrl => getSetting('header_logo_url', '');
  bool get showSpecialOffers => isFeatureEnabled('show_special_offers');
  bool get showCategories => isFeatureEnabled('show_categories');
  bool get showFeaturedProducts => isFeatureEnabled('show_featured_products');
  bool get showOrdersPage => isFeatureEnabled('show_orders_page');
  bool get showSearchBar => isFeatureEnabled('show_search_bar');
  bool get showSupportButton => isFeatureEnabled('show_support_button');
  String get supportWhatsapp => getSetting('support_whatsapp', '');
  String get supportPhone => getSetting('support_phone', '');
  String get privacyPolicyText => getSetting('privacy_policy_text', '');
}
