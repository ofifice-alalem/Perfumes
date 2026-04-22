# 🗄️ الجداول الحالية في النظام

---

## 📋 جداول المرحلة 1: System Core Design

---

### 1. units

**الوظيفة:** تعريف وحدات القياس

| الحقل | النوع | PK/FK | Nullable | الوصف |
|------|------|------|----------|-------|
| id | BIGINT | PK | NO | معرف الوحدة |
| name | VARCHAR(50) | — | NO | اسم الوحدة (مليلتر / غرام / قطعة) |
| symbol | VARCHAR(10) | — | NO | الرمز (ml / g / pcs) |
| created_at | TIMESTAMP | — | YES | تاريخ الإنشاء |
| updated_at | TIMESTAMP | — | YES | تاريخ التحديث |

**Indexes:**
- PRIMARY KEY (id)
- UNIQUE (symbol)

---

### 2. categories

**الوظيفة:** تصنيف المنتجات وربطها بوحدة القياس

| الحقل | النوع | PK/FK | Nullable | الوصف |
|------|------|------|----------|-------|
| id | BIGINT | PK | NO | معرف التصنيف |
| name | VARCHAR(255) | — | NO | اسم التصنيف (عطور زيتية / بخور / وشق) |
| unit_id | BIGINT | FK → units | NO | الوحدة المرتبطة |
| created_at | TIMESTAMP | — | YES | تاريخ الإنشاء |
| updated_at | TIMESTAMP | — | YES | تاريخ التحديث |

**Indexes:**
- PRIMARY KEY (id)
- FOREIGN KEY (unit_id) REFERENCES units(id)
- INDEX (unit_id)

---

### 3. price_tiers

**الوظيفة:** تصنيف جودة المنتجات (A/B/C)

| الحقل | النوع | PK/FK | Nullable | الوصف |
|------|------|------|----------|-------|
| id | BIGINT | PK | NO | معرف التير |
| name | VARCHAR(10) | — | NO | اسم التير (A / B / C) |
| description | TEXT | — | YES | وصف التير |
| created_at | TIMESTAMP | — | YES | تاريخ الإنشاء |
| updated_at | TIMESTAMP | — | YES | تاريخ التحديث |

**Indexes:**
- PRIMARY KEY (id)
- UNIQUE (name)

---

### 4. products

**الوظيفة:** تعريف المنتجات

| الحقل | النوع | PK/FK | Nullable | الوصف |
|------|------|------|----------|-------|
| id | BIGINT | PK | NO | معرف المنتج |
| name | VARCHAR(255) | — | NO | اسم المنتج |
| category_id | BIGINT | FK → categories | NO | التصنيف |
| price_tier_id | BIGINT | FK → price_tiers | NO | مستوى الجودة |
| selling_type | ENUM | — | NO | نوع البيع (DECANT_ONLY / FULL_ONLY / BOTH / UNIT_BASED) |
| created_at | TIMESTAMP | — | YES | تاريخ الإنشاء |
| updated_at | TIMESTAMP | — | YES | تاريخ التحديث |

**Indexes:**
- PRIMARY KEY (id)
- FOREIGN KEY (category_id) REFERENCES categories(id)
- FOREIGN KEY (price_tier_id) REFERENCES price_tiers(id)
- INDEX (category_id)
- INDEX (price_tier_id)
- INDEX (selling_type)

**ENUM Values:**
- selling_type: ('DECANT_ONLY', 'FULL_ONLY', 'BOTH', 'UNIT_BASED')

---

### 5. inventory

**الوظيفة:** تتبع المخزون الحالي

| الحقل | النوع | PK/FK | Nullable | الوصف |
|------|------|------|----------|-------|
| id | BIGINT | PK | NO | معرف السجل |
| product_id | BIGINT | FK → products | NO | المنتج |
| quantity | DECIMAL(10,2) | — | NO | الكمية المتوفرة |
| unit_id | BIGINT | FK → units | NO | الوحدة |
| created_at | TIMESTAMP | — | YES | تاريخ الإنشاء |
| updated_at | TIMESTAMP | — | YES | تاريخ التحديث |

**Indexes:**
- PRIMARY KEY (id)
- FOREIGN KEY (product_id) REFERENCES products(id)
- FOREIGN KEY (unit_id) REFERENCES units(id)
- UNIQUE (product_id)
- INDEX (unit_id)

**ملاحظة:** unit_id redundant (يمكن الحصول عليه من product → category → unit)

---

## 📋 جداول المرحلة 2: Pricing System

