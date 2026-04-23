# 🗄️ Database Migrations - Perfumes POS

## 📋 نظرة عامة

تم تحويل جميع الـ 29 جدول من SQL إلى Laravel Migrations بنجاح.

---

## 🎯 الجداول المنشأة (29 جدول)

### الترتيب حسب التبعيات:

```
1.  units                      - وحدات القياس
2.  price_tiers                - مستويات التسعير
3.  categories                 - التصنيفات
4.  sizes                      - الأحجام
5.  payment_methods            - طرق الدفع
6.  users (updated)            - المستخدمين
7.  customers                  - العملاء
8.  suppliers                  - الموردين
9.  material_types             - المواد التشغيلية
10. discounts                  - الخصومات
11. products                   - المنتجات
12. inventory                  - المخزون
13. product_images             - صور المنتجات
14. tier_prices                - الأسعار المركزية
15. unit_based_prices          - أسعار الوحدات
16. invoices                   - الفواتير
17. invoice_items              - تفاصيل الفواتير
18. payments                   - الدفعات
19. purchases                  - المشتريات
20. material_purchases         - مشتريات المواد
21. recipes                    - الوصفات
22. recipe_items               - مكونات الوصفات
23. material_usage             - استهلاك المواد
24. invoice_costs              - تكاليف الفواتير
25. inventory_movements        - حركات المخزون
26. returns                    - المرتجعات
27. return_items               - تفاصيل المرتجعات
28. discount_products          - ربط الخصومات
29. return_cost_reversals      - عكس التكاليف
```

---

## 🚀 الأوامر

### تشغيل الـ Migrations

```bash
# تشغيل جميع الـ migrations
php artisan migrate

# عرض حالة الـ migrations
php artisan migrate:status

# التراجع عن آخر batch
php artisan migrate:rollback

# التراجع عن جميع الـ migrations
php artisan migrate:reset

# إعادة تشغيل جميع الـ migrations
php artisan migrate:refresh

# إعادة تشغيل مع seeders
php artisan migrate:refresh --seed
```

### التحقق من الجداول

```bash
# عرض جميع الجداول
php artisan db:show

# عرض تفاصيل جدول معين
php artisan db:table products

# استخدام MySQL مباشرة
mysql -u alalem -p perfumes_pos -e "SHOW TABLES;"
```

---

## 📁 ملفات الـ Migrations

جميع الملفات موجودة في:
```
database/migrations/
├── 2024_01_01_000001_create_units_table.php
├── 2024_01_01_000002_create_price_tiers_table.php
├── 2024_01_01_000003_create_categories_table.php
├── ...
└── 2024_01_01_000029_create_return_cost_reversals_table.php
```

---

## ⚙️ الإعدادات

### قاعدة البيانات (.env)

```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=perfumes_pos
DB_USERNAME=alalem
DB_PASSWORD=Alalem@12255!
```

---

## 🔑 الميزات الرئيسية

### ✅ Foreign Keys
- جميع العلاقات محددة بـ `foreignId()->constrained()`
- دعم `onDelete('cascade')` للحذف المتسلسل
- دعم `nullable()` للعلاقات الاختيارية

### ✅ Indexes
- Primary keys تلقائية
- Unique indexes للحقول الفريدة
- Performance indexes للاستعلامات
- Composite indexes للعلاقات المعقدة

### ✅ Data Types
- `decimal(10,2)` للأموال والكميات
- `enum()` للقيم المحددة
- `text()` للنصوص الطويلة
- `timestamp()` للتواريخ

### ✅ Default Values
- قيم افتراضية منطقية
- `useCurrent()` للـ timestamps
- `default(0)` للأرقام
- `default(true)` للـ booleans

---

## 📊 الإحصائيات

```
✅ 29 جدول POS
✅ 40+ Foreign Keys
✅ 60+ Indexes
✅ 8 Enums
✅ 15+ Unique Constraints
✅ 100% متوافق مع SQL الأصلي
```

---

## 🎯 الميزات المطبقة

### v2.1
- [x] SKU للمنتجات
- [x] min_stock_level للتنبيهات
- [x] الدفع الجزئي (paid_amount, due_amount, payment_status)
- [x] product_unit_cost (snapshot)
- [x] waste_percentage
- [x] restock_fee
- [x] return_cost_reversals

### v3.0
- [x] discount_id في invoices و invoice_items
- [x] is_returnable في products
- [x] batch_number في purchases و inventory_movements

---

## 🔍 أمثلة الاستخدام

### إنشاء جدول جديد

```bash
php artisan make:migration create_example_table
```

### تعديل جدول موجود

```bash
php artisan make:migration add_field_to_products_table
```

### حذف جدول

```bash
php artisan make:migration drop_example_table
```

---

## ⚠️ ملاحظات مهمة

1. **الترتيب مهم**: الجداول منشأة بترتيب التبعيات
2. **Foreign Keys**: تأكد من وجود الجدول المرجعي قبل إنشاء FK
3. **Rollback**: استخدم `migrate:rollback` بحذر في production
4. **Backup**: احتفظ بنسخة احتياطية قبل أي تعديل

---

## 🐛 استكشاف الأخطاء

### خطأ: Foreign key constraint fails

```bash
# تأكد من الترتيب الصحيح
php artisan migrate:reset
php artisan migrate
```

### خطأ: Table already exists

```bash
# حذف الجدول يدوياً أو
php artisan migrate:rollback
```

### خطأ: Connection refused

```bash
# تحقق من إعدادات .env
# تأكد من تشغيل MySQL
sudo systemctl start mysql
```

---

## 📚 المراجع

- [Laravel Migrations Documentation](https://laravel.com/docs/migrations)
- [Database Schema Builder](https://laravel.com/docs/schema)
- [SKILLS.md](../SKILLS.md) - دليل المشروع الشامل
- [steps_v2/](../steps_v2/) - التوثيق التفصيلي

---

## ✅ الحالة

**✅ مكتمل بنجاح**

جميع الـ 29 جدول تم إنشاؤها بنجاح مع جميع العلاقات والفهارس.

**الخطوة التالية:** إنشاء Models 🚀

---

**آخر تحديث:** 2024  
**الإصدار:** v3.0
