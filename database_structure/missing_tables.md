# 🗄️ الجداول الناقصة / الاختيارية / المستقبلية

---

## 📌 تصنيف الجداول

الجداول مصنفة حسب الأولوية:
- 🔴 **CRITICAL:** ضرورية لاكتمال النظام
- 🟡 **HIGH:** مهمة لتحسين النظام
- 🟢 **MEDIUM:** تحسينات اختيارية
- 🔵 **LOW:** ميزات مستقبلية

---

## 🔴 CRITICAL: جداول ضرورية

---

### 1. inventory_movements

**الوظيفة:** تتبع جميع حركات المخزون (إضافة / خصم / تعديل / نقل)

| الحقل | النوع | PK/FK | Nullable | الوصف |
|------|------|------|----------|-------|
| id | BIGINT | PK | NO | معرف الحركة |
| product_id | BIGINT | FK → products | NO | المنتج |
| movement_type | ENUM | — | NO | نوع الحركة |
| quantity | DECIMAL(10,2) | — | NO | الكمية (موجب للإضافة / سالب للخصم) |
| quantity_before | DECIMAL(10,2) | — | NO | الكمية قبل الحركة |
| quantity_after | DECIMAL(10,2) | — | NO | الكمية بعد الحركة |
| reference_type | VARCHAR(50) | — | YES | نوع المرجع (sale / purchase / adjustment / loss / return) |
| reference_id | BIGINT | — | YES | معرف المرجع |
| user_id | BIGINT | FK → users | NO | المستخدم |
| notes | TEXT | — | YES | ملاحظات |
| created_at | TIMESTAMP | — | YES | تاريخ الحركة |

**Indexes:**
- PRIMARY KEY (id)
- FOREIGN KEY (product_id) REFERENCES products(id)
- FOREIGN KEY (user_id) REFERENCES users(id)
- INDEX (product_id)
- INDEX (movement_type)
- INDEX (reference_type, reference_id)
- INDEX (created_at)

**ENUM Values:**
- movement_type: ('in', 'out', 'adjustment', 'transfer')

**الأهمية:** تتبع شامل لكل حركات المخزون في مكان واحد

**الفائدة:**
- تقارير حركة المخزون
- تدقيق المخزون
- تتبع من أضاف/خصم المخزون
- معرفة سبب كل حركة

**أمثلة على الاستخدام:**
```
بيع منتج:
- movement_type: 'out'
- quantity: -5
- reference_type: 'sale'
- reference_id: 123

شراء دفعة:
- movement_type: 'in'
- quantity: +200
- reference_type: 'purchase'
- reference_id: 45

تعديل يدوي:
- movement_type: 'adjustment'
- quantity: +10
- reference_type: NULL
- notes: "تصحيح جرد"

فاقد/تلف:
- movement_type: 'out'
- quantity: -15
- reference_type: 'loss'
- reference_id: 78

مرتجع:
- movement_type: 'in'
- quantity: +3
- reference_type: 'return'
- reference_id: 56
```

---

### 2. users

**الوظيفة:** إدارة المستخدمين (Laravel default)

| الحقل | النوع | PK/FK | Nullable | الوصف |
|------|------|------|----------|-------|
| id | BIGINT | PK | NO | معرف المستخدم |
| name | VARCHAR(255) | — | NO | الاسم |
| email | VARCHAR(255) | — | NO | البريد الإلكتروني |
| password | VARCHAR(255) | — | NO | كلمة المرور |
| role | VARCHAR(50) | — | NO | الدور (admin / seller) |
| is_active | BOOLEAN | — | NO | حالة النشاط |
| email_verified_at | TIMESTAMP | — | YES | تاريخ التحقق |
| remember_token | VARCHAR(100) | — | YES | رمز التذكر |
| created_at | TIMESTAMP | — | YES | تاريخ الإنشاء |
| updated_at | TIMESTAMP | — | YES | تاريخ التحديث |

**Indexes:**
- PRIMARY KEY (id)
- UNIQUE (email)
- INDEX (role)
- INDEX (is_active)

**الأهمية:** مطلوب لنظام المصادقة والصلاحيات

---

### 3. unit_based_prices

**الوظيفة:** تسعير المنتجات UNIT_BASED (بخور / وشق)