---

### 6. sizes

**الوظيفة:** تعريف أحجام البيع

| الحقل | النوع | PK/FK | Nullable | الوصف |
|------|------|------|----------|-------|
| id | BIGINT | PK | NO | معرف الحجم |
| name | VARCHAR(50) | — | NO | اسم الحجم (1ml / 3ml / 5ml / 200ml) |
| value | DECIMAL(10,2) | — | NO | القيمة الرقمية |
| unit_id | BIGINT | FK → units | NO | الوحدة |
| created_at | TIMESTAMP | — | YES | تاريخ الإنشاء |
| updated_at | TIMESTAMP | — | YES | تاريخ التحديث |

**Indexes:**
- PRIMARY KEY (id)
- FOREIGN KEY (unit_id) REFERENCES units(id)
- INDEX (unit_id)

---

### 7. tier_prices

**الوظيفة:** تسعير مركزي (Tier + Size = Price)

| الحقل | النوع | PK/FK | Nullable | الوصف |
|------|------|------|----------|-------|
| id | BIGINT | PK | NO | معرف السعر |
| tier_id | BIGINT | FK → price_tiers | NO | التير |
| size_id | BIGINT | FK → sizes | NO | الحجم |
| price | DECIMAL(10,2) | — | NO | السعر |
| created_at | TIMESTAMP | — | YES | تاريخ الإنشاء |
| updated_at | TIMESTAMP | — | YES | تاريخ التحديث |

**Indexes:**
- PRIMARY KEY (id)
- FOREIGN KEY (tier_id) REFERENCES price_tiers(id)
- FOREIGN KEY (size_id) REFERENCES sizes(id)
- UNIQUE (tier_id, size_id)
- INDEX (tier_id)
- INDEX (size_id)

---

## 📋 جداول المرحلة 3: Sales System

---

### 8. sales

**الوظيفة:** تسجيل عمليات البيع

| الحقل | النوع | PK/FK | Nullable | الوصف |
|------|------|------|----------|-------|
| id | BIGINT | PK | NO | معرف البيع |
| user_id | BIGINT | FK → users | NO | البائع |
| product_id | BIGINT | FK → products | NO | المنتج |
| size_id | BIGINT | FK → sizes | NO | الحجم |
| quantity | DECIMAL(10,2) | — | NO | الكمية المباعة |
| price | DECIMAL(10,2) | — | NO | السعر النهائي |
| created_at | TIMESTAMP | — | YES | تاريخ البيع |

**Indexes:**
- PRIMARY KEY (id)
- FOREIGN KEY (user_id) REFERENCES users(id)
- FOREIGN KEY (product_id) REFERENCES products(id)
- FOREIGN KEY (size_id) REFERENCES sizes(id)
- INDEX (user_id)
- INDEX (product_id)
- INDEX (created_at)

**ملاحظة:** size_id يجب أن يكون nullable للـ UNIT_BASED products

---

## 📋 جداول المرحلة 4: Operational Costing

---

### 9. purchase_batches

**الوظيفة:** تسجيل دفعات الشراء مع التكلفة

| الحقل | النوع | PK/FK | Nullable | الوصف |
|------|------|------|----------|-------|
| id | BIGINT | PK | NO | رقم الدفعة |
| product_id | BIGINT | FK → products | NO | المنتج |
| quantity | DECIMAL(10,2) | — | NO | كمية الشراء |
| unit_cost | DECIMAL(10,2) | — | NO | سعر الوحدة |
| total_cost | DECIMAL(10,2) | — | NO | إجمالي التكلفة |
| supplier_name | VARCHAR(255) | — | YES | اسم المورد |
| purchase_date | DATE | — | NO | تاريخ الشراء |
| created_at | TIMESTAMP | — | YES | تاريخ الإنشاء |

**Indexes:**
- PRIMARY KEY (id)
- FOREIGN KEY (product_id) REFERENCES products(id)
- INDEX (product_id)
- INDEX (purchase_date)

---

### 10. batch_inventory

**الوظيفة:** ربط الدفعات بالمخزون (FIFO tracking)

| الحقل | النوع | PK/FK | Nullable | الوصف |
|------|------|------|----------|-------|
| id | BIGINT | PK | NO | معرف السجل |
| batch_id | BIGINT | FK → purchase_batches | NO | الدفعة |
| product_id | BIGINT | FK → products | NO | المنتج |
| remaining_quantity | DECIMAL(10,2) | — | NO | الكمية المتبقية |
| created_at | TIMESTAMP | — | YES | تاريخ الإنشاء |
| updated_at | TIMESTAMP | — | YES | تاريخ التحديث |

