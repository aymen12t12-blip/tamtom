import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../models/menu_item.dart';
import '../providers/cart_provider.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';
import 'cart_screen.dart';
import 'product_detail_screen.dart';

class CategoryScreen extends StatefulWidget {
  final String categoryName;
  const CategoryScreen({super.key, required this.categoryName});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final ApiService _api = ApiService();
  List<MenuItem> _items = [];
  List<MenuItem> _filtered = [];
  bool _loading = true;
  String _sortBy = 'default';

  static const Color _primary = Color(0xFF4CAF50);
  static const Color _darkGreen = Color(0xFF2E7D32);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final items = await _api.getProductsByCategory(widget.categoryName);
    if (mounted) {
      setState(() {
        _items = items;
        _applySort();
        _loading = false;
      });
    }
  }

  void _applySort() {
    final list = List<MenuItem>.from(_items);
    if (_sortBy == 'price_asc') {
      list.sort((a, b) => a.price.compareTo(b.price));
    } else if (_sortBy == 'price_desc') {
      list.sort((a, b) => b.price.compareTo(a.price));
    }
    _filtered = list;
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: Text(widget.categoryName,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.sort),
              onSelected: (val) {
                setState(() {
                  _sortBy = val;
                  _applySort();
                });
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'default', child: Text('الافتراضي')),
                const PopupMenuItem(
                    value: 'price_asc', child: Text('السعر: من الأقل')),
                const PopupMenuItem(
                    value: 'price_desc', child: Text('السعر: من الأعلى')),
              ],
            ),
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined),
                  onPressed: () {
                    if (cart.isEmpty) return;
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const CartScreen()));
                  },
                ),
                if (cart.itemCount > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                          color: Colors.orange, shape: BoxShape.circle),
                      constraints:
                          const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text('${cart.itemCount}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center),
                    ),
                  ),
              ],
            ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _filtered.isEmpty
                ? _buildEmpty()
                : RefreshIndicator(
                    onRefresh: _load,
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: _filtered.length,
                      itemBuilder: (_, i) => _buildProductCard(_filtered[i]),
                    ),
                  ),
        bottomNavigationBar: cart.isEmpty ? null : _buildCartBar(cart),
      ),
    );
  }

  Widget _buildProductCard(MenuItem item) {
    final cart = context.watch<CartProvider>();
    final quantity = cart.getQuantity(item.id);
    final imageUrl = item.image != null && item.image!.isNotEmpty
        ? (item.image!.startsWith('http')
            ? item.image!
            : '${ApiConfig.baseUrl}${item.image}')
        : '';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailScreen(item: item),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 6,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(14)),
                    child: imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => _placeholder(),
                          )
                        : _placeholder(),
                  ),
                  if (!item.isAvailable)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(14)),
                        ),
                        child: const Center(
                          child: Text('غير متاح',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${item.price.toStringAsFixed(0)} ر.ي',
                            style: const TextStyle(
                                color: _darkGreen,
                                fontWeight: FontWeight.bold,
                                fontSize: 14),
                          ),
                          if (item.unit != null)
                            Text(item.unit!,
                                style: TextStyle(
                                    color: Colors.grey[500], fontSize: 11)),
                        ],
                      ),
                      if (item.isAvailable)
                        quantity == 0
                            ? GestureDetector(
                                onTap: () {
                                  context.read<CartProvider>().addItem(
                                      item,
                                      item.restaurantId ?? '',
                                      'طمطوم');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('تم إضافة ${item.name}'),
                                      duration:
                                          const Duration(seconds: 1),
                                      backgroundColor: _primary,
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: const BoxDecoration(
                                      color: _primary,
                                      shape: BoxShape.circle),
                                  child: const Icon(Icons.add,
                                      color: Colors.white, size: 18),
                                ),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                    onTap: () => context
                                        .read<CartProvider>()
                                        .updateQuantity(
                                            item.id, quantity - 1),
                                    child: Container(
                                      width: 26,
                                      height: 26,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: _primary),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.remove,
                                          size: 14, color: _primary),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6),
                                    child: Text('$quantity',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  GestureDetector(
                                    onTap: () => context
                                        .read<CartProvider>()
                                        .addItem(item,
                                            item.restaurantId ?? '',
                                            'طمطوم'),
                                    child: Container(
                                      width: 26,
                                      height: 26,
                                      decoration: const BoxDecoration(
                                          color: _primary,
                                          shape: BoxShape.circle),
                                      child: const Icon(Icons.add,
                                          size: 14, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: Colors.green[50],
      child:
          const Center(child: Text('🥦', style: TextStyle(fontSize: 48))),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📦', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 16),
          Text('لا توجد منتجات في ${widget.categoryName}',
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildCartBar(CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, -2))
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const CartScreen())),
          style: ElevatedButton.styleFrom(
            backgroundColor: _primary,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('${cart.itemCount} عنصر',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const Text('عرض السلة',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              Text('${cart.subtotal.toStringAsFixed(0)} ر.ي',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
