// lib/screens/splash_screen.dart
// شاشة البداية (Splash Screen) مع أنيميشن سقوط الشعار والغبار

import 'package:flutter/material.dart';
import 'webview_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoAnimation;
  late Animation<double> _logoOpacity;

  late AnimationController _dustController;
  late Animation<double> _dustAnimation;
  late Animation<double> _dustOpacity;

  late AnimationController _textController;
  late Animation<double> _textOpacity;

  @override
  void initState() {
    super.initState();

    // 1. إعداد أنيميشن سقوط الشعار
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _logoAnimation = Tween<double>(begin: -200, end: 0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.bounceOut),
    );

    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _logoController, curve: const Interval(0, 0.5, curve: Curves.easeIn)),
    );

    // 2. إعداد أنيميشن الغبار (تأثير دائرة تتوسع عند السقوط)
    _dustController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _dustAnimation = Tween<double>(begin: 0, end: 150).animate(
      CurvedAnimation(parent: _dustController, curve: Curves.easeOut),
    );

    _dustOpacity = Tween<double>(begin: 0.5, end: 0).animate(
      CurvedAnimation(parent: _dustController, curve: Curves.easeOut),
    );

    // 3. إعداد أنيميشن ظهور النص
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _textOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );

    // تشغيل التسلسل
    _startAnimation();
  }

  Future<void> _startAnimation() async {
    // تشغيل سقوط الشعار
    await _logoController.forward();
    
    // تشغيل الغبار عند الاصطدام (تقريباً في نهاية سقوط الشعار)
    _dustController.forward();
    
    // تشغيل ظهور النص
    await _textController.forward();

    // الانتظار قليلاً قبل الانتقال
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const WebViewScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 1000),
        ),
      );
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _dustController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // تأثير الغبار
                AnimatedBuilder(
                  animation: _dustController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _dustOpacity.value,
                      child: Container(
                        width: _dustAnimation.value,
                        height: _dustAnimation.value / 2,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                
                // الشعار (استخدام أيقونة طماطم أو سلة فواكه)
                AnimatedBuilder(
                  animation: _logoController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _logoAnimation.value),
                      child: Opacity(
                        opacity: _logoOpacity.value,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.3),
                                blurRadius: 15,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.shopping_basket_rounded,
                            size: 80,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 40),
            
            // النص: طمطوم للفواكه والخضروات
            AnimatedBuilder(
              animation: _textController,
              builder: (context, child) {
                return Opacity(
                  opacity: _textOpacity.value,
                  child: Column(
                    children: [
                      const Text(
                        'طمطوم',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                          letterSpacing: 2,
                        ),
                      ),
                      const Text(
                        'للفواكه والخضروات',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
