import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../models/menu_item.dart';
import '../providers/cart_provider.dart';
import '../services/api_service.dart';
import 'cart_screen.dart';

class ProductDetailScreen extends StatelessWidget {
  final MenuItem item;
  const ProductDetailScreen({super.key, required this.item});

  static const Color _primary = Color(0xFF4CAF50);
  static const Color _darkGreen = Color(0xFF2E7D32);

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final quantity = cart.getQuantity(item.id);
    final api = ApiService();
    final imageUrl = api.resolveImageUrl(item.image);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              backgroundColor: _darkGreen,
              flexibleSpace: FlexibleSpaceBar(
                background: imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => _placeholder(),
                      )
                    : _placeholder(),
              ),
              actions: [
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.shopping_cart_outlined,
                          color: Colors.white),
                      onPressed: () {
                        if (cart.isEmpty) return;
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const CartScreen()));
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
                          constraints: const BoxConstraints(
                              minWidth: 16, minHeight: 16),
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
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (!item.isAvailable)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red),
                            ),
                            child: Text('غير متاح',
                                style: TextStyle(
                                    color: Colors.red[700],
                                    fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '${item.price.toStringAsFixed(2)} ر.ي',
                          style: const TextStyle(
                              color: _darkGreen,
                              fontSize: 24,
                              fontWeight: FontWeight.bold),
                        ),
                        if (item.unit != null) ...[
                          const SizedBox(width: 6),
                          Text('/ ${item.unit}',
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 16)),
                        ],
                      ],
                    ),
                    if (item.category != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.category!,
                          style: const TextStyle(
                              color: _primary,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                    const Divider(height: 32),
                    if (item.description != null &&
                        item.description!.isNotEmpty) ...[
                      const Text('الوصف',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(
                        item.description!,
                        style:
                            TextStyle(color: Colors.grey[700], height: 1.6),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.local_shipping_outlined,
                              color: _primary),
                          const SizedBox(width: 10),
                          const Text('توصيل سريع لباب منزلك',
                              style:
                                  TextStyle(fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: item.isAvailable
            ? Container(
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
                  child: quantity == 0
                      ? ElevatedButton.icon(
                          onPressed: () {
                            context.read<CartProvider>().addItem(
                                item, item.restaurantId ?? '', 'طمطوم');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('تم إضافة ${item.name} للسلة'),
                                backgroundColor: _primary,
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add_shopping_cart),
                          label: const Text('إضافة للسلة',
                              style: TextStyle(fontSize: 16)),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 52),
                          ),
                        )
                      : Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: _primary),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove,
                                        color: _primary),
                                    onPressed: () => context
                                        .read<CartProvider>()
                                        .updateQuantity(
                                            item.id, quantity - 1),
                                  ),
                                  Text('$quantity',
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                  IconButton(
                                    icon: const Icon(Icons.add,
                                        color: _primary),
                                    onPressed: () => context
                                        .read<CartProvider>()
                                        .addItem(item,
                                            item.restaurantId ?? '', 'طمطوم'),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const CartScreen())),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(0, 52),
                                ),
                                child: Text(
                                  'عرض السلة (${cart.itemCount})',
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              )
            : Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: SafeArea(
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text('هذا المنتج غير متاح حالياً',
                          style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: Colors.green[100],
      child: const Center(child: Text('🥦', style: TextStyle(fontSize: 80))),
    );
  }
}
