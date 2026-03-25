import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/order.dart';
import '../services/api_service.dart';
import 'order_tracking_screen.dart';
import 'auth/auth_screen.dart';

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

  static const Color _primary = Color(0xFF4CAF50);
  static const Color _darkGreen = Color(0xFF2E7D32);

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
    if (mounted) {
      setState(() {
        _myOrders = orders;
        _loading = false;
      });
    }
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
    final auth = context.watch<AuthProvider>();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: const Text('طلباتي',
              style: TextStyle(fontWeight: FontWeight.bold)),
          automaticallyImplyLeading: false,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: _primary,
            labelColor: _primary,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: 'طلباتي'),
              Tab(text: 'تتبع طلب'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildMyOrders(auth),
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AuthScreen())),
              child: const Text('تسجيل الدخول'),
            ),
          ],
        ),
      );
    }

    if (_loading) return const Center(child: CircularProgressIndicator());

    if (_myOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('📦', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 16),
            const Text('لا توجد طلبات حتى الآن',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('ابدأ بطلب منتجاتك المفضلة!',
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
    final isActive = ['pending', 'confirmed', 'preparing', 'on_way']
        .contains(order.status);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OrderTrackingScreen(order: order),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 6,
                offset: const Offset(0, 2))
          ],
          border: isActive
              ? Border.all(color: _primary.withOpacity(0.3), width: 1.5)
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (isActive)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 8),
                          decoration: const BoxDecoration(
                              color: _primary, shape: BoxShape.circle),
                        ),
                      Text(
                        '#${order.orderNumber ?? order.id.substring(0, 8)}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor(order.status).withOpacity(0.15),
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
                Row(
                  children: [
                    const Icon(Icons.store, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(order.restaurantName!,
                        style: TextStyle(color: Colors.grey[700])),
                  ],
                ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${order.total?.toStringAsFixed(0) ?? '0'} ر.ي',
                    style: const TextStyle(
                        color: _darkGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
                  ),
                  if (order.createdAt != null)
                    Text(
                      _formatDate(order.createdAt!),
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                ],
              ),
              if (isActive) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on, size: 14, color: _primary),
                      const SizedBox(width: 4),
                      Text('اضغط لتتبع الطلب',
                          style: TextStyle(
                              color: Colors.green[700],
                              fontSize: 12,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrackOrder() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('تتبع طلبك',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _trackController,
                        decoration: InputDecoration(
                          hintText: 'أدخل رقم الطلب',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _tracking ? null : _trackOrder,
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 16)),
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
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_trackedOrder != null)
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        OrderTrackingScreen(order: _trackedOrder!)),
              ),
              child: _buildTrackedOrderCard(_trackedOrder!),
            ),
        ],
      ),
    );
  }

  Widget _buildTrackedOrderCard(Order order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '#${order.orderNumber ?? order.id.substring(0, 8)}',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (order.restaurantName != null)
            Text(order.restaurantName!,
                style: TextStyle(color: Colors.grey[700])),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.touch_app, size: 16, color: _primary),
              const SizedBox(width: 4),
              const Text('اضغط لعرض تفاصيل التتبع',
                  style: TextStyle(color: _primary, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) =>
      '${date.day}/${date.month}/${date.year}  ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
}
