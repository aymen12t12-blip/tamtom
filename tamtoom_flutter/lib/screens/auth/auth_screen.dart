import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Login
  final _loginIdentifier = TextEditingController();
  final _loginPassword = TextEditingController();
  bool _loginLoading = false;
  bool _loginObscure = true;

  // Register
  final _regName = TextEditingController();
  final _regPhone = TextEditingController();
  final _regCountry = TextEditingController();
  final _regPassword = TextEditingController();
  bool _regLoading = false;
  bool _regObscure = true;

  String _error = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() => _error = ''));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginIdentifier.dispose();
    _loginPassword.dispose();
    _regName.dispose();
    _regPhone.dispose();
    _regCountry.dispose();
    _regPassword.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_loginIdentifier.text.isEmpty || _loginPassword.text.isEmpty) {
      setState(() => _error = 'يرجى إدخال جميع البيانات');
      return;
    }
    setState(() {
      _loginLoading = true;
      _error = '';
    });
    final auth = context.read<AuthProvider>();
    final result = await auth.login(
        _loginIdentifier.text.trim(), _loginPassword.text.trim());
    if (mounted) {
      setState(() => _loginLoading = false);
      if (result['success']) {
        Navigator.pop(context);
      } else {
        setState(() => _error = result['message'] ?? 'خطأ في تسجيل الدخول');
      }
    }
  }

  Future<void> _register() async {
    if (_regName.text.isEmpty ||
        _regPhone.text.isEmpty ||
        _regPassword.text.isEmpty) {
      setState(() => _error = 'يرجى إدخال جميع البيانات المطلوبة');
      return;
    }
    setState(() {
      _regLoading = true;
      _error = '';
    });
    final auth = context.read<AuthProvider>();
    final result = await auth.register(
      name: _regName.text.trim(),
      phone: _regPhone.text.trim(),
      password: _regPassword.text.trim(),
      country: _regCountry.text.trim(),
    );
    if (mounted) {
      setState(() => _regLoading = false);
      if (result['success']) {
        Navigator.pop(context);
      } else {
        setState(() => _error = result['message'] ?? 'خطأ في إنشاء الحساب');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // شعار التطبيق
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'طم',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    Text(
                      'طوم',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: Colors.red[600],
                      ),
                    ),
                  ],
                ),
                const Text(
                  'خضروات وفواكه طازجة',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 32),

                // بطاقة الدخول/التسجيل
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // تبويبات
                      Container(
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          indicator: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black12, blurRadius: 4),
                            ],
                          ),
                          labelColor: const Color(0xFF2E7D32),
                          unselectedLabelColor: Colors.grey,
                          labelStyle: const TextStyle(
                              fontWeight: FontWeight.bold),
                          tabs: const [
                            Tab(text: 'تسجيل الدخول'),
                            Tab(text: 'حساب جديد'),
                          ],
                        ),
                      ),

                      // رسالة الخطأ
                      if (_error.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.red[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline,
                                  color: Colors.red[700], size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _error,
                                  style: TextStyle(color: Colors.red[700]),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // محتوى التبويبات
                      SizedBox(
                        height: 340,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildLoginTab(),
                            _buildRegisterTab(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // زر الرجوع
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('تصفح بدون تسجيل دخول',
                      style: TextStyle(color: Colors.grey)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _loginIdentifier,
            decoration: const InputDecoration(
              labelText: 'رقم الهاتف أو الاسم',
              prefixIcon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _loginPassword,
            obscureText: _loginObscure,
            decoration: InputDecoration(
              labelText: 'كلمة المرور',
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(_loginObscure
                    ? Icons.visibility_off
                    : Icons.visibility),
                onPressed: () =>
                    setState(() => _loginObscure = !_loginObscure),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loginLoading ? null : _login,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _loginLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('دخول',
                      style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _regName,
              decoration: const InputDecoration(
                labelText: 'الاسم الكامل *',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _regPhone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'رقم الهاتف *',
                prefixIcon: Icon(Icons.phone),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _regCountry,
              decoration: const InputDecoration(
                labelText: 'البلد (اختياري)',
                prefixIcon: Icon(Icons.flag),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _regPassword,
              obscureText: _regObscure,
              decoration: InputDecoration(
                labelText: 'كلمة المرور *',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(_regObscure
                      ? Icons.visibility_off
                      : Icons.visibility),
                  onPressed: () =>
                      setState(() => _regObscure = !_regObscure),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _regLoading ? null : _register,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _regLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('إنشاء حساب',
                        style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