| الحقل | النوع | PK/FK | Nullable | الوصف |
|------|------|------|----------|-------|
| id | BIGINT | PK | NO | معرف السعر |
| product_id | BIGINT | FK → products | NO | المنتج |
| tier_id | BIGINT | FK → price_tiers | NO | التير |
| price_per_unit | DECIMAL(10,2) | — | NO | سعر الوحدة الواحدة |
| created_at | TIMESTAMP | — | YES | تاريخ الإنشاء |
| updated_at | TIMESTAMP | — | YES | تاريخ التحديث |

**Indexes:**
- PRIMARY KEY (id)
- FOREIGN KEY (product_id) REFERENCES products(id)
- FOREIGN KEY (tier_id) REFERENCES price_tiers(id)
- UNIQUE (product_id, tier_id)
- INDEX (product_id)

**الأهمية:** حل نقطة القرار لتسعير UNIT_BASED

**البديل:** استخدام tier_prices مع size خاص أو سعر ثابت في products

---

---

## 🟡 HIGH: جداول مهمة

---

### 4. invoices

**الوظيفة:** فواتير متعددة المنتجات

| الحقل | النوع | PK/FK | Nullable | الوصف |
|------|------|------|----------|-------|
| id | BIGINT | PK | NO | رقم الفاتورة |
| invoice_number | VARCHAR(50) | — | NO | رقم الفاتورة (فريد) |
| customer_id | BIGINT | FK → customers | YES | العميل |
| user_id | BIGINT | FK → users | NO | البائع |
| subtotal | DECIMAL(10,2) | — | NO | المجموع الفرعي |
| discount | DECIMAL(10,2) | — | NO | الخصم |
| tax | DECIMAL(10,2) | — | NO | الضريبة |
| total | DECIMAL(10,2) | — | NO | الإجمالي |
| payment_method | VARCHAR(50) | — | NO | طريقة الدفع |
| status | ENUM | — | NO | حالة الفاتورة |
| notes | TEXT | — | YES | ملاحظات |
| created_at | TIMESTAMP | — | YES | تاريخ الإنشاء |
| updated_at | TIMESTAMP | — | YES | تاريخ التحديث |

**Indexes:**
- PRIMARY KEY (id)
- UNIQUE (invoice_number)
- FOREIGN KEY (customer_id) REFERENCES customers(id)
- FOREIGN KEY (user_id) REFERENCES users(id)
- INDEX (customer_id)
- INDEX (user_id)
- INDEX (status)
- INDEX (created_at)

**ENUM Values:**
- status: ('pending', 'completed', 'cancelled', 'refunded')

**الأهمية:** ضرورية لفواتير متعددة المنتجات وتقارير أفضل

**الفائدة:**
- بيع عدة منتجات في فاتورة واحدة
- طباعة فواتير احترافية
- تقارير مبيعات أدق
- تتبع حالة الفاتورة

---

### 5. invoice_items

**الوظيفة:** تفاصيل منتجات الفاتورة

| الحقل | النوع | PK/FK | Nullable | الوصف |
|------|------|------|----------|-------|
| id | BIGINT | PK | NO | معرف السطر |
| invoice_id | BIGINT | FK → invoices | NO | الفاتورة |
| product_id | BIGINT | FK → products | NO | المنتج |
| size_id | BIGINT | FK → sizes | YES | الحجم (nullable للـ UNIT_BASED) |
| quantity | DECIMAL(10,2) | — | NO | الكمية |
| unit_price | DECIMAL(10,2) | — | NO | سعر الوحدة |
| discount | DECIMAL(10,2) | — | NO | خصم السطر |
| total_price | DECIMAL(10,2) | — | NO | الإجمالي |
| created_at | TIMESTAMP | — | YES | تاريخ الإنشاء |

**Indexes:**
- PRIMARY KEY (id)
- FOREIGN KEY (invoice_id) REFERENCES invoices(id) ON DELETE CASCADE
- FOREIGN KEY (product_id) REFERENCES products(id)
- FOREIGN KEY (size_id) REFERENCES sizes(id)
- INDEX (invoice_id)
- INDEX (product_id)

**الفائدة:**
- تفاصيل دقيقة لكل منتج
- خصومات على مستوى السطر
- تقارير منتجات مفصلة

**ملاحظة:** إذا تم تطبيق invoices، يمكن ربط sales بـ invoice_id أو استبدال sales بـ invoice_items

---

### 6. customers

**الوظيفة:** إدارة بيانات العملاء

