import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  final ApiService _api = ApiService();
  List<dynamic> _addresses = [];
  bool _loading = true;

  static const Color _primary = Color(0xFF4CAF50);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;
    setState(() => _loading = true);
    final addrs = await _api.getAddresses(user.id);
    if (mounted) setState(() {
      _addresses = addrs;
      _loading = false;
    });
  }

  Future<void> _delete(String addressId) async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;
    final ok = await _api.deleteAddress(user.id, addressId);
    if (ok && mounted) {
      setState(() => _addresses.removeWhere((a) => a['id'].toString() == addressId));
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('تم حذف العنوان')));
    }
  }

  Future<void> _addAddress() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    final labelCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final cityCtrl = TextEditingController();

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
              16, 20, 16, MediaQuery.of(context).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('إضافة عنوان جديد',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: labelCtrl,
                decoration: const InputDecoration(
                    labelText: 'تسمية العنوان (مثال: المنزل، العمل)',
                    prefixIcon: Icon(Icons.label)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressCtrl,
                decoration: const InputDecoration(
                    labelText: 'العنوان التفصيلي',
                    prefixIcon: Icon(Icons.location_on)),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: cityCtrl,
                decoration: const InputDecoration(
                    labelText: 'المدينة',
                    prefixIcon: Icon(Icons.location_city)),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (addressCtrl.text.isEmpty) return;
                    final ok = await _api.addAddress(user.id, {
                      'label': labelCtrl.text.trim(),
                      'address': addressCtrl.text.trim(),
                      'city': cityCtrl.text.trim(),
                    });
                    if (mounted) Navigator.pop(context, ok);
                  },
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: const Text('حفظ العنوان'),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (result == true) {
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: const Text('عناويني',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _addAddress,
          backgroundColor: _primary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _addresses.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('📍', style: TextStyle(fontSize: 60)),
                        const SizedBox(height: 16),
                        const Text('لا توجد عناوين محفوظة',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('أضف عنواناً لتسريع عملية الطلب',
                            style: TextStyle(color: Colors.grey[600])),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _addAddress,
                          icon: const Icon(Icons.add),
                          label: const Text('إضافة عنوان'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _addresses.length,
                    itemBuilder: (_, i) {
                      final addr = _addresses[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
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
                        child: ListTile(
                          leading: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.orange[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.location_on,
                                color: Colors.orange),
                          ),
                          title: Text(
                            addr['label'] as String? ?? 'عنوان',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                              '${addr['address'] ?? ''}${addr['city'] != null ? ' - ${addr['city']}' : ''}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.red),
                            onPressed: () => showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('حذف العنوان'),
                                content: const Text(
                                    'هل تريد حذف هذا العنوان؟'),
                                actions: [
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context),
                                      child: const Text('إلغاء')),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _delete(addr['id'].toString());
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red),
                                    child: const Text('حذف'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
