import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/menu_item.dart';
import '../models/category.dart';
import '../providers/cart_provider.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';
import 'category_screen.dart';
import 'product_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ApiService _api = ApiService();
  final _searchController = TextEditingController();
  List<Category> _categoryResults = [];
  List<MenuItem> _itemResults = [];
  bool _hasSearched = false;
  bool _loading = false;

  static const Color _primary = Color(0xFF4CAF50);
  static const Color _darkGreen = Color(0xFF2E7D32);

  Future<void> _search(String query) async {
    if (query.length < 2) {
      setState(() {
        _categoryResults = [];
        _itemResults = [];
        _hasSearched = false;
      });
      return;
    }
    setState(() => _loading = true);
    final data = await _api.search(query);
    if (mounted) {
      setState(() {
        _categoryResults = (data['categories'] as List? ?? [])
            .map((j) => Category.fromJson(j))
            .toList();
        _itemResults = (data['menuItems'] as List? ?? [])
            .map((j) => MenuItem.fromJson(j))
            .toList();
        _hasSearched = true;
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: const Text('البحث',
              style: TextStyle(fontWeight: FontWeight.bold)),
          automaticallyImplyLeading: false,
        ),
        body: Column(
          children: [
            // شريط البحث
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: TextField(
                controller: _searchController,
                autofocus: false,
                decoration: InputDecoration(
                  hintText: 'ابحث عن منتج أو تصنيف...',
                  prefixIcon: const Icon(Icons.search, color: _primary),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _search('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: _search,
                onSubmitted: _search,
              ),
            ),

            // النتائج
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : !_hasSearched
                      ? _buildInitialState()
                      : _categoryResults.isEmpty && _itemResults.isEmpty
                          ? _buildNoResults()
                          : _buildResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔍', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 16),
          Text(
            'ابحث عن منتجاتك المفضلة',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'خضروات، فواكه، وأكثر...',
            style: TextStyle(color: Colors.grey[400], fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('😔', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 16),
          const Text('لا توجد نتائج',
              style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('جرب كلمات بحث مختلفة',
              style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildResults() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        // التصنيفات
        if (_categoryResults.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('التصنيفات',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          ..._categoryResults.map((cat) => GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        CategoryScreen(categoryName: cat.name),
                  ),
                ),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4)
                    ],
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: cat.image != null && cat.image!.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: cat.image!.startsWith('http')
                                    ? cat.image!
                                    : '${ApiConfig.baseUrl}${cat.image}',
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) => Center(
                                  child: Text(cat.icon ?? '📦',
                                      style: const TextStyle(
                                          fontSize: 20)),
                                ),
                              )
                            : Center(
                                child: Text(cat.icon ?? '📦',
                                    style: const TextStyle(
                                        fontSize: 20)),
                              ),
                      ),
                    ),
                    title: Text(cat.name,
                        style:
                            const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle:
                        cat.description != null ? Text(cat.description!) : null,
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  ),
                ),
              )),
        ],

        // المنتجات
        if (_itemResults.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text('المنتجات (${_itemResults.length})',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          ..._itemResults.map((item) {
            final imageUrl = item.image != null && item.image!.isNotEmpty
                ? (item.image!.startsWith('http')
                    ? item.image!
                    : '${ApiConfig.baseUrl}${item.image}')
                : '';
            final cart = context.watch<CartProvider>();
            final quantity = cart.getQuantity(item.id);

            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ProductDetailScreen(item: item)),
              ),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4)
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: imageUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: imageUrl,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) =>
                                    _placeholder(),
                              )
                            : _placeholder(),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            if (item.description != null)
                              Text(item.description!,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600]),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Text(
                              '${item.price.toStringAsFixed(0)} ر.ي',
                              style: const TextStyle(
                                  color: _darkGreen,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      if (item.isAvailable)
                        quantity == 0
                            ? GestureDetector(
                                onTap: () {
                                  context.read<CartProvider>().addItem(
                                      item,
                                      item.restaurantId ?? '',
                                      'طمطوم');
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    SnackBar(
                                      content:
                                          Text('تم إضافة ${item.name}'),
                                      duration:
                                          const Duration(seconds: 1),
                                      backgroundColor: _primary,
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 34,
                                  height: 34,
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
                                      width: 28,
                                      height: 28,
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
                                            fontWeight:
                                                FontWeight.bold)),
                                  ),
                                  GestureDetector(
                                    onTap: () => context
                                        .read<CartProvider>()
                                        .addItem(item,
                                            item.restaurantId ?? '',
                                            'طمطوم'),
                                    child: Container(
                                      width: 28,
                                      height: 28,
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
                ),
              ),
            );
          }),
        ],

        const SizedBox(height: 80),
      ],
    );
  }

  Widget _placeholder() {
    return Container(
      width: 60,
      height: 60,
      color: Colors.green[50],
      child:
          const Center(child: Text('🥦', style: TextStyle(fontSize: 28))),
    );
  }
}