| الحقل | النوع | PK/FK | Nullable | الوصف |
|------|------|------|----------|-------|
| id | BIGINT | PK | NO | معرف العميل |
| name | VARCHAR(255) | — | NO | الاسم |
| phone | VARCHAR(20) | — | YES | رقم الهاتف |
| email | VARCHAR(255) | — | YES | البريد الإلكتروني |
| address | TEXT | — | YES | العنوان |
| total_purchases | DECIMAL(10,2) | — | NO | إجمالي المشتريات |
| is_active | BOOLEAN | — | NO | حالة النشاط |
| created_at | TIMESTAMP | — | YES | تاريخ التسجيل |
| updated_at | TIMESTAMP | — | YES | تاريخ التحديث |

**Indexes:**
- PRIMARY KEY (id)
- UNIQUE (phone)
- INDEX (email)
- INDEX (is_active)

**الفائدة:**
- تتبع العملاء
- برامج الولاء
- تقارير العملاء

**التعديل المطلوب على sales:**
```sql
ALTER TABLE sales ADD COLUMN customer_id BIGINT NULL;
ALTER TABLE sales ADD FOREIGN KEY (customer_id) REFERENCES customers(id);
```

---

### 7. suppliers

**الوظيفة:** إدارة بيانات الموردين

| الحقل | النوع | PK/FK | Nullable | الوصف |
|------|------|------|----------|-------|
| id | BIGINT | PK | NO | معرف المورد |
| name | VARCHAR(255) | — | NO | اسم المورد |
| phone | VARCHAR(20) | — | YES | رقم الهاتف |
| email | VARCHAR(255) | — | YES | البريد الإلكتروني |
| address | TEXT | — | YES | العنوان |
| total_purchases | DECIMAL(10,2) | — | NO | إجمالي المشتريات منه |
| is_active | BOOLEAN | — | NO | حالة النشاط |
| created_at | TIMESTAMP | — | YES | تاريخ التسجيل |
| updated_at | TIMESTAMP | — | YES | تاريخ التحديث |

**Indexes:**
- PRIMARY KEY (id)
- INDEX (phone)
- INDEX (is_active)

**الفائدة:**
- تتبع الموردين
- تقارير المشتريات
- تقييم الموردين

**التعديل المطلوب على purchase_batches:**
```sql
ALTER TABLE purchase_batches DROP COLUMN supplier_name;
ALTER TABLE purchase_batches ADD COLUMN supplier_id BIGINT NULL;
ALTER TABLE purchase_batches ADD FOREIGN KEY (supplier_id) REFERENCES suppliers(id);
```

---

### 8. payment_methods

**الوظيفة:** تتبع طرق الدفع

| الحقل | النوع | PK/FK | Nullable | الوصف |
|------|------|------|----------|-------|
| id | BIGINT | PK | NO | معرف الطريقة |
| name | VARCHAR(50) | — | NO | اسم الطريقة (نقدي / بطاقة / تحويل) |
| is_active | BOOLEAN | — | NO | حالة النشاط |
| created_at | TIMESTAMP | — | YES | تاريخ الإنشاء |
| updated_at | TIMESTAMP | — | YES | تاريخ التحديث |

**Indexes:**
- PRIMARY KEY (id)
- UNIQUE (name)
- INDEX (is_active)

---

### 9. payments

**الوظيفة:** تسجيل المدفوعات

| الحقل | النوع | PK/FK | Nullable | الوصف |
|------|------|------|----------|-------|
| id | BIGINT | PK | NO | معرف الدفع |
| sale_id | BIGINT | FK → sales | YES | البيع (إذا لم يكن invoice) |
| invoice_id | BIGINT | FK → invoices | YES | الفاتورة |
| payment_method_id | BIGINT | FK → payment_methods | NO | طريقة الدفع |
| amount | DECIMAL(10,2) | — | NO | المبلغ |
| reference | VARCHAR(100) | — | YES | رقم مرجعي |
| created_at | TIMESTAMP | — | YES | تاريخ الدفع |

**Indexes:**
- PRIMARY KEY (id)
- FOREIGN KEY (sale_id) REFERENCES sales(id)
- FOREIGN KEY (invoice_id) REFERENCES invoices(id)
- FOREIGN KEY (payment_method_id) REFERENCES payment_methods(id)
- INDEX (sale_id)
- INDEX (invoice_id)
- INDEX (created_at)

**الفائدة:**
- تتبع طرق الدفع
- تقارير مالية دقيقة
- تسوية الحسابات

---

### 10. material_batches

