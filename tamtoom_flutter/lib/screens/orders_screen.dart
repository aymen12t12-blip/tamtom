import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/order.dart';
import '../services/api_service.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _api = ApiService();
  final _trackController = TextEditingController();
  List<Order> _myOrders = [];
  Order? _trackedOrder;
  bool _loading = false;
  bool _tracking = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final user = context.read<AuthProvider>().user;
    if (user?.phone == null) return;
    setState(() => _loading = true);
    final orders = await _api.getOrdersByPhone(user!.phone!);
    if (mounted) setState(() {
      _myOrders = orders;
      _loading = false;
    });
  }

  Future<void> _trackOrder() async {
    final num = _trackController.text.trim();
    if (num.isEmpty) return;
    setState(() => _tracking = true);
    final order = await _api.getOrderByNumber(num);
    if (mounted) {
      setState(() {
        _trackedOrder = order;
        _tracking = false;
      });
      if (order == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لم يتم العثور على هذا الطلب')),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _trackController.dispose();
    super.dispose();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'confirmed': return Colors.blue;
      case 'preparing': return Colors.purple;
      case 'on_way': return Colors.teal;
      case 'delivered': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          title: const Text('طلباتي',
              style: TextStyle(fontWeight: FontWeight.bold)),
          automaticallyImplyLeading: false,
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'طلباتي'),
              Tab(text: 'تتبع طلب'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // تبويب طلباتي
            _buildMyOrders(auth),
            // تبويب تتبع طلب
            _buildTrackOrder(),
          ],
        ),
      ),
    );
  }

  Widget _buildMyOrders(AuthProvider auth) {
    if (!auth.isAuthenticated) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('📋', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 16),
            const Text('سجل دخولك لعرض طلباتك',
                style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pushNamed(context, '/auth'),
              child: const Text('تسجيل الدخول'),
            ),
          ],
        ),
      );
    }

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_myOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('📦', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 16),
            const Text('لا توجد طلبات حتى الآن',
                style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('ابدأ بطلب شيء لذيذ!',
                style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _myOrders.length,
        itemBuilder: (_, i) => _buildOrderCard(_myOrders[i]),
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.orderNumber ?? order.id.substring(0, 8),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        _statusColor(order.status).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    order.statusLabel,
                    style: TextStyle(
                      color: _statusColor(order.status),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (order.restaurantName != null)
              Text(order.restaurantName!,
                  style: TextStyle(color: Colors.grey[700])),
            const SizedBox(height: 4),
            Text(
              'الإجمالي: ${order.total?.toStringAsFixed(0) ?? '0'} ر.ي',
              style: const TextStyle(
                  color: Color(0xFF2E7D32), fontWeight: FontWeight.bold),
            ),
            if (order.createdAt != null) ...[
              const SizedBox(height: 4),
              Text(
                _formatDate(order.createdAt!),
                style:
                    TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
            if (order.driverName != null &&
                order.status == 'on_way') ...[
              const Divider(),
              Row(
                children: [
                  const Icon(Icons.delivery_dining,
                      color: Color(0xFF4CAF50), size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'السائق: ${order.driverName}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  if (order.driverPhone != null)
                    IconButton(
                      icon: const Icon(Icons.phone,
                          color: Color(0xFF4CAF50)),
                      onPressed: () {},
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTrackOrder() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'تتبع طلبك',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _trackController,
                  decoration: const InputDecoration(
                    hintText: 'أدخل رقم الطلب',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _tracking ? null : _trackOrder,
                child: _tracking
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('بحث'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_trackedOrder != null) _buildTrackedOrderDetails(_trackedOrder!),
        ],
      ),
    );
  }

  Widget _buildTrackedOrderDetails(Order order) {
    final steps = [
      ('pending', 'تم الاستلام', Icons.receipt),
      ('confirmed', 'تم التأكيد', Icons.check_circle),
      ('preparing', 'قيد التحضير', Icons.restaurant),
      ('on_way', 'في الطريق', Icons.delivery_dining),
      ('delivered', 'تم التوصيل', Icons.home),
    ];

    final currentIndex =
        steps.indexWhere((s) => s.$1 == order.status);

    return Card(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'طلب: ${order.orderNumber ?? order.id}',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16),
            ),
            if (order.restaurantName != null)
              Text(order.restaurantName!,
                  style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 16),
            // خطوات التتبع
            ...steps.asMap().entries.map((entry) {
              final idx = entry.key;
              final step = entry.value;
              final isDone = currentIndex >= idx;
              final isCurrent = currentIndex == idx;
              return Row(
                children: [
                  Column(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isDone
                              ? const Color(0xFF4CAF50)
                              : Colors.grey[200],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(step.$3,
                            size: 18,
                            color: isDone
                                ? Colors.white
                                : Colors.grey[400]),
                      ),
                      if (idx < steps.length - 1)
                        Container(
                          width: 2,
                          height: 30,
                          color: isDone && currentIndex > idx
                              ? const Color(0xFF4CAF50)
                              : Colors.grey[200],
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        step.$2,
                        style: TextStyle(
                          fontWeight: isCurrent
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isCurrent
                              ? const Color(0xFF2E7D32)
                              : isDone
                                  ? Colors.black87
                                  : Colors.grey[400],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