**Indexes:**
- PRIMARY KEY (id)
- FOREIGN KEY (batch_id) REFERENCES purchase_batches(id)
- FOREIGN KEY (product_id) REFERENCES products(id)
- INDEX (batch_id)
- INDEX (product_id)
- INDEX (created_at) -- للـ FIFO

---

### 11. material_types

**الوظيفة:** تعريف المواد التشغيلية (كحول / زجاج / عبوات)

| الحقل | النوع | PK/FK | Nullable | الوصف |
|------|------|------|----------|-------|
| id | BIGINT | PK | NO | معرف المادة |
| name | VARCHAR(100) | — | NO | اسم المادة |
| unit | VARCHAR(10) | — | NO | الوحدة (ml / pcs) |
| cost_per_unit | DECIMAL(10,2) | — | NO | تكلفة الوحدة |
| created_at | TIMESTAMP | — | YES | تاريخ الإنشاء |
| updated_at | TIMESTAMP | — | YES | تاريخ التحديث |

**Indexes:**
- PRIMARY KEY (id)

**ملاحظة:** cost_per_unit ثابت (نقطة قرار: snapshot أو batches)

---

### 12. material_usage

**الوظيفة:** تسجيل استهلاك المواد لكل عملية بيع (Cost Tracking Layer)

| الحقل | النوع | PK/FK | Nullable | الوصف |
|------|------|------|----------|-------|
| id | BIGINT | PK | NO | معرف السجل |
| sale_id | BIGINT | FK → sales | NO | البيع |
| material_id | BIGINT | FK → material_types | NO | المادة |
| quantity_used | DECIMAL(10,2) | — | NO | الكمية المستخدمة |
| created_at | TIMESTAMP | — | YES | تاريخ الإنشاء |

**Indexes:**
- PRIMARY KEY (id)
- FOREIGN KEY (sale_id) REFERENCES sales(id)
- FOREIGN KEY (material_id) REFERENCES material_types(id)
- INDEX (sale_id)
- INDEX (material_id)

---

### 13. sale_costs

**الوظيفة:** حساب التكلفة الفعلية لكل بيع

| الحقل | النوع | PK/FK | Nullable | الوصف |
|------|------|------|----------|-------|
| id | BIGINT | PK | NO | معرف السجل |
| sale_id | BIGINT | FK → sales | NO | البيع |
| product_cost | DECIMAL(10,2) | — | NO | تكلفة المنتج من الدفعة |
| material_cost | DECIMAL(10,2) | — | NO | تكلفة المواد |
| total_cost | DECIMAL(10,2) | — | NO | إجمالي التكلفة |
| created_at | TIMESTAMP | — | YES | تاريخ الإنشاء |

**Indexes:**
- PRIMARY KEY (id)
- FOREIGN KEY (sale_id) REFERENCES sales(id)
- UNIQUE (sale_id)

**ملاحظة:** يمكن إضافة batch_id لتتبع الدفعة المستخدمة

---

### 14. inventory_losses

**الوظيفة:** تسجيل الفاقد والتلف

| الحقل | النوع | PK/FK | Nullable | الوصف |
|------|------|------|----------|-------|
| id | BIGINT | PK | NO | معرف السجل |
| product_id | BIGINT | FK → products | NO | المنتج |
| quantity | DECIMAL(10,2) | — | NO | الكمية المفقودة |
| reason | TEXT | — | YES | سبب التلف |
| loss_cost | DECIMAL(10,2) | — | YES | القيمة المالية |
| created_at | TIMESTAMP | — | YES | تاريخ التسجيل |

**Indexes:**
- PRIMARY KEY (id)
- FOREIGN KEY (product_id) REFERENCES products(id)
- INDEX (product_id)
- INDEX (created_at)

---

## 📋 جداول المرحلة 5: Production & Recipe Engine

---

### 15. recipes

**الوظيفة:** تعريف وصفة إنتاج لكل منتج + حجم

| الحقل | النوع | PK/FK | Nullable | الوصف |
|------|------|------|----------|-------|
| id | BIGINT | PK | NO | معرف الوصفة |
| product_id | BIGINT | FK → products | NO | المنتج |
| size_id | BIGINT | FK → sizes | YES | الحجم (nullable للـ UNIT_BASED) |
| is_active | BOOLEAN | — | NO | تفعيل الوصفة |
| created_at | TIMESTAMP | — | YES | تاريخ الإنشاء |
| updated_at | TIMESTAMP | — | YES | تاريخ التحديث |

