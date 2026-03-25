import 'dart:async';
import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/api_service.dart';

class OrderTrackingScreen extends StatefulWidget {
  final Order order;
  const OrderTrackingScreen({super.key, required this.order});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  final ApiService _api = ApiService();
  late Order _order;
  Timer? _refreshTimer;

  static const Color _primary = Color(0xFF4CAF50);
  static const Color _darkGreen = Color(0xFF2E7D32);

  final List<_TrackStep> _steps = [
    _TrackStep('pending', 'تم استلام الطلب', Icons.receipt_outlined,
        'سيتم مراجعة طلبك قريباً'),
    _TrackStep('confirmed', 'تم تأكيد الطلب', Icons.check_circle_outline,
        'تم قبول طلبك بنجاح'),
    _TrackStep('preparing', 'قيد التحضير', Icons.kitchen_outlined,
        'يتم تجهيز طلبك الآن'),
    _TrackStep('on_way', 'في الطريق إليك', Icons.delivery_dining_outlined,
        'السائق في طريقه إليك'),
    _TrackStep('delivered', 'تم التوصيل', Icons.home_outlined,
        'تم توصيل طلبك بنجاح'),
  ];

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    _startRefreshTimer();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startRefreshTimer() {
    if (_order.status == 'delivered' || _order.status == 'cancelled') return;
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (_) async {
      final updated = await _api.getOrderById(_order.id);
      if (mounted && updated != null) {
        setState(() => _order = updated);
        if (_order.status == 'delivered' || _order.status == 'cancelled') {
          _refreshTimer?.cancel();
        }
      }
    });
  }

  int get _currentStepIndex =>
      _steps.indexWhere((s) => s.status == _order.status);

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'preparing':
        return Colors.purple;
      case 'on_way':
        return Colors.teal;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCancelled = _order.status == 'cancelled';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: Text(
            'تتبع الطلب ${_order.orderNumber ?? _order.id.substring(0, 8)}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // بطاقة حالة الطلب
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isCancelled
                        ? [Colors.red[700]!, Colors.red[400]!]
                        : [_darkGreen, _primary],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Icon(
                      isCancelled ? Icons.cancel : Icons.local_shipping,
                      color: Colors.white,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _order.statusLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_order.estimatedTime != null && !isCancelled) ...[
                      const SizedBox(height: 8),
                      Text(
                        'الوقت المتوقع: ${_order.estimatedTime}',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // خطوات التتبع
              if (!isCancelled)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 2))
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('مراحل الطلب',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      ...List.generate(_steps.length, (i) {
                        final step = _steps[i];
                        final isDone = _currentStepIndex >= i;
                        final isCurrent = _currentStepIndex == i;
                        return _buildStep(
                            step, isDone, isCurrent, i < _steps.length - 1);
                      }),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              // معلومات السائق
              if (_order.driverName != null && _order.status == 'on_way')
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.teal.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.teal[50],
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.delivery_dining,
                            color: Colors.teal, size: 28),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('السائق',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 12)),
                            Text(
                              _order.driverName!,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            if (_order.driverPhone != null)
                              Text(_order.driverPhone!,
                                  style:
                                      TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                      ),
                      if (_order.driverPhone != null)
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.teal[50],
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.phone, color: Colors.teal),
                        ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              // ملخص الطلب
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('ملخص الطلب',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    if (_order.restaurantName != null)
                      _infoRow(Icons.store, 'المتجر', _order.restaurantName!),
                    if (_order.customerName != null)
                      _infoRow(Icons.person, 'الاسم', _order.customerName!),
                    if (_order.deliveryAddress != null &&
                        _order.deliveryAddress!.isNotEmpty)
                      _infoRow(
                          Icons.location_on, 'العنوان', _order.deliveryAddress!),
                    if (_order.total != null)
                      _infoRow(Icons.payments, 'الإجمالي',
                          '${_order.total!.toStringAsFixed(2)} ر.ي',
                          valueColor: _darkGreen),
                    if (_order.createdAt != null)
                      _infoRow(Icons.access_time, 'وقت الطلب',
                          _formatDate(_order.createdAt!)),
                    if (_order.items.isNotEmpty) ...[
                      const Divider(),
                      const Text('العناصر',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ..._order.items.map((item) {
                        final name = item['name'] as String? ?? '';
                        final qty = item['quantity'] ?? 1;
                        final price = item['price'];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text('$name × $qty'),
                              Text(
                                '${((price as num?) ?? 0).toStringAsFixed(0)} ر.ي',
                                style: const TextStyle(color: _darkGreen),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(
      _TrackStep step, bool isDone, bool isCurrent, bool hasLine) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDone ? _primary : Colors.grey[200],
                shape: BoxShape.circle,
                boxShadow: isCurrent
                    ? [
                        BoxShadow(
                            color: _primary.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2))
                      ]
                    : [],
              ),
              child: Icon(
                step.icon,
                size: 20,
                color: isDone ? Colors.white : Colors.grey[400],
              ),
            ),
            if (hasLine)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 2,
                height: 40,
                color: isDone && _currentStepIndex > _steps.indexWhere(
                        (s) => s.status == step.status)
                    ? _primary
                    : Colors.grey[200],
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: TextStyle(
                    fontWeight:
                        isCurrent ? FontWeight.bold : FontWeight.normal,
                    color: isDone ? Colors.black87 : Colors.grey[400],
                    fontSize: 15,
                  ),
                ),
                if (isCurrent)
                  Text(
                    step.subtitle,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[500]),
          const SizedBox(width: 8),
          Text('$label: ',
              style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: valueColor ?? Colors.black87,
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day}/${d.month}/${d.year}  ${d.hour}:${d.minute.toString().padLeft(2, '0')}';
}

class _TrackStep {
  final String status;
  final String title;
  final IconData icon;
  final String subtitle;

  const _TrackStep(this.status, this.title, this.icon, this.subtitle);
}
