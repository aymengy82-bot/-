# دليل رفع مشروع تطبيق المطعم Flutter

## المشاكل التي تم إصلاحها

### 1. تحديث المكتبات (Dependencies)
- تم تحديث جميع المكتبات إلى أحدث الإصدارات المتوافقة
- استبدال `toast` بـ `fluttertoast` للتوافق الأفضل
- تحديث `http` إلى الإصدار الأحدث
- إزالة `dependency_overrides` غير الضرورية

### 2. إصلاح مشاكل HTTP
- تحديث استخدام `http.post()` لتمرير `Uri.parse()`
- إصلاح `ByteStream` في رفع الملفات
- تحسين معالجة الأخطاء

### 3. تحديث إعدادات Android
- رفع `compileSdkVersion` إلى 34
- رفع `minSdkVersion` إلى 21
- تحديث Gradle إلى الإصدار الأحدث
- استبدال `jcenter()` بـ `mavenCentral()`

### 4. تحسين الكود
- إزالة التعليقات غير الضرورية
- تحسين استيراد المكتبات
- إصلاح مشكلة فحص الاتصال بالإنترنت

## خطوات رفع المشروع على استضافة مجانية

### الجزء الأول: إعداد الخادم (Backend)

#### 1. اختيار استضافة مجانية للـ PHP
**الخيارات المقترحة:**
- **InfinityFree** (الأفضل): https://infinityfree.net
- **000webhost**: https://www.000webhost.com
- **FreeHosting**: https://freehosting.com

#### 2. إنشاء قاعدة البيانات
```sql
-- إنشاء قاعدة البيانات
CREATE DATABASE restaurant_db;

-- جداول قاعدة البيانات
USE restaurant_db;

-- جدول العملاء
CREATE TABLE customers (
    cus_id INT AUTO_INCREMENT PRIMARY KEY,
    cus_name VARCHAR(100) NOT NULL,
    cus_email VARCHAR(100) UNIQUE,
    cus_mobile VARCHAR(20) NOT NULL,
    cus_pwd VARCHAR(255) NOT NULL,
    cus_image VARCHAR(255),
    cus_regdate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- جدول الفئات
CREATE TABLE categories (
    cat_id INT AUTO_INCREMENT PRIMARY KEY,
    cat_name VARCHAR(100) NOT NULL,
    cat_thumbnail VARCHAR(255),
    cat_regdate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- جدول الأطعمة
CREATE TABLE foods (
    foo_id INT AUTO_INCREMENT PRIMARY KEY,
    cat_id INT,
    foo_name VARCHAR(100) NOT NULL,
    foo_name_en VARCHAR(100),
    foo_price DECIMAL(10,2) NOT NULL,
    foo_offer TINYINT DEFAULT 0,
    foo_info TEXT,
    foo_info_en TEXT,
    foo_thumbnail VARCHAR(255),
    foo_image VARCHAR(255),
    foo_regdate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (cat_id) REFERENCES categories(cat_id)
);

-- جدول المفضلة
CREATE TABLE favorites (
    fav_id INT AUTO_INCREMENT PRIMARY KEY,
    cus_id INT,
    foo_id INT,
    fav_regdate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (cus_id) REFERENCES customers(cus_id),
    FOREIGN KEY (foo_id) REFERENCES foods(foo_id)
);

-- جدول الفواتير
CREATE TABLE bills (
    bil_id INT AUTO_INCREMENT PRIMARY KEY,
    cus_id INT,
    bil_address TEXT,
    bil_before_note TEXT,
    bil_after_note TEXT,
    bil_rate INT DEFAULT 0,
    del_id INT,
    bil_regdate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (cus_id) REFERENCES customers(cus_id)
);

-- جدول تفاصيل الفواتير
CREATE TABLE bill_details (
    det_id INT AUTO_INCREMENT PRIMARY KEY,
    bil_id INT,
    foo_id INT,
    det_qty INT NOT NULL,
    det_price DECIMAL(10,2) NOT NULL,
    det_note TEXT,
    det_regdate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (bil_id) REFERENCES bills(bil_id),
    FOREIGN KEY (foo_id) REFERENCES foods(foo_id)
);
```

#### 3. إنشاء ملفات PHP API

**هيكل المجلدات:**
```
/public_html/
├── api/
│   ├── config.php
│   ├── customer/
│   │   ├── login.php
│   │   └── insert_customer.php
│   ├── category/
│   │   └── readcategory.php
│   ├── food/
│   │   └── readfoodcustomer.php
│   ├── favorite/
│   │   ├── readfavorite.php
│   │   ├── insert_favorite.php
│   │   └── delete_favorite.php
│   └── bill/
│       ├── readbill.php
│       ├── readdetail_bill.php
│       └── insert_bill.php
└── images/
    ├── category/
    └── food/
```

**ملف config.php:**
```php
<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

$servername = "localhost";
$username = "your_db_username";
$password = "your_db_password";
$dbname = "your_db_name";

$token = "wjeiwenwejwkejwke98w9e8wewnew8wehwenj232jh32j3h2j3h2j";

try {
    $pdo = new PDO("mysql:host=$servername;dbname=$dbname", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch(PDOException $e) {
    echo json_encode(["code" => "500", "message" => "Connection failed"]);
    exit();
}

function validateToken() {
    global $token;
    if (!isset($_GET['token']) || $_GET['token'] !== $token) {
        echo json_encode(["code" => "401", "message" => "Unauthorized"]);
        exit();
    }
}
?>
```