**Indexes:**
- PRIMARY KEY (id)
- FOREIGN KEY (product_id) REFERENCES products(id)
- FOREIGN KEY (size_id) REFERENCES sizes(id)
- UNIQUE (product_id, size_id)
- INDEX (product_id)
- INDEX (is_active)

**ملاحظة:** size_id nullable للـ UNIT_BASED products (نقطة قرار: recipe_type)

---

### 16. recipe_items

**الوظيفة:** تفاصيل مكونات كل وصفة

| الحقل | النوع | PK/FK | Nullable | الوصف |
|------|------|------|----------|-------|
| id | BIGINT | PK | NO | معرف السجل |
| recipe_id | BIGINT | FK → recipes | NO | الوصفة |
| material_id | BIGINT | FK → material_types | NO | المادة |
| quantity | DECIMAL(10,2) | — | NO | الكمية المستخدمة |
| unit | VARCHAR(10) | — | NO | الوحدة (ml / g / pcs) |
| created_at | TIMESTAMP | — | YES | تاريخ الإنشاء |
| updated_at | TIMESTAMP | — | YES | تاريخ التحديث |

**Indexes:**
- PRIMARY KEY (id)
- FOREIGN KEY (recipe_id) REFERENCES recipes(id)
- FOREIGN KEY (material_id) REFERENCES material_types(id)
- INDEX (recipe_id)
- INDEX (material_id)

**ملاحظة:** يدعم materials فقط (نقطة قرار: دعم منتجات مركبة)

---

### 17. production_logs

**الوظيفة:** تسجيل عمليات الإنتاج الفعلية (Execution Tracking Layer)

| الحقل | النوع | PK/FK | Nullable | الوصف |
|------|------|------|----------|-------|
| id | BIGINT | PK | NO | معرف السجل |
| sale_id | BIGINT | FK → sales | NO | البيع |
| recipe_id | BIGINT | FK → recipes | NO | الوصفة |
| product_id | BIGINT | FK → products | NO | المنتج |
| size_id | BIGINT | FK → sizes | YES | الحجم |
| quantity_produced | DECIMAL(10,2) | — | NO | الكمية المنتجة |
| created_at | TIMESTAMP | — | YES | تاريخ الإنتاج |

**Indexes:**
- PRIMARY KEY (id)
- FOREIGN KEY (sale_id) REFERENCES sales(id)
- FOREIGN KEY (recipe_id) REFERENCES recipes(id)
- FOREIGN KEY (product_id) REFERENCES products(id)
- FOREIGN KEY (size_id) REFERENCES sizes(id)
- INDEX (sale_id)
- INDEX (recipe_id)
- INDEX (created_at)

---

## 📋 جداول المرحلة 6: Production Readiness

---

### 18. transactions

**الوظيفة:** ضمان تنفيذ العمليات بشكل آمن (ACID)

| الحقل | النوع | PK/FK | Nullable | الوصف |
|------|------|------|----------|-------|
| id | BIGINT | PK | NO | معرف العملية |
| type | VARCHAR(50) | — | NO | نوع العملية (sale / update / delete) |
| status | ENUM | — | NO | حالة العملية (pending / committed / failed) |
| started_at | TIMESTAMP | — | YES | وقت البداية |
| completed_at | TIMESTAMP | — | YES | وقت الانتهاء |

**Indexes:**
- PRIMARY KEY (id)
- INDEX (status)
- INDEX (started_at)

**ENUM Values:**
- status: ('pending', 'committed', 'failed')

---

### 19. inventory_reservations

**الوظيفة:** حجز المخزون قبل تأكيد البيع

| الحقل | النوع | PK/FK | Nullable | الوصف |
|------|------|------|----------|-------|
| id | BIGINT | PK | NO | معرف الحجز |
| product_id | BIGINT | FK → products | NO | المنتج |
| quantity | DECIMAL(10,2) | — | NO | الكمية المحجوزة |
| status | ENUM | — | NO | حالة الحجز (reserved / released) |
| created_at | TIMESTAMP | — | YES | تاريخ الحجز |
| updated_at | TIMESTAMP | — | YES | تاريخ التحديث |

**Indexes:**
- PRIMARY KEY (id)
- FOREIGN KEY (product_id) REFERENCES products(id)
- INDEX (product_id)
- INDEX (status)

**ENUM Values:**
- status: ('reserved', 'released')

**ملاحظة:** يمكن إضافة transaction_id للربط

