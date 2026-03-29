// lib/screens/webview_screen.dart
// الشاشة الرئيسية التي تعرض الموقع مع رسالة انتظار عند التحميل الأول

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/constants.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  // متحكم WebView
  late final WebViewController _controller;

  // متغيرات الحالة
  bool _isLoading = true;
  bool _hasError = false;
  bool _isConnected = true;
  bool _isFirstLoad = true;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _initWebView();
    _monitorConnectivity();
  }

  // ==========================================
  // 📡 فحص الاتصال بالإنترنت
  // ==========================================
  Future<void> _checkConnectivity() async {
    final List<ConnectivityResult> result = await Connectivity().checkConnectivity();
    setState(() {
      _isConnected = !result.contains(ConnectivityResult.none);
    });
  }

  // ==========================================
  // 👂 مراقبة تغيير حالة الإنترنت
  // ==========================================
  void _monitorConnectivity() {
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      if (!mounted) return;
      setState(() {
        _isConnected = !result.contains(ConnectivityResult.none);
      });
      if (_isConnected && _hasError) {
        _reloadWebView();
      }
    });
  }

  // ==========================================
  // 🔧 تهيئة وإعداد WebView
  // ==========================================
  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFFFFFFF))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (!mounted) return;
            setState(() {
              _progress = progress / 100;
            });
          },
          onPageStarted: (String url) {
            if (!mounted) return;
            setState(() {
              _isLoading = true;
              _hasError = false;
            });
          },
          onPageFinished: (String url) {
            if (!mounted) return;
            setState(() {
              _isLoading = false;
              _isFirstLoad = false;
              _progress = 1.0;
            });
          },
          onWebResourceError: (WebResourceError error) {
            if (!mounted) return;
            setState(() {
              _hasError = true;
              _isLoading = false;
              _isFirstLoad = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            if (!AppConstants.isAllowedUrl(request.url)) {
              _launchInExternalBrowser(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(AppConstants.websiteUrl));
  }

  // ==========================================
  // 🌐 فتح الرابط في المتصفح الخارجي
  // ==========================================
  Future<void> _launchInExternalBrowser(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // ==========================================
  // 🔄 إعادة تحميل الصفحة
  // ==========================================
  void _reloadWebView() {
    _controller.reload();
    setState(() {
      _hasError = false;
      _isLoading = true;
    });
  }

  // ==========================================
  // ⬅️ العودة للصفحة السابقة أو الخروج
  // ==========================================
  void _goBack() async {
    if (await _controller.canGoBack()) {
      _controller.goBack();
    } else {
      _showExitConfirmation();
    }
  }

  // ==========================================
  // ❓ تأكيد الخروج من التطبيق
  // ==========================================
  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إغلاق التطبيق'),
        content: const Text('هل تريد الخروج من التطبيق؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              exit(0);
            },
            child: const Text('خروج', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;
        _goBack();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        // إزالة AppBar ليكون العرض كامل كما طلب المستخدم
        body: SafeArea(
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (!_isConnected) {
      return _buildNoInternetWidget();
    }

    if (_hasError) {
      return _buildErrorWidget();
    }

    return Stack(
      children: [
        // واجهة الموقع
        WebViewWidget(controller: _controller),

        // رسالة الانتظار عند التحميل الأول
        if (_isFirstLoad && _isLoading)
          Container(
            color: Colors.white,
            width: double.infinity,
            height: double.infinity,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    color: Colors.red,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'يرجى الانتظار قليلاً للمرة الأولى من أجل تحميل البيانات...',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'جاري الاتصال بـ ${AppConstants.appName}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // شريط تقدم التحميل الصغير في الأعلى (بعد التحميل الأول)
        if (!_isFirstLoad && _isLoading && _progress < 0.99)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(
              value: _progress,
              backgroundColor: Colors.grey.shade300,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
              minHeight: 3,
            ),
          ),
      ],
    );
  }

  Widget _buildNoInternetWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          const Text(
            'لا يوجد اتصال بالإنترنت',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _reloadWebView,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 80, color: Colors.red),
          const SizedBox(height: 20),
          const Text(
            'حدث خطأ في تحميل البيانات',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _reloadWebView,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}
