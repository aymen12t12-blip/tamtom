import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../models/restaurant.dart';
import '../models/menu_item.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/ui_settings_provider.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';
import 'restaurant_screen.dart';
import 'cart_screen.dart';
import 'category_screen.dart';
import 'auth/auth_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _api = ApiService();
  List<Category> _categories = [];
  List<Restaurant> _restaurants = [];
  List<dynamic> _offers = [];
  List<MenuItem> _featuredProducts = [];
  String _selectedCategory = 'all';
  bool _loading = true;
  int _currentOfferIndex = 0;
  Timer? _offerTimer;
  final PageController _offerController = PageController();

  static const Color _primary = Color(0xFF4CAF50);
  static const Color _darkGreen = Color(0xFF2E7D32);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _offerTimer?.cancel();
    _offerController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final results = await Future.wait([
      _api.getCategories(),
      _api.getRestaurants(),
      _api.getSpecialOffers(),
      _api.getFeaturedProducts(),
    ]);
    if (mounted) {
      setState(() {
        _categories = results[0] as List<Category>;
        _restaurants = results[1] as List<Restaurant>;
        _offers = (results[2] as List<dynamic>)
            .where((o) => o['isActive'] == true)
            .toList();
        _featuredProducts = results[3] as List<MenuItem>;
        _loading = false;
      });
      _startOfferTimer();
    }
  }

  void _startOfferTimer() {
    _offerTimer?.cancel();
    if (_offers.length > 1) {
      _offerTimer = Timer.periodic(const Duration(seconds: 5), (_) {
        if (!mounted) return;
        final next = (_currentOfferIndex + 1) % _offers.length;
        _offerController.animateToPage(next,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut);
        setState(() => _currentOfferIndex = next);
      });
    }
  }

  List<Restaurant> get _filteredRestaurants {
    if (_selectedCategory == 'all') return _restaurants;
    return _restaurants
        .where((r) => r.categoryId == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final auth = context.watch<AuthProvider>();
    final ui = context.watch<UiSettingsProvider>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: _buildAppBar(cart),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadData,
                child: CustomScrollView(
                  slivers: [
                    if (ui.showSpecialOffers && _offers.isNotEmpty)
                      SliverToBoxAdapter(child: _buildOffersCarousel()),

                    if (!auth.isAuthenticated)
                      SliverToBoxAdapter(child: _buildGuestBanner(context)),

                    if (ui.showCategories && _categories.isNotEmpty)
                      SliverToBoxAdapter(child: _buildCategories()),

                    if (ui.showFeaturedProducts && _featuredProducts.isNotEmpty)
                      SliverToBoxAdapter(
                          child: _buildFeaturedProducts(context)),

                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Row(
                          children: [
                            const Icon(Icons.store, color: _primary, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              _selectedCategory == 'all'
                                  ? 'جميع المتاجر'
                                  : (_categories
                                          .firstWhere(
                                            (c) => c.id == _selectedCategory,
                                            orElse: () =>
                                                Category(id: '', name: ''),
                                          )
                                          .name),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                            _buildRestaurantCard(_filteredRestaurants[index]),
                        childCount: _filteredRestaurants.length,
                      ),
                    ),

                    if (_filteredRestaurants.isEmpty)
                      const SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(40),
                            child: Text('لا توجد متاجر في هذا التصنيف'),
                          ),
                        ),
                      ),

                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                ),
              ),
      ),
    );
  }

  AppBar _buildAppBar(CartProvider cart) {
    return AppBar(
      backgroundColor: _darkGreen,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('طم',
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Colors.white)),
          Text('طوم',
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Colors.red[300])),
        ],
      ),
      actions: [
        Stack(
          children: [
            IconButton(
              icon:
                  const Icon(Icons.shopping_cart_outlined, color: Colors.white),
              onPressed: () {
                if (cart.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('السلة فارغة')),
                  );
                  return;
                }
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
      centerTitle: true,
    );
  }

  Widget _buildOffersCarousel() {
    final activeOffers = _offers;
    return Container(
      margin: const EdgeInsets.all(16),
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: PageView.builder(
              controller: _offerController,
              onPageChanged: (i) => setState(() => _currentOfferIndex = i),
              itemCount: activeOffers.length,
              itemBuilder: (_, i) {
                final offer = activeOffers[i];
                final imageUrl = offer['image'] as String? ?? '';
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: imageUrl.startsWith('http')
                                ? imageUrl
                                : '${ApiConfig.baseUrl}$imageUrl',
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) =>
                                _offerPlaceholder(offer),
                          )
                        : _offerPlaceholder(offer),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7)
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      right: 16,
                      left: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            offer['title'] as String? ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (offer['description'] != null)
                            Text(
                              offer['description'] as String,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          if (activeOffers.length > 1)
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  activeOffers.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: _currentOfferIndex == i ? 20 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _currentOfferIndex == i
                          ? Colors.white
                          : Colors.white54,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _offerPlaceholder(Map<String, dynamic> offer) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🥬🍅🍇', style: TextStyle(fontSize: 50)),
            const SizedBox(height: 8),
            Text(offer['title'] as String? ?? 'عروض طمطوم',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_primary.withOpacity(0.1), _primary.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_outline, color: _primary, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ابدأ التسوق الآن',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                Text('سجل دخولك لتجربة أفضل',
                    style: TextStyle(
                        color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AuthScreen())),
            style: ElevatedButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text('دخول'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              const Icon(Icons.grid_view, color: _primary, size: 20),
              const SizedBox(width: 8),
              const Text('التصنيفات',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              _buildCategoryChip(id: 'all', name: 'الكل', icon: Icons.grid_view),
              ..._categories.map((c) => _buildCategoryChip(
                    id: c.id,
                    name: c.name,
                    iconEmoji: c.icon,
                    imageUrl: c.image,
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip({
    required String id,
    required String name,
    IconData? icon,
    String? iconEmoji,
    String? imageUrl,
  }) {
    final isSelected = _selectedCategory == id;
    return GestureDetector(
      onTap: () {
        if (id != 'all') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CategoryScreen(categoryName: name),
            ),
          );
        } else {
          setState(() => _selectedCategory = id);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(left: 10),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isSelected ? _primary : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: imageUrl.startsWith('http')
                            ? imageUrl
                            : '${ApiConfig.baseUrl}$imageUrl',
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => _categoryIcon(
                            icon, iconEmoji, isSelected),
                      )
                    : _categoryIcon(icon, iconEmoji, isSelected),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              name,
              style: TextStyle(
                fontSize: 11,
                fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? _primary : Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryIcon(IconData? icon, String? emoji, bool isSelected) {
    return Center(
      child: emoji != null
          ? Text(emoji, style: const TextStyle(fontSize: 26))
          : Icon(
              icon ?? Icons.category,
              color: isSelected ? Colors.white : Colors.grey[600],
              size: 26,
            ),
    );
  }

  Widget _buildFeaturedProducts(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.trending_up, color: _primary, size: 20),
                  const SizedBox(width: 8),
                  const Text('وصل حديثاً',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              TextButton(
                onPressed: () {},
                child: const Text('عرض الكل',
                    style: TextStyle(color: _primary)),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _featuredProducts.take(10).length,
            itemBuilder: (_, i) =>
                _buildFeaturedProductCard(_featuredProducts[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedProductCard(MenuItem item) {
    final imageUrl = _api.resolveImageUrl(item.image);
    return GestureDetector(
      onTap: () {
        final cart = context.read<CartProvider>();
        cart.addItem(item, item.restaurantId ?? '', 'طمطوم');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم إضافة ${item.name} للسلة'),
            duration: const Duration(seconds: 1),
            backgroundColor: _primary,
          ),
        );
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(left: 12, bottom: 8),
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
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
              child: imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      height: 110,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => _productPlaceholder(),
                    )
                  : _productPlaceholder(),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${item.price.toStringAsFixed(0)} ر.ي',
                        style: const TextStyle(
                            color: _darkGreen, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        width: 26,
                        height: 26,
                        decoration: const BoxDecoration(
                            color: _primary, shape: BoxShape.circle),
                        child: const Icon(Icons.add,
                            color: Colors.white, size: 16),
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

  Widget _productPlaceholder() {
    return Container(
      height: 110,
      color: Colors.green[50],
      child:
          const Center(child: Text('🥦', style: TextStyle(fontSize: 44))),
    );
  }

  Widget _buildRestaurantCard(Restaurant restaurant) {
    final imageUrl = _api.resolveImageUrl(restaurant.image);
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => RestaurantScreen(restaurant: restaurant)),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                          height: 160,
                          color: Colors.grey[200],
                          child: const Center(
                              child: CircularProgressIndicator())),
                      errorWidget: (_, __, ___) => _restaurantPlaceholder(),
                    )
                  : _restaurantPlaceholder(),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(restaurant.name,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: restaurant.isOpen
                              ? Colors.green[50]
                              : Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          restaurant.isOpen ? 'مفتوح' : 'مغلق',
                          style: TextStyle(
                            fontSize: 12,
                            color: restaurant.isOpen
                                ? Colors.green[700]
                                : Colors.red[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (restaurant.description != null) ...[
                    const SizedBox(height: 4),
                    Text(restaurant.description!,
                        style:
                            TextStyle(fontSize: 13, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (restaurant.rating != null) ...[
                        Icon(Icons.star, size: 14, color: Colors.amber[600]),
                        const SizedBox(width: 2),
                        Text(restaurant.rating!.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 13)),
                        const SizedBox(width: 12),
                      ],
                      if (restaurant.deliveryTime != null) ...[
                        Icon(Icons.access_time,
                            size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 2),
                        Text(restaurant.deliveryTime!,
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey[600])),
                        const SizedBox(width: 12),
                      ],
                      if (restaurant.deliveryFee != null)
                        Text(
                          restaurant.deliveryFee == 0
                              ? 'توصيل مجاني'
                              : 'توصيل ${restaurant.deliveryFee!.toStringAsFixed(0)} ر.ي',
                          style: TextStyle(
                            fontSize: 13,
                            color: restaurant.deliveryFee == 0
                                ? Colors.green[600]
                                : Colors.grey[600],
                          ),
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

  Widget _restaurantPlaceholder() {
    return Container(
      height: 160,
      width: double.infinity,
      color: Colors.green[50],
      child: const Center(child: Text('🏪', style: TextStyle(fontSize: 60))),
    );
  }
}