---

### 20. audit_logs

**الوظيفة:** تسجيل كل العمليات داخل النظام

| الحقل | النوع | PK/FK | Nullable | الوصف |
|------|------|------|----------|-------|
| id | BIGINT | PK | NO | معرف السجل |
| user_id | BIGINT | FK → users | NO | المستخدم |
| action | VARCHAR(50) | — | NO | العملية (create / update / delete) |
| entity_type | VARCHAR(50) | — | NO | نوع الكيان (product / sale / inventory) |
| entity_id | BIGINT | — | NO | معرف الكيان |
| changes | JSON | — | YES | تفاصيل التعديل |
| created_at | TIMESTAMP | — | YES | وقت العملية |

**Indexes:**
- PRIMARY KEY (id)
- FOREIGN KEY (user_id) REFERENCES users(id)
- INDEX (user_id)
- INDEX (entity_type, entity_id)
- INDEX (created_at)

---

### 21. accounting_ledger

**الوظيفة:** دفتر حسابات بسيط (POS-level)

| الحقل | النوع | PK/FK | Nullable | الوصف |
|------|------|------|----------|-------|
| id | BIGINT | PK | NO | معرف السجل |
| sale_id | BIGINT | FK → sales | NO | البيع |
| type | ENUM | — | NO | نوع القيد (revenue / cost / profit) |
| amount | DECIMAL(10,2) | — | NO | القيمة |
| description | TEXT | — | YES | شرح |
| created_at | TIMESTAMP | — | YES | التاريخ |

**Indexes:**
- PRIMARY KEY (id)
- FOREIGN KEY (sale_id) REFERENCES sales(id)
- INDEX (sale_id)
- INDEX (type)
- INDEX (created_at)

**ENUM Values:**
- type: ('revenue', 'cost', 'profit')

---

### 22. role_permissions

**الوظيفة:** تحكم في صلاحيات النظام

| الحقل | النوع | PK/FK | Nullable | الوصف |
|------|------|------|----------|-------|
| id | BIGINT | PK | NO | معرف السجل |
| role | VARCHAR(50) | — | NO | الدور (admin / seller) |
| permission | VARCHAR(100) | — | NO | الصلاحية (create_sale / edit_sale) |
| created_at | TIMESTAMP | — | YES | تاريخ الإنشاء |

**Indexes:**
- PRIMARY KEY (id)
- UNIQUE (role, permission)
- INDEX (role)

---

### 23. system_health_logs

**الوظيفة:** مراقبة أخطاء النظام

| الحقل | النوع | PK/FK | Nullable | الوصف |
|------|------|------|----------|-------|
| id | BIGINT | PK | NO | معرف السجل |
| level | ENUM | — | NO | مستوى الخطورة (info / warning / error) |
| message | TEXT | — | NO | الرسالة |
| context | JSON | — | YES | بيانات إضافية |
| created_at | TIMESTAMP | — | YES | الوقت |

**Indexes:**
- PRIMARY KEY (id)
- INDEX (level)
- INDEX (created_at)

**ENUM Values:**
- level: ('info', 'warning', 'error')

---

## 📊 ملخص الجداول

**إجمالي الجداول:** 23 جدول

**حسب المرحلة:**
- المرحلة 1 (Core): 5 جداول
- المرحلة 2 (Pricing): 2 جدول
- المرحلة 3 (Sales): 1 جدول
- المرحلة 4 (Costing): 6 جداول
- المرحلة 5 (Production): 3 جداول
- المرحلة 6 (Safety): 6 جداول

---

## 🔗 العلاقات الرئيسية

```
units
  ↓
categories → products → inventory
              ↓           ↓
         price_tiers   purchase_batches
              ↓           ↓
         tier_prices   batch_inventory
              ↓
            sizes
              ↓
           sales → sale_costs
              ↓      ↓
    production_logs  material_usage
              ↓
           recipes → recipe_items
```

---

## ⚠️ ملاحظات مهمة

1. **جدول users:** مفترض وجوده (Laravel default)
2. **UNIT_BASED:** نقاط قرار مفتوحة في التسعير والبيع
3. **Material Cost:** ثابت حالياً (نقطة قرار: snapshot أو batches)
4. **FIFO:** يعتمد على created_at في batch_inventory
5. **POS-first:** محاسبة بسيطة، لا double-entry

---

## ✅ الحالة

```
Status: COMPLETE ✅
Total Tables: 23
Design Phase: FINISHED
Ready for: Decision Points Resolution
```