**الوظيفة:** دفعات شراء المواد التشغيلية (كحول / زجاج)

| الحقل | النوع | PK/FK | Nullable | الوصف |
|------|------|------|----------|-------|
| id | BIGINT | PK | NO | رقم الدفعة |
| material_id | BIGINT | FK → material_types | NO | المادة |
| quantity | DECIMAL(10,2) | — | NO | الكمية |
| unit_cost | DECIMAL(10,2) | — | NO | سعر الوحدة |
| total_cost | DECIMAL(10,2) | — | NO | إجمالي التكلفة |
| supplier_id | BIGINT | FK → suppliers | YES | المورد |
| purchase_date | DATE | — | NO | تاريخ الشراء |
| created_at | TIMESTAMP | — | YES | تاريخ الإنشاء |

**Indexes:**
- PRIMARY KEY (id)
- FOREIGN KEY (material_id) REFERENCES material_types(id)
- FOREIGN KEY (supplier_id) REFERENCES suppliers(id)
- INDEX (material_id)
- INDEX (purchase_date)

---

### 11. material_inventory

**الوظيفة:** مخزون المواد مع FIFO

| الحقل | النوع | PK/FK | Nullable | الوصف |
|------|------|------|----------|-------|
| id | BIGINT | PK | NO | معرف السجل |
| material_batch_id | BIGINT | FK → material_batches | NO | الدفعة |
| material_id | BIGINT | FK → material_types | NO | المادة |
| remaining_quantity | DECIMAL(10,2) | — | NO | الكمية المتبقية |
| created_at | TIMESTAMP | — | YES | تاريخ الإنشاء |
| updated_at | TIMESTAMP | — | YES | تاريخ التحديث |

**Indexes:**
- PRIMARY KEY (id)
- FOREIGN KEY (material_batch_id) REFERENCES material_batches(id)
- FOREIGN KEY (material_id) REFERENCES material_types(id)
- INDEX (material_batch_id)
- INDEX (material_id)
- INDEX (created_at) -- للـ FIFO

**الفائدة:**
- تكلفة دقيقة للمواد
- FIFO للمواد التشغيلية
- تتبع أفضل للتكاليف

**التعديل المطلوب على material_usage:**
```sql
ALTER TABLE material_usage ADD COLUMN cost_per_unit_snapshot DECIMAL(10,2) NOT NULL;
ALTER TABLE material_usage ADD COLUMN total_cost DECIMAL(10,2) NOT NULL;
ALTER TABLE material_usage ADD COLUMN material_batch_id BIGINT NULL;
ALTER TABLE material_usage ADD FOREIGN KEY (material_batch_id) REFERENCES material_batches(id);
```

---

---

## 🟢 MEDIUM: تحسينات اختيارية

---

### 12. returns

**الوظيفة:** إدارة المرتجعات

| الحقل | النوع | PK/FK | Nullable | الوصف |
|------|------|------|----------|-------|
| id | BIGINT | PK | NO | رقم المرتجع |
| sale_id | BIGINT | FK → sales | NO | البيع الأصلي |
| user_id | BIGINT | FK → users | NO | المستخدم |
| reason | TEXT | — | YES | سبب الإرجاع |
| refund_amount | DECIMAL(10,2) | — | NO | المبلغ المسترد |
| status | ENUM | — | NO | حالة المرتجع |
| created_at | TIMESTAMP | — | YES | تاريخ الإرجاع |
| updated_at | TIMESTAMP | — | YES | تاريخ التحديث |

**Indexes:**
- PRIMARY KEY (id)
- FOREIGN KEY (sale_id) REFERENCES sales(id)
- FOREIGN KEY (user_id) REFERENCES users(id)
- INDEX (sale_id)
- INDEX (status)
- INDEX (created_at)

**ENUM Values:**
- status: ('pending', 'approved', 'rejected', 'completed')

---

### 13. return_items

**الوظيفة:** تفاصيل المنتجات المرتجعة

| الحقل | النوع | PK/FK | Nullable | الوصف |
|------|------|------|----------|-------|
| id | BIGINT | PK | NO | معرف السطر |
| return_id | BIGINT | FK → returns | NO | المرتجع |
| product_id | BIGINT | FK → products | NO | المنتج |
| size_id | BIGINT | FK → sizes | YES | الحجم |
| quantity | DECIMAL(10,2) | — | NO | الكمية |
| refund_amount | DECIMAL(10,2) | — | NO | المبلغ المسترد |
| created_at | TIMESTAMP | — | YES | تاريخ الإنشاء |

