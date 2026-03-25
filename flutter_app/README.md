# تطبيق طمطوم - Flutter

تطبيق جوال لمتجر طمطوم للخضار والفواكه. مبني باستخدام Flutter مع عرض موقع الويب داخله + ميزات أصلية.

## ✨ الميزات

- 🌐 **WebView** - عرض متجر طمطوم كاملاً داخل التطبيق
- 🔔 **Push Notifications** - إشعارات الطلبات عبر Firebase FCM
- 🎨 **Splash Screen** - شاشة بداية متحركة قابلة للتحكم من لوحة الإدارة
- 🎨 **Theme Control** - تحكم في ألوان التطبيق من لوحة الإدارة عن بُعد
- 🌙 **Dark Mode** - دعم الوضع الليلي تلقائياً
- 📶 **Offline Detection** - كشف انقطاع الإنترنت مع رسالة مناسبة
- 🔒 **Privacy Policy** - صفحة سياسة الخصوصية داخل التطبيق

---

## 📋 متطلبات التثبيت

- Flutter SDK 3.24+
- Dart 3.3+
- Android Studio / VS Code
- حساب Firebase

---

## 🚀 خطوات الإعداد

### 1. تثبيت Flutter
```bash
# تحميل Flutter من الموقع الرسمي
https://docs.flutter.dev/get-started/install

# التحقق من التثبيت
flutter doctor
```

### 2. إعداد Firebase

