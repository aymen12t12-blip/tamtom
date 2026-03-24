# تطبيق طمطوم للعميل - Flutter

تطبيق للهاتف يتصل بسيرفر طمطوم لتوصيل الخضروات والفواكه الطازجة.

---

## 📋 الميزات

- **الصفحة الرئيسية**: تصنيفات المتاجر والعروض
- **صفحة المتجر**: قائمة المنتجات مع التصنيفات
- **سلة الطلبات**: إضافة منتجات + حساب رسوم التوصيل + كوبون خصم + طريقة دفع
- **البحث**: البحث عن منتجات وتصنيفات
- **طلباتي**: عرض الطلبات السابقة + تتبع طلب
- **المفضلة**: المنتجات المحفوظة
- **الملف الشخصي**: بيانات المستخدم + تسجيل الدخول/الخروج
- **المصادقة**: تسجيل الدخول + إنشاء حساب جديد

---

## 🚀 كيفية تشغيل التطبيق

### المتطلبات الأساسية

1. تثبيت **Flutter SDK** من [flutter.dev](https://flutter.dev/docs/get-started/install)
2. تثبيت **Android Studio** أو **VS Code** مع إضافة Flutter

### خطوات التثبيت والتشغيل

```bash
# 1. انتقل إلى مجلد المشروع
cd tamtoom_flutter

# 2. تثبيت الاعتمادية
flutter pub get

# 3. تشغيل على المحاكي أو الهاتف
flutter run

# 4. بناء APK للهاتف
flutter build apk --release

# 5. تثبيت APK على الهاتف
flutter install
```

---

## ⚙️ تهيئة السيرفر

افتح الملف: `lib/config/api_config.dart`

```dart
// غيّر هذا العنوان إلى عنوان سيرفرك
static const String baseUrl = 'https://your-server.replit.app';
```

### عناوين متاحة:
| البيئة | العنوان |
|--------|---------|
| محاكي أندرويد | `http://10.0.2.2:5000` |
| محاكي iOS | `http://localhost:5000` |
| هاتف حقيقي (شبكة محلية) | `http://192.168.x.x:5000` |
| سيرفر Replit (مُنشر) | `https://your-domain.replit.app` |

---

## 📦 بناء APK للهاتف

```bash
# بناء APK في وضع Release (حجم أصغر وأداء أفضل)
flutter build apk --release

# ملف APK يكون في:
# build/app/outputs/flutter-apk/app-release.apk
```

### تثبيت APK على الهاتف:

**الطريقة الأولى - عبر الأمر:**
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

**الطريقة الثانية - نقل الملف:**
1. انسخ ملف `app-release.apk` إلى هاتفك
2. افتح الإعدادات → الأمان → السماح بالمصادر المجهولة
3. افتح ملف APK وقم بالتثبيت

---

## 🗂️ هيكل المشروع

```
tamtoom_flutter/
├── lib/
│   ├── main.dart              # نقطة البداية
│   ├── config/
│   │   └── api_config.dart    # إعدادات السيرفر
│   ├── models/                # نماذج البيانات
│   │   ├── category.dart
│   │   ├── restaurant.dart
│   │   ├── menu_item.dart
│   │   ├── cart_item.dart
│   │   ├── order.dart
│   │   └── user.dart
│   ├── services/              # خدمات API
│   │   ├── api_service.dart   # كل طلبات HTTP
│   │   └── auth_service.dart  # المصادقة
│   ├── providers/             # إدارة الحالة
│   │   ├── auth_provider.dart
│   │   └── cart_provider.dart
│   └── screens/               # الشاشات
│       ├── splash_screen.dart  # شاشة الترحيب
│       ├── main_scaffold.dart  # الهيكل الرئيسي (nav bar)
│       ├── home_screen.dart    # الصفحة الرئيسية
│       ├── restaurant_screen.dart # صفحة المتجر
│       ├── cart_screen.dart    # سلة الطلبات
│       ├── search_screen.dart  # البحث
│       ├── orders_screen.dart  # الطلبات والتتبع
│       ├── favorites_screen.dart # المفضلة
│       ├── profile_screen.dart # الملف الشخصي
│       └── auth/
│           └── auth_screen.dart # تسجيل الدخول/التسجيل
└── pubspec.yaml               # الاعتمادية
```

---

## 🔌 API المستخدمة

| الوظيفة | Endpoint |
|---------|----------|
| الفئات | `GET /api/categories` |
| المطاعم | `GET /api/restaurants` |
| قائمة المتجر | `GET /api/restaurants/:id/menu` |
| البحث | `GET /api/search?q=...` |
| حساب التوصيل | `POST /api/delivery-fees/calculate` |
| التحقق من الكوبون | `POST /api/coupons/validate` |
| إنشاء طلب | `POST /api/orders` |
| تتبع طلب | `GET /api/orders/number/:orderNumber` |
| طلبات العميل | `GET /api/orders/customer/:phone` |
| تسجيل الدخول | `POST /api/auth/login` |
| إنشاء حساب | `POST /api/auth/register` |
| التحقق من الرمز | `POST /api/auth/validate` |
| المفضلة | `GET /api/favorites/products/:userId` |

---

## 🧪 اختبار الاتصال بالسيرفر

بعد تشغيل التطبيق:
1. افتح الشاشة الرئيسية - إذا ظهرت التصنيفات والمتاجر → الاتصال يعمل
2. اضغط على متجر → إذا ظهرت المنتجات → قاعدة البيانات تعمل
3. سجل دخول بـ: هاتف: `01234567890` ← أنشئ حساباً جديداً أولاً

---

## ❓ حل المشاكل الشائعة

### 1. خطأ في الاتصال على المحاكي
```
// غيّر في api_config.dart
static const String baseUrl = 'http://10.0.2.2:5000'; // للمحاكي
```

### 2. خطأ CLEARTEXT HTTP
في ملف `android/app/src/main/AndroidManifest.xml` أضف:
```xml
<application android:usesCleartextTraffic="true" ...>
```

### 3. لا تظهر الصور
تأكد أن عنوان السيرفر صحيح في `restaurant_screen.dart`

---

## 📱 متطلبات النظام

- **Android**: 5.0+ (API 21+)
- **iOS**: 12.0+
- Flutter 3.x+
- Dart 3.x+