**Indexes:**
- PRIMARY KEY (id)
- FOREIGN KEY (return_id) REFERENCES returns(id)
- FOREIGN KEY (product_id) REFERENCES products(id)
- FOREIGN KEY (size_id) REFERENCES sizes(id)
- INDEX (return_id)
- INDEX (product_id)

**الفائدة:**
- إدارة المرتجعات
- إعادة المخزون
- تقارير المرتجعات

---

### 14. discounts

**الوظيفة:** إدارة الخصومات والعروض

| الحقل | النوع | PK/FK | Nullable | الوصف |
|------|------|------|----------|-------|
| id | BIGINT | PK | NO | معرف الخصم |
| name | VARCHAR(255) | — | NO | اسم الخصم |
| type | ENUM | — | NO | نوع الخصم (percentage / fixed) |
| value | DECIMAL(10,2) | — | NO | قيمة الخصم |
| min_purchase | DECIMAL(10,2) | — | YES | الحد الأدنى للشراء |
| start_date | DATE | — | YES | تاريخ البداية |
| end_date | DATE | — | YES | تاريخ النهاية |
| is_active | BOOLEAN | — | NO | حالة النشاط |
| created_at | TIMESTAMP | — | YES | تاريخ الإنشاء |
| updated_at | TIMESTAMP | — | YES | تاريخ التحديث |

**Indexes:**
- PRIMARY KEY (id)
- INDEX (is_active)
- INDEX (start_date, end_date)

**ENUM Values:**
- type: ('percentage', 'fixed')

---

### 15. discount_products

**الوظيفة:** ربط الخصومات بالمنتجات

| الحقل | النوع | PK/FK | Nullable | الوصف |
|------|------|------|----------|-------|
| id | BIGINT | PK | NO | معرف السجل |
| discount_id | BIGINT | FK → discounts | NO | الخصم |
| product_id | BIGINT | FK → products | NO | المنتج |
| created_at | TIMESTAMP | — | YES | تاريخ الإنشاء |

**Indexes:**
- PRIMARY KEY (id)
- FOREIGN KEY (discount_id) REFERENCES discounts(id)
- FOREIGN KEY (product_id) REFERENCES products(id)
- UNIQUE (discount_id, product_id)
- INDEX (discount_id)
- INDEX (product_id)

**الفائدة:**
- عروض وخصومات
- تسويق
- زيادة المبيعات

---

### 16. product_images

**الوظيفة:** صور المنتجات

| الحقل | النوع | PK/FK | Nullable | الوصف |
|------|------|------|----------|-------|
| id | BIGINT | PK | NO | معرف الصورة |
| product_id | BIGINT | FK → products | NO | المنتج |
| image_path | VARCHAR(255) | — | NO | مسار الصورة |
| is_primary | BOOLEAN | — | NO | صورة رئيسية |
| order | INT | — | NO | الترتيب |
| created_at | TIMESTAMP | — | YES | تاريخ الإنشاء |

**Indexes:**
- PRIMARY KEY (id)
- FOREIGN KEY (product_id) REFERENCES products(id)
- INDEX (product_id)
- INDEX (is_primary)

---

### 17. notifications

**الوظيفة:** إشعارات النظام

| الحقل | النوع | PK/FK | Nullable | الوصف |
|------|------|------|----------|-------|
| id | BIGINT | PK | NO | معرف الإشعار |
| user_id | BIGINT | FK → users | YES | المستخدم |
| type | VARCHAR(50) | — | NO | نوع الإشعار |
| title | VARCHAR(255) | — | NO | العنوان |
| message | TEXT | — | NO | الرسالة |
| is_read | BOOLEAN | — | NO | مقروء |
| created_at | TIMESTAMP | — | YES | تاريخ الإنشاء |

**Indexes:**
- PRIMARY KEY (id)
- FOREIGN KEY (user_id) REFERENCES users(id)
- INDEX (user_id)
- INDEX (is_read)
- INDEX (created_at)

**الفائدة:**
- تنبيهات المخزون
- تنبيهات الطلبات
- إشعارات النظام

---

---

## 🔵 LOW: ميزات مستقبلية

---

### 18. loyalty_programs

**الوظيفة:** برامج الولاء