1. اذهب إلى [Firebase Console](https://console.firebase.google.com/)
2. أنشئ مشروعاً جديداً باسم `tamtom-store`
3. أضف تطبيق Android:
   - **Package name**: `com.tamtom.store`
   - حمّل ملف `google-services.json` وضعه في `android/app/`
4. فعّل **Firebase Cloud Messaging (FCM)**
5. احصل على **Server Key** من: Project Settings → Cloud Messaging

### 3. تحديث إعدادات Firebase في الكود

في ملف `lib/main.dart` استبدل القيم التالية بقيم مشروعك:
```dart
await Firebase.initializeApp(
  options: const FirebaseOptions(
    apiKey: 'AIzaSy...',           // من Firebase Console
    appId: '1:123456:android:abc', // من Firebase Console  
    messagingSenderId: '123456',   // Project Number
    projectId: 'tamtom-store',     // Project ID
    storageBucket: 'tamtom-store.appspot.com',
  ),
);
```

### 4. إضافة FCM Server Key للسيرفر

في Replit أو Render، أضف متغير البيئة:
```
FCM_SERVER_KEY=AAAAxxxxxxx...
```

(احصل عليه من: Firebase Console → Project Settings → Cloud Messaging → Server Key)

### 5. تشغيل التطبيق

```bash
# داخل مجلد flutter_app
cd flutter_app

# تثبيت الحزم
flutter pub get

# تشغيل في وضع التطوير
flutter run

# بناء APK
flutter build apk --release
```

---

## 🤖 البناء التلقائي (GitHub Actions)

الملف `.github/workflows/build_apk.yml` يبني APK تلقائياً عند كل push.

### إعداد Secrets في GitHub:

| Secret | الوصف |
|--------|--------|
| `GOOGLE_SERVICES_JSON` | محتوى ملف google-services.json كـ base64 |
| `KEYSTORE_BASE64` | ملف الـ keystore كـ base64 |
| `KEY_ALIAS` | اسم المفتاح |
| `KEY_PASSWORD` | كلمة مرور المفتاح |
| `STORE_PASSWORD` | كلمة مرور الـ keystore |

### تحويل الملفات إلى base64:
```bash
# تحويل google-services.json
base64 -i android/app/google-services.json | tr -d '\n'

# تحويل keystore
base64 -i tamtom.jks | tr -d '\n'
```

### إنشاء Keystore للنشر:
```bash
keytool -genkey -v \
  -keystore tamtom-keystore.jks \
  -alias tamtom \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000
```

---

## 🎨 التحكم في الثيمات والسبلاش من لوحة الإدارة

اذهب إلى لوحة الإدارة → إعدادات الواجهة، وقم بتعديل:

| الإعداد | المفتاح | الوصف |
|---------|---------|--------|
| صورة السبلاش | `splash_image_url` | رابط صورة شاشة البداية |
| عنوان السبلاش | `splash_title` | عنوان شاشة البداية |
| نص السبلاش | `splash_subtitle` | النص التوضيحي |
| مدة السبلاش | `splash_duration` | المدة بالميلي ثانية (3000 = 3 ثوان) |
| لون الخلفية | `splash_background_color` | لون خلفية السبلاش (hex) |
| اللون الأساسي | `primary_color` | اللون الرئيسي للتطبيق (hex) |
| اللون الثانوي | `secondary_color` | اللون الثانوي (hex) |

---

## 📡 إرسال الإشعارات

من لوحة الإدارة أو مباشرة عبر API:

```bash
curl -X POST https://tamtomsture.onrender.com/api/flutter/send-notification \
  -H "Content-Type: application/json" \
  -H "x-admin-token: YOUR_ADMIN_TOKEN" \
  -d '{
    "title": "عرض خاص!",
    "body": "خصم 20% على جميع الفواكه اليوم"
  }'
```

---

## 📁 هيكل المشروع

```
flutter_app/
├── lib/
│   ├── main.dart                    # نقطة البداية
│   ├── screens/
│   │   ├── splash_screen.dart       # شاشة البداية المتحركة
│   │   ├── web_screen.dart          # شاشة WebView
│   │   └── privacy_screen.dart      # سياسة الخصوصية
│   └── services/
│       ├── config_service.dart      # جلب الإعدادات من API
│       └── notification_service.dart # إدارة FCM
├── android/
│   ├── app/
│   │   ├── build.gradle             # إعدادات البناء
│   │   ├── google-services.json     # [تضاف يدوياً من Firebase]
│   │   └── src/main/
│   │       ├── AndroidManifest.xml  # الصلاحيات
│   │       └── kotlin/.../          # كود Kotlin
│   └── gradle.properties            # إعدادات Gradle
├── assets/
│   ├── fonts/                       # خط Cairo [تضاف يدوياً]
│   └── images/
├── .github/workflows/
│   └── build_apk.yml               # بناء تلقائي
└── pubspec.yaml                    # تبعيات المشروع
```

---

## 📱 الصلاحيات المطلوبة

| الصلاحية | السبب | وقت الطلب |
|----------|--------|------------|
| INTERNET | الوصول للمتجر | تلقائي |
| NOTIFICATIONS | إشعارات الطلبات | عند أول تشغيل |
| NETWORK_STATE | كشف الاتصال | تلقائي |
| STORAGE | التخزين المؤقت | عند الحاجة |

---

## 📜 سياسة Google Play

هذا التطبيق ليس "متصفحاً بسيطاً" لأنه يحتوي على:
- ✅ إشعارات FCM أصلية
- ✅ شاشة سبلاش متحركة مع تحكم عن بُعد
- ✅ ثيمات قابلة للتخصيص
- ✅ كشف حالة الشبكة
- ✅ صفحة سياسة الخصوصية
- ✅ تخزين محلي للإعدادات
- ✅ تكامل مع API الخاص بالمتجر

---

## 🆘 استكشاف الأخطاء

**المشكلة**: التطبيق لا يستقبل الإشعارات
- تأكد من وجود `google-services.json` في `android/app/`
- تأكد من إضافة `FCM_SERVER_KEY` في السيرفر
- تحقق من صلاحية الإشعارات في إعدادات الجهاز

**المشكلة**: شاشة السبلاش لا تتغير
- التطبيق يجلب الإعدادات عند كل تشغيل من: `/api/flutter/app-config`
- تأكد من حفظ التغييرات في لوحة الإدارة

**المشكلة**: فشل البناء
```bash
flutter clean
flutter pub get
flutter build apk --release
```
