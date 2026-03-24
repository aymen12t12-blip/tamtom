import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/restaurant.dart';
import '../models/menu_item.dart';
import '../providers/cart_provider.dart';
import '../services/api_service.dart';
import 'cart_screen.dart';

class RestaurantScreen extends StatefulWidget {
  final Restaurant restaurant;
  const RestaurantScreen({super.key, required this.restaurant});

  @override
  State<RestaurantScreen> createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends State<RestaurantScreen> {
  final ApiService _api = ApiService();
  List<MenuItem> _menuItems = [];
  List<String> _categories = [];
  String _selectedCategory = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMenu();
  }

  Future<void> _loadMenu() async {
    final items = await _api.getMenuItems(widget.restaurant.id);
    if (mounted) {
      final cats = items.map((i) => i.category ?? 'عام').toSet().toList();
      setState(() {
        _menuItems = items;
        _categories = cats;
        _selectedCategory = cats.isNotEmpty ? cats[0] : '';
        _loading = false;
      });
    }
  }

  List<MenuItem> get _filteredItems {
    return _menuItems
        .where((i) => (i.category ?? 'عام') == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: CustomScrollView(
          slivers: [
            // صورة المطعم مع تأثير parallax
            SliverAppBar(
              expandedHeight: 220,
              pinned: true,
              backgroundColor: const Color(0xFF2E7D32),
              flexibleSpace: FlexibleSpaceBar(
                background: widget.restaurant.image != null &&
                        widget.restaurant.image!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: widget.restaurant.image!.startsWith('http')
                            ? widget.restaurant.image!
                            : 'https://99b4d7e9-c93f-45c5-b450-66829a4d2865-00-lubjf8dozjuc.sisko.replit.dev${widget.restaurant.image}',
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Container(
                          color: Colors.green[100],
                          child: const Center(
                              child: Text('🏪', style: TextStyle(fontSize: 80))),
                        ),
                      )
                    : Container(
                        color: Colors.green[100],
                        child: const Center(
                            child:
                                Text('🏪', style: TextStyle(fontSize: 80))),
                      ),
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
                          MaterialPageRoute(builder: (_) => const CartScreen()),
                        );
                      },
                    ),
                    if (cart.itemCount > 0)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '${cart.itemCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),

            // معلومات المطعم
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.restaurant.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: widget.restaurant.isOpen
                                ? Colors.green[50]
                                : Colors.red[50],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: widget.restaurant.isOpen
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                          child: Text(
                            widget.restaurant.isOpen ? 'مفتوح' : 'مغلق',
                            style: TextStyle(
                              color: widget.restaurant.isOpen
                                  ? Colors.green[700]
                                  : Colors.red[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (widget.restaurant.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        widget.restaurant.description!,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        if (widget.restaurant.rating != null) ...[
                          Icon(Icons.star, size: 16, color: Colors.amber[600]),
                          const SizedBox(width: 2),
                          Text(widget.restaurant.rating!.toStringAsFixed(1)),
                          const SizedBox(width: 16),
                        ],
                        if (widget.restaurant.deliveryTime != null) ...[
                          const Icon(Icons.access_time,
                              size: 16, color: Colors.grey),
                          const SizedBox(width: 2),
                          Text(widget.restaurant.deliveryTime!),
                          const SizedBox(width: 16),
                        ],
                        if (widget.restaurant.minimumOrder != null &&
                            widget.restaurant.minimumOrder! > 0) ...[
                          const Icon(Icons.shopping_bag_outlined,
                              size: 16, color: Colors.grey),
                          const SizedBox(width: 2),
                          Text(
                              'أدنى طلب: ${widget.restaurant.minimumOrder!.toStringAsFixed(0)}'),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // تصنيفات القائمة
            if (_categories.isNotEmpty)
              SliverPersistentHeader(
                pinned: true,
                delegate: _CategoryHeaderDelegate(
                  categories: _categories,
                  selected: _selectedCategory,
                  onSelected: (c) => setState(() => _selectedCategory = c),
                ),
              ),

            // عناصر القائمة
            if (_loading)
              const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) =>
                      _buildMenuItemCard(context, _filteredItems[i]),
                  childCount: _filteredItems.length,
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
        bottomNavigationBar: cart.isEmpty
            ? null
            : _buildCartBar(context, cart),
      ),
    );
  }

  Widget _buildMenuItemCard(BuildContext context, MenuItem item) {
    final cart = context.watch<CartProvider>();
    final quantity = cart.getQuantity(item.id);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // صورة العنصر
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: item.image != null && item.image!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: item.image!.startsWith('http')
                          ? item.image!
                          : 'https://99b4d7e9-c93f-45c5-b450-66829a4d2865-00-lubjf8dozjuc.sisko.replit.dev${item.image}',
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => _itemPlaceholder(),
                    )
                  : _itemPlaceholder(),
            ),
            const SizedBox(width: 12),
            // معلومات العنصر
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  if (item.description != null && item.description!.isNotEmpty)
                    Text(
                      item.description!,
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${item.price.toStringAsFixed(0)} ر.ي${item.unit != null ? '/${item.unit}' : ''}',
                        style: const TextStyle(
                          color: Color(0xFF2E7D32),
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      // أزرار الكمية
                      if (!item.isAvailable)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('غير متاح',
                              style: TextStyle(
                                  color: Colors.grey, fontSize: 12)),
                        )
                      else if (quantity == 0)
                        GestureDetector(
                          onTap: () {
                            context.read<CartProvider>().addItem(
                                  item,
                                  widget.restaurant.id,
                                  widget.restaurant.name,
                                );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('تم إضافة ${item.name}'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              color: Color(0xFF4CAF50),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.add,
                                color: Colors.white, size: 20),
                          ),
                        )
                      else
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => context
                                  .read<CartProvider>()
                                  .updateQuantity(item.id, quantity - 1),
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: const Color(0xFF4CAF50)),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.remove,
                                    size: 16, color: Color(0xFF4CAF50)),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                '$quantity',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => context
                                  .read<CartProvider>()
                                  .addItem(
                                    item,
                                    widget.restaurant.id,
                                    widget.restaurant.name,
                                  ),
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF4CAF50),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.add,
                                    size: 16, color: Colors.white),
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

  Widget _itemPlaceholder() {
    return Container(
      width: 80,
      height: 80,
      color: Colors.green[50],
      child: const Center(child: Text('🥦', style: TextStyle(fontSize: 36))),
    );
  }

  Widget _buildCartBar(BuildContext context, CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2))
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartScreen()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
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
                child: Text(
                  '${cart.itemCount} عنصر',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Text(
                'عرض السلة',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${cart.subtotal.toStringAsFixed(0)} ر.ي',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryHeaderDelegate extends SliverPersistentHeaderDelegate {
  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelected;

  _CategoryHeaderDelegate({
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: categories.length,
        itemBuilder: (context, i) {
          final cat = categories[i];
          final isSelected = cat == selected;
          return GestureDetector(
            onTap: () => onSelected(cat),
            child: Container(
              margin: const EdgeInsets.only(left: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF4CAF50)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                cat,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[700],
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  double get maxExtent => 56;

  @override
  double get minExtent => 56;

  @override
  bool shouldRebuild(_CategoryHeaderDelegate oldDelegate) =>
      selected != oldDelegate.selected || categories != oldDelegate.categories;
}