| الحقل | النوع | PK/FK | Nullable | الوصف |
|------|------|------|----------|-------|
| id | BIGINT | PK | NO | معرف البرنامج |
| name | VARCHAR(255) | — | NO | اسم البرنامج |
| points_per_lyd | DECIMAL(10,2) | — | NO | نقاط لكل دينار |
| min_points_redeem | INT | — | NO | الحد الأدنى للاستبدال |
| is_active | BOOLEAN | — | NO | حالة النشاط |
| created_at | TIMESTAMP | — | YES | تاريخ الإنشاء |
| updated_at | TIMESTAMP | — | YES | تاريخ التحديث |

**Indexes:**
- PRIMARY KEY (id)
- INDEX (is_active)

---

### 19. customer_points

**الوظيفة:** نقاط العملاء

| الحقل | النوع | PK/FK | Nullable | الوصف |
|------|------|------|----------|-------|
| id | BIGINT | PK | NO | معرف السجل |
| customer_id | BIGINT | FK → customers | NO | العميل |
| points | INT | — | NO | النقاط |
| created_at | TIMESTAMP | — | YES | تاريخ الإنشاء |
| updated_at | TIMESTAMP | — | YES | تاريخ التحديث |

**Indexes:**
- PRIMARY KEY (id)
- FOREIGN KEY (customer_id) REFERENCES customers(id)
- UNIQUE (customer_id)

---

### 20. expenses

**الوظيفة:** المصروفات التشغيلية

| الحقل | النوع | PK/FK | Nullable | الوصف |
|------|------|------|----------|-------|
| id | BIGINT | PK | NO | معرف المصروف |
| category | VARCHAR(100) | — | NO | فئة المصروف |
| amount | DECIMAL(10,2) | — | NO | المبلغ |
| description | TEXT | — | YES | الوصف |
| user_id | BIGINT | FK → users | NO | المستخدم |
| expense_date | DATE | — | NO | تاريخ المصروف |
| created_at | TIMESTAMP | — | YES | تاريخ الإنشاء |

**Indexes:**
- PRIMARY KEY (id)
- FOREIGN KEY (user_id) REFERENCES users(id)
- INDEX (category)
- INDEX (expense_date)

---

### 21. reports_cache

**الوظيفة:** تخزين التقارير المحسوبة مسبقاً

| الحقل | النوع | PK/FK | Nullable | الوصف |
|------|------|------|----------|-------|
| id | BIGINT | PK | NO | معرف التقرير |
| report_type | VARCHAR(50) | — | NO | نوع التقرير |
| period | VARCHAR(50) | — | NO | الفترة (daily / monthly) |
| data | JSON | — | NO | بيانات التقرير |
| generated_at | TIMESTAMP | — | YES | تاريخ التوليد |

**Indexes:**
- PRIMARY KEY (id)
- INDEX (report_type, period)
- INDEX (generated_at)

---

## 📊 ملخص الجداول الناقصة

**إجمالي الجداول:** 21 جدول

**حسب الأولوية:**
- 🔴 CRITICAL: 3 جداول (inventory_movements, users, unit_based_prices)
- 🟡 HIGH: 8 جداول (invoices, invoice_items, customers, suppliers, payments, materials)
- 🟢 MEDIUM: 6 جداول (returns, discounts, images, notifications)
- 🔵 LOW: 4 جداول (loyalty, expenses, reports)

---

## 🎯 التوصيات

### **المرحلة الأولى (قبل التطبيق):**
```
✅ users (Laravel default)
✅ unit_based_prices (حل نقطة القرار)
✅ inventory_movements (تتبع حركات المخزون)
```

### **المرحلة الثانية (بعد الإطلاق الأولي):**
```
□ invoices + invoice_items (فواتير متعددة المنتجات)
□ customers
□ suppliers
□ payment_methods + payments
□ material_batches + material_inventory
```

### **المرحلة الثالثة (تحسينات):**
```
□ returns + return_items
□ discounts + discount_products
□ notifications
□ product_images
```

### **المرحلة الرابعة (مستقبلية):**
```
□ loyalty_programs + customer_points
□ expenses
□ product_images
□ reports_cache
```

---

## ✅ الخلاصة

**الجداول الحالية:** 23 جدول ✅  
**الجداول الناقصة:** 21 جدول  
**الضرورية منها:** 3 جداول (inventory_movements, users, unit_based_prices)  

**الحالة:** النظام الحالي مكتمل منطقياً، والجداول الناقصة هي تحسينات اختيارية أو ميزات مستقبلية.
