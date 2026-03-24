import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../models/category.dart';
import '../services/api_service.dart';
import 'restaurant_screen.dart';

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
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          title: const Text('البحث',
              style: TextStyle(fontWeight: FontWeight.bold)),
          automaticallyImplyLeading: false,
        ),
        body: Column(
          children: [
            // شريط البحث
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                autofocus: false,
                decoration: InputDecoration(
                  hintText: 'ابحث عن منتج أو تصنيف...',
                  prefixIcon: const Icon(Icons.search),
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
                  fillColor: Colors.white,
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
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('🔍',
                                  style: TextStyle(fontSize: 60)),
                              const SizedBox(height: 16),
                              Text(
                                'ابحث عن منتجاتك المفضلة',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : _categoryResults.isEmpty && _itemResults.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('😔',
                                      style: TextStyle(fontSize: 60)),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'لا توجد نتائج',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'جرب كلمات بحث مختلفة',
                                    style:
                                        TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            )
                          : ListView(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16),
                              children: [
                                // التصنيفات
                                if (_categoryResults.isNotEmpty) ...[
                                  const Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 8),
                                    child: Text('التصنيفات',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16)),
                                  ),
                                  ..._categoryResults.map((cat) => Card(
                                        margin: const EdgeInsets.only(
                                            bottom: 8),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: ListTile(
                                          leading: Container(
                                            width: 44,
                                            height: 44,
                                            decoration: BoxDecoration(
                                              color: Colors.green[50],
                                              shape: BoxShape.circle,
                                            ),
                                            child: Center(
                                              child: Text(
                                                cat.icon ?? '📦',
                                                style: const TextStyle(
                                                    fontSize: 22),
                                              ),
                                            ),
                                          ),
                                          title: Text(cat.name,
                                              style: const TextStyle(
                                                  fontWeight:
                                                      FontWeight.w600)),
                                          trailing: const Icon(
                                              Icons.arrow_forward_ios,
                                              size: 14),
                                        ),
                                      )),
                                ],

                                // المنتجات
                                if (_itemResults.isNotEmpty) ...[
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8),
                                    child: Text(
                                        'المنتجات (${_itemResults.length})',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16)),
                                  ),
                                  ..._itemResults
                                      .map((item) => Card(
                                            margin: const EdgeInsets.only(
                                                bottom: 8),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: ListTile(
                                              leading: Container(
                                                width: 54,
                                                height: 54,
                                                decoration: BoxDecoration(
                                                  color: Colors.green[50],
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8),
                                                ),
                                                child: const Center(
                                                  child: Text('🥦',
                                                      style: TextStyle(
                                                          fontSize: 30)),
                                                ),
                                              ),
                                              title: Text(item.name,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600)),
                                              subtitle: Text(
                                                  '${item.price.toStringAsFixed(0)} ر.ي'),
                                              trailing: const Icon(
                                                  Icons.arrow_forward_ios,
                                                  size: 14),
                                            ),
                                          ))
                                      .toList(),
                                ],

                                const SizedBox(height: 80),
                              ],
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
