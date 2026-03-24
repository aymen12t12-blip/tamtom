import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final ApiService _api = ApiService();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  final _couponController = TextEditingController();

  String _paymentMethod = 'cash';
  bool _placingOrder = false;
  bool _calculatingFee = false;
  bool _couponLoading = false;
  String _couponError = '';
  Position? _userPosition;

  @override
  void initState() {
    super.initState();
    _fillUserData();
    _getLocation();
  }

  void _fillUserData() {
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _nameController.text = user.name;
      _phoneController.text = user.phone ?? '';
    }
  }

  Future<void> _getLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
      final position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() => _userPosition = position);
        _calculateDeliveryFee();
      }
    } catch (_) {}
  }

  Future<void> _calculateDeliveryFee() async {
    if (_userPosition == null) return;
    final cart = context.read<CartProvider>();
    if (cart.restaurantId == null) return;

    setState(() => _calculatingFee = true);
    final result = await _api.calculateDeliveryFee(
      customerLat: _userPosition!.latitude,
      customerLng: _userPosition!.longitude,
      restaurantId: cart.restaurantId!,
      orderSubtotal: cart.subtotal,
    );
    if (mounted && result != null && result['success'] == true) {
      cart.setDeliveryFee((result['fee'] ?? 0).toDouble());
    }
    if (mounted) setState(() => _calculatingFee = false);
  }

  Future<void> _validateCoupon() async {
    if (_couponController.text.trim().isEmpty) return;
    final cart = context.read<CartProvider>();
    setState(() {
      _couponLoading = true;
      _couponError = '';
    });

    final result = await _api.validateCoupon(
      code: _couponController.text.trim(),
      orderValue: cart.subtotal,
    );

    if (mounted) {
      setState(() => _couponLoading = false);
      if (result != null && result['valid'] == true) {
        cart.applyCoupon(
          _couponController.text.trim(),
          (result['discount'] ?? 0).toDouble(),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('تم تطبيق الكوبون! خصم ${result['discount']} ر.ي'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() =>
            _couponError = result?['message'] ?? 'كوبون غير صالح');
      }
    }
  }

  Future<void> _placeOrder() async {
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال الاسم ورقم الهاتف')),
      );
      return;
    }

    final cart = context.read<CartProvider>();
    setState(() => _placingOrder = true);

    final orderData = {
      'customerName': _nameController.text.trim(),
      'customerPhone': _phoneController.text.trim(),
      'deliveryAddress': _addressController.text.trim(),
      'notes': _notesController.text.trim(),
      'paymentMethod': _paymentMethod,
      'restaurantId': cart.restaurantId,
      'items': cart.toOrderItems(),
      'subtotal': cart.subtotal.toStringAsFixed(2),
      'deliveryFee': cart.deliveryFee.toStringAsFixed(2),
      'totalAmount': cart.total.toStringAsFixed(2),
      'total': cart.total.toStringAsFixed(2),
      if (cart.couponCode != null) 'couponCode': cart.couponCode,
      if (_userPosition != null) ...{
        'customerLocationLat':
            _userPosition!.latitude.toStringAsFixed(6),
        'customerLocationLng':
            _userPosition!.longitude.toStringAsFixed(6),
      },
    };

    final result = await _api.placeOrder(orderData);
    if (mounted) {
      setState(() => _placingOrder = false);
      if (result != null) {
        cart.clearCart();
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('✅', style: TextStyle(fontSize: 60)),
                const SizedBox(height: 12),
                const Text(
                  'تم تأكيد طلبك!',
                  style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'رقم الطلب: ${result['orderNumber'] ?? ''}',
                  style: const TextStyle(
                      fontSize: 16, color: Colors.green),
                ),
                const SizedBox(height: 4),
                const Text(
                  'سيتم التواصل معك قريباً',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((r) => r.isFirst);
                },
                child: const Text('الرئيسية'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('فشل في تأكيد الطلب. حاول مرة أخرى'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          title: const Text('سلة الطلبات',
              style: TextStyle(fontWeight: FontWeight.bold)),
          actions: [
            if (cart.itemCount > 0)
              TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('مسح السلة'),
                      content: const Text('هل تريد مسح جميع العناصر؟'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('لا'),
                        ),
                        TextButton(
                          onPressed: () {
                            cart.clearCart();
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          child: const Text('نعم',
                              style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('مسح', style: TextStyle(color: Colors.red)),
              ),
          ],
        ),
        body: cart.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🛒', style: TextStyle(fontSize: 80)),
                    const SizedBox(height: 16),
                    const Text(
                      'السلة فارغة',
                      style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'أضف بعض المنتجات من المتاجر',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('تصفح المتاجر'),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    // عناصر السلة
                    _buildCartItems(cart),

                    // بيانات التوصيل
                    _buildDeliveryForm(),

                    // كوبون الخصم
                    _buildCouponSection(cart),

                    // طريقة الدفع
                    _buildPaymentMethods(),

                    // ملخص الطلب
                    _buildOrderSummary(cart),

                    // زر تأكيد الطلب
                    _buildPlaceOrderButton(cart),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildCartItems(CartProvider cart) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              cart.restaurantName ?? 'المتجر',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const Divider(height: 1),
          ...cart.items.map((item) => ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text('🥦', style: TextStyle(fontSize: 28)),
                  ),
                ),
                title: Text(item.menuItem.name,
                    style:
                        const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(
                    '${item.menuItem.price.toStringAsFixed(0)} ر.ي × ${item.quantity}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline,
                          color: Colors.red, size: 22),
                      onPressed: () =>
                          cart.updateQuantity(item.menuItem.id, item.quantity - 1),
                    ),
                    Text('${item.quantity}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline,
                          color: Color(0xFF4CAF50), size: 22),
                      onPressed: () => cart.addItem(
                          item.menuItem, item.restaurantId, item.restaurantName),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildDeliveryForm() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('بيانات التوصيل',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'الاسم الكامل',
              prefixIcon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'رقم الهاتف',
              prefixIcon: Icon(Icons.phone),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _addressController,
            decoration: InputDecoration(
              labelText: 'عنوان التوصيل',
              prefixIcon: const Icon(Icons.location_on),
              suffixIcon: _userPosition != null
                  ? const Icon(Icons.gps_fixed, color: Colors.green)
                  : IconButton(
                      icon: const Icon(Icons.my_location),
                      onPressed: _getLocation,
                    ),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'ملاحظات (اختياري)',
              prefixIcon: Icon(Icons.note),
            ),
            maxLines: 2,
          ),
          if (_userPosition == null) ...[
            const SizedBox(height: 8),
            const Text(
              'يُفضل تحديد موقعك لحساب رسوم التوصيل',
              style: TextStyle(color: Colors.orange, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCouponSection(CartProvider cart) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('كوبون الخصم',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          if (cart.couponCode != null)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'كوبون: ${cart.couponCode} - خصم ${cart.couponDiscount.toStringAsFixed(0)} ر.ي',
                    style: const TextStyle(color: Colors.green),
                  ),
                  GestureDetector(
                    onTap: () {
                      cart.removeCoupon();
                      _couponController.clear();
                    },
                    child: const Icon(Icons.close, color: Colors.red, size: 18),
                  ),
                ],
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _couponController,
                    decoration: InputDecoration(
                      hintText: 'أدخل كود الكوبون',
                      errorText:
                          _couponError.isNotEmpty ? _couponError : null,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                    textCapitalization: TextCapitalization.characters,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _couponLoading ? null : _validateCoupon,
                  child: _couponLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('تطبيق'),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    final methods = [
      {'id': 'cash', 'label': 'كاش', 'emoji': '💵'},
      {'id': 'card', 'label': 'بطاقة', 'emoji': '💳'},
      {'id': 'wallet', 'label': 'محفظة', 'emoji': '👛'},
      {'id': 'online', 'label': 'إلكتروني', 'emoji': '🌐'},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('طريقة الدفع',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          Row(
            children: methods.map((m) {
              final isSelected = _paymentMethod == m['id'];
              return Expanded(
                child: GestureDetector(
                  onTap: () =>
                      setState(() => _paymentMethod = m['id'] as String),
                  child: Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF4CAF50)
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF4CAF50)
                            : Colors.grey[300]!,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(m['emoji'] as String,
                            style: const TextStyle(fontSize: 22)),
                        const SizedBox(height: 4),
                        Text(
                          m['label'] as String,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color:
                                isSelected ? Colors.white : Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(CartProvider cart) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _summaryRow('المجموع الفرعي',
              '${cart.subtotal.toStringAsFixed(2)} ر.ي'),
          _summaryRow(
            'رسوم التوصيل',
            _calculatingFee
                ? 'جاري الحساب...'
                : cart.deliveryFee == 0
                    ? 'مجاني'
                    : '${cart.deliveryFee.toStringAsFixed(2)} ر.ي',
            valueColor: cart.deliveryFee == 0 ? Colors.green : null,
          ),
          if (cart.couponDiscount > 0)
            _summaryRow(
              'خصم الكوبون',
              '- ${cart.couponDiscount.toStringAsFixed(2)} ر.ي',
              valueColor: Colors.green,
            ),
          const Divider(),
          _summaryRow(
            'الإجمالي',
            '${cart.total.toStringAsFixed(2)} ر.ي',
            isBold: true,
            fontSize: 18,
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
    String label,
    String value, {
    bool isBold = false,
    double fontSize = 14,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: valueColor ??
                  (isBold ? const Color(0xFF2E7D32) : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceOrderButton(CartProvider cart) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _placingOrder ? null : _placeOrder,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: _placingOrder
              ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    ),
                    SizedBox(width: 10),
                    Text('جاري تأكيد الطلب...',
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                  ],
                )
              : Text(
                  'تأكيد الطلب - ${cart.total.toStringAsFixed(0)} ر.ي',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}
