import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ui_settings_provider.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ui = context.watch<UiSettingsProvider>();
    final text = ui.privacyPolicyText;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('سياسة الخصوصية',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.privacy_tip, color: Color(0xFF4CAF50)),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'نحن نهتم بخصوصيتك ونحافظ على بياناتك',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              text.isNotEmpty
                  ? Text(text, style: const TextStyle(height: 1.7, fontSize: 15))
                  : _defaultPrivacy(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _defaultPrivacy() {
    const sections = [
      ('جمع البيانات',
          'نقوم بجمع المعلومات الضرورية لتقديم خدماتنا بشكل أفضل، مثل الاسم ورقم الهاتف وعنوان التوصيل.'),
      ('استخدام البيانات',
          'نستخدم بياناتك فقط لمعالجة طلباتك، التواصل معك بشأن حالة الطلبات، وتحسين خدماتنا.'),
      ('حماية البيانات',
          'نستخدم تقنيات تشفير متقدمة لحماية بياناتك الشخصية ومعلوماتك المالية.'),
      ('مشاركة البيانات',
          'لا نبيع أو نشارك بياناتك الشخصية مع أطراف ثالثة إلا لغرض إتمام عملية التوصيل.'),
      ('حذف البيانات',
          'يمكنك طلب حذف حسابك وجميع بياناتك المرتبطة به في أي وقت عبر التواصل معنا.'),
      ('الاتصال بنا',
          'إذا كان لديك أي استفسار حول سياسة الخصوصية، يمكنك التواصل معنا عبر خيارات الدعم في التطبيق.'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sections.map((s) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.$1,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(s.$2,
                  style: const TextStyle(
                      color: Colors.black87, height: 1.6)),
            ],
          ),
        );
      }).toList(),
    );
  }
}