**مثال على ملف customer/login.php:**
```php
<?php
include '../config.php';
validateToken();

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $cus_mobile = $_POST['cus_mobile'];
    $cus_pwd = $_POST['cus_pwd'];
    
    $stmt = $pdo->prepare("SELECT * FROM customers WHERE cus_mobile = ? AND cus_pwd = ?");
    $stmt->execute([$cus_mobile, md5($cus_pwd)]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if ($user) {
        echo json_encode([
            "code" => "200",
            "message" => [
                "cus_id" => $user['cus_id'],
                "cus_name" => $user['cus_name'],
                "cus_email" => $user['cus_email'],
                "cus_mobile" => $user['cus_mobile'],
                "cus_image" => $user['cus_image']
            ]
        ]);
    } else {
        echo json_encode(["code" => "404", "message" => "User not found"]);
    }
}
?>
```

### الجزء الثاني: إعداد التطبيق

#### 1. تحديث رابط API
في ملف `lib/pages/config.dart`:
```dart
final String path_api = "https://yourdomain.com/api/";
final String path_images = "https://yourdomain.com/images/";
```

#### 2. إضافة أذونات الإنترنت
في `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

#### 3. تشغيل الأوامر
```bash
# تنظيف المشروع
flutter clean

# تحديث المكتبات
flutter pub get

# تشغيل التطبيق
flutter run
```

### الجزء الثالث: رفع الملفات

#### 1. رفع ملفات PHP
- ارفع مجلد `api` إلى `/public_html/`
- ارفع مجلد `images` إلى `/public_html/`
- تأكد من صحة أذونات الملفات (755 للمجلدات، 644 للملفات)

#### 2. إعداد قاعدة البيانات
- ادخل إلى phpMyAdmin في لوحة التحكم
- أنشئ قاعدة البيانات
- استورد الجداول باستخدام الكود SQL أعلاه

#### 3. إدخال بيانات تجريبية
```sql
-- إدخال فئات تجريبية
INSERT INTO categories (cat_name, cat_thumbnail) VALUES 
('المقبلات', 'cat1.png'),
('الأطباق الرئيسية', 'cat2.png'),
('الحلويات', 'cat3.png');

-- إدخال أطعمة تجريبية
INSERT INTO foods (cat_id, foo_name, foo_price, foo_offer, foo_info, foo_thumbnail, foo_image) VALUES 
(1, 'حمص بالطحينة', 15.00, 1, 'حمص طازج مع الطحينة والزيت', 'food1.jpg', 'food1.jpg'),
(2, 'كباب مشوي', 45.00, 0, 'كباب لحم مشوي مع الخضار', 'food2.jpg', 'food2.jpg'),
(3, 'كنافة نابلسية', 25.00, 1, 'كنافة طازجة بالجبن والقطر', 'food3.jpg', 'food3.jpg');
```

### الجزء الرابع: اختبار التطبيق

#### 1. اختبار API
- اختبر الروابط في المتصفح:
  - `https://yourdomain.com/api/category/readcategory.php?token=YOUR_TOKEN`
  - `https://yourdomain.com/api/food/readfoodcustomer.php?token=YOUR_TOKEN`

#### 2. اختبار التطبيق
- قم بتشغيل التطبيق
- اختبر تسجيل الدخول والتسجيل
- اختبر عرض الفئات والأطعمة
- اختبر إضافة المفضلة والطلبات

### نصائح مهمة

#### 1. الأمان
- غيّر التوكن في `config.dart` و `config.php`
- استخدم HTTPS دائماً
- لا تحفظ كلمات المرور بشكل واضح

#### 2. الأداء
- ضغط الصور قبل رفعها
- استخدم CDN للصور إذا أمكن
- فعّل الـ caching في الخادم

#### 3. النسخ الاحتياطية
- اعمل نسخة احتياطية من قاعدة البيانات بانتظام
- احتفظ بنسخة من ملفات PHP

#### 4. المراقبة
- راقب استخدام الموارد
- تابع سجلات الأخطاء
- اختبر التطبيق بانتظام

### استضافات مجانية موصى بها

#### 1. InfinityFree
- **المميزات**: PHP 8.1، MySQL، SSL مجاني، 5GB مساحة
- **العيوب**: إعلانات، محدودية في الموارد
- **الرابط**: https://infinityfree.net

#### 2. 000webhost
- **المميزات**: PHP 8.0، MySQL، 1GB مساحة، SSL مجاني
- **العيوب**: توقف لساعة يومياً، إعلانات
- **الرابط**: https://www.000webhost.com

#### 3. Heroku (للـ Backend فقط)
- **المميزات**: دعم متعدد اللغات، Git deployment
- **العيوب**: يتطلب معرفة تقنية أكثر
- **الرابط**: https://heroku.com

### خطوات ما بعد النشر

1. **اختبار شامل**: اختبر جميع وظائف التطبيق
2. **تحسين الأداء**: راقب سرعة التحميل والاستجابة
3. **إضافة المحتوى**: أضف المزيد من الفئات والأطعمة
4. **التسويق**: شارك التطبيق مع المستخدمين المحتملين
5. **التطوير المستمر**: أضف ميزات جديدة بناءً على ملاحظات المستخدمين

هذا الدليل يوفر خطة شاملة لرفع تطبيق المطعم على استضافة مجانية مع إصلاح جميع المشاكل الموجودة في الكود.