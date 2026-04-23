# تحديثات النظام v2.1

## نظرة عامة
هذا الملف يوثق التحسينات المطبقة على النظام المبسط v2 لتحسين الدقة المحاسبية والواقع التجاري.

---

## 1️⃣ المرحلة 1: تعريف المنتج والمخزون

### التحديثات على جدول `products`
```sql
-- إضافة حقل SKU للمنتجات
ALTER TABLE products ADD COLUMN sku VARCHAR(50) NULL UNIQUE AFTER name;
```

**الفائدة:**
- تسهيل البحث والربط مع أنظمة ERP
- دعم الباركود
- تتبع فريد لكل منتج

---

### التحديثات على جدول `inventory`
```sql
-- إضافة حقل الحد الأدنى للمخزون
ALTER TABLE inventory ADD COLUMN min_stock_level DECIMAL(10,2) NULL DEFAULT 0 AFTER quantity;
```

**الفائدة:**
- تنبيهات تلقائية عند انخفاض المخزون
- إدارة أفضل للمخزون
- تجنب نفاد المخزون

---

## 2️⃣ المرحلة 3: عملية البيع

### التحديثات على جدول `invoices`
```sql
-- إضافة حقول الدفع الجزئي
ALTER TABLE invoices 
ADD COLUMN paid_amount DECIMAL(10,2) NOT NULL DEFAULT 0 AFTER total,
ADD COLUMN due_amount DECIMAL(10,2) NOT NULL DEFAULT 0 AFTER paid_amount,
ADD COLUMN payment_status ENUM('unpaid','partial','paid') NOT NULL DEFAULT 'unpaid' AFTER due_amount;
```

**الفائدة:**
- دعم الدفع الجزئي (العميل يدفع جزء الآن وجزء لاحقاً)
- تتبع المديونيات
- واقعية أكثر للعمليات التجارية

**القواعد الجديدة:**
- `paid_amount`: المبلغ المدفوع فعلياً
- `due_amount`: المبلغ المتبقي = `total - paid_amount`
- `payment_status`:
  - `unpaid`: لم يُدفع شيء
  - `partial`: دُفع جزء
  - `paid`: دُفع كاملاً

---

### التحديثات على جدول `payments`
```sql
-- إزالة قيد الدفعة الواحدة - السماح بدفعات متعددة
-- لا حاجة لتعديل الجدول، فقط تغيير المنطق:
-- يمكن الآن إضافة عدة سجلات في payments لنفس invoice_id
```

**الفائدة:**
- دعم طرق دفع متعددة (نقدي + بطاقة)
- دفعات متعددة على مراحل
- مرونة أكبر في الدفع

**مثال:**
```sql
-- الفاتورة: 100 دينار
-- الدفعة 1: 60 دينار نقدي
INSERT INTO payments (invoice_id, payment_method_id, amount) VALUES (1, 1, 60);

-- الدفعة 2: 40 دينار بطاقة
INSERT INTO payments (invoice_id, payment_method_id, amount) VALUES (1, 2, 40);

-- تحديث الفاتورة
UPDATE invoices SET 
    paid_amount = 100,
    due_amount = 0,
    payment_status = 'paid'
WHERE id = 1;
```

---

## 3️⃣ المرحلة 4: التكاليف والوصفات

### التحديثات على جدول `invoice_items`
```sql
-- إضافة snapshot لتكلفة المنتج وقت البيع
ALTER TABLE invoice_items 
ADD COLUMN product_unit_cost DECIMAL(10,2) NULL AFTER unit_price;
```

**الفائدة:**
- حفظ تكلفة المنتج وقت البيع (لا تتأثر بتغيير الأسعار لاحقاً)
- دقة محاسبية عالية
- حساب الربح الحقيقي لكل عملية بيع

**كيفية الحساب:**
```sql
-- عند البيع، نحسب متوسط تكلفة المنتج من جدول purchases
SELECT AVG(unit_cost) FROM purchases WHERE product_id = ?;

-- ثم نخزنها في invoice_items.product_unit_cost
```

---

### التحديثات على جدول `recipe_items`
```sql
-- إضافة نسبة الهدر للمواد
ALTER TABLE recipe_items 
ADD COLUMN waste_percentage DECIMAL(5,2) NOT NULL DEFAULT 0 AFTER quantity;
```

**الفائدة:**
- مراعاة الهدر الطبيعي (تبخر الكحول، كسر الزجاج، إلخ)
- حساب أدق للتكاليف
- واقعية أكثر

**الصيغة الجديدة:**
```
الكمية الفعلية المستخدمة = quantity × (1 + waste_percentage / 100)
```

**مثال:**
```sql
-- وصفة تحتاج 10ml كحول
-- نسبة الهدر: 5%
-- الكمية الفعلية = 10 × (1 + 5/100) = 10 × 1.05 = 10.5ml

INSERT INTO recipe_items (recipe_id, material_id, quantity, waste_percentage, unit)
VALUES (1, 1, 10, 5, 'ml');
```

---

## 4️⃣ المرحلة 6: المرتجعات

### التحديثات على جدول `returns`
```sql
-- إضافة رسوم إعادة التخزين
ALTER TABLE returns 
ADD COLUMN restock_fee DECIMAL(10,2) NOT NULL DEFAULT 0 AFTER refund_amount,
ADD COLUMN restock_fee_percentage DECIMAL(5,2) NULL AFTER restock_fee;
```

**الفائدة:**
- خصم رسوم على المنتجات المستعملة أو التالفة
- حماية الأرباح
- واقعية أكثر

**القواعد:**
- `restock_fee`: رسوم ثابتة (مثلاً 5 دينار)
- `restock_fee_percentage`: نسبة مئوية من المبلغ المسترد
- المبلغ المسترد النهائي = `refund_amount - restock_fee`

**مثال:**
```sql
-- مرتجع بقيمة 100 دينار
-- رسوم إعادة تخزين: 10%
-- المبلغ المسترد = 100 - (100 × 10%) = 90 دينار

UPDATE returns SET 
    refund_amount = 100,
    restock_fee_percentage = 10,
    restock_fee = 10
WHERE id = 1;
```

---

### إضافة جدول `return_cost_reversals`
```sql
-- جدول جديد لعكس التكاليف عند المرتجع
CREATE TABLE return_cost_reversals (
    id                  BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    return_id           BIGINT UNSIGNED NOT NULL,
    invoice_cost_id     BIGINT UNSIGNED NOT NULL,
    product_cost        DECIMAL(10,2) NOT NULL DEFAULT 0,
    material_cost       DECIMAL(10,2) NOT NULL DEFAULT 0,
    total_cost          DECIMAL(10,2) NOT NULL DEFAULT 0,
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_return_cost_reversals_return FOREIGN KEY (return_id) REFERENCES returns(id),
    CONSTRAINT fk_return_cost_reversals_invoice_cost FOREIGN KEY (invoice_cost_id) REFERENCES invoice_costs(id),
    UNIQUE KEY uq_return_cost_reversals_return (return_id)
);
```

**الفائدة:**
- عكس التكاليف عند المرتجع
- دقة في حساب الأرباح
- تتبع كامل للتكاليف المستردة

**كيفية العمل:**
1. عند اكتمال المرتجع (`status = 'completed'`)
2. نحسب التكاليف الأصلية من `invoice_costs`
3. نعكسها في `return_cost_reversals` (قيم سالبة)
4. نعيد المخزون

**مثال:**
```sql
-- الفاتورة الأصلية:
-- product_cost = 50, material_cost = 10, total_cost = 60

-- عند المرتجع الكامل:
INSERT INTO return_cost_reversals (return_id, invoice_cost_id, product_cost, material_cost, total_cost)
VALUES (1, 1, -50, -10, -60);

-- الربح الحقيقي = (إيرادات - تكاليف) - (مرتجعات - تكاليف مستردة)
```

---

## 📊 ملخص التحديثات

### الجداول المعدلة:
1. ✅ `products` - إضافة `sku`
2. ✅ `inventory` - إضافة `min_stock_level`
3. ✅ `invoices` - إضافة `paid_amount`, `due_amount`, `payment_status`
4. ✅ `invoice_items` - إضافة `product_unit_cost`
5. ✅ `recipe_items` - إضافة `waste_percentage`
6. ✅ `returns` - إضافة `restock_fee`, `restock_fee_percentage`

### الجداول الجديدة:
1. ✅ `return_cost_reversals` - عكس التكاليف عند المرتجع

### التغييرات في المنطق:
1. ✅ دعم دفعات متعددة في `payments`
2. ✅ حساب الدفع الجزئي تلقائياً
3. ✅ حفظ snapshot التكلفة عند البيع
4. ✅ حساب الهدر في الوصفات
5. ✅ عكس التكاليف عند المرتجع

---

## 🎯 الفوائد الإجمالية

### دقة محاسبية:
- ✅ Snapshot التكلفة يحفظ الربح الحقيقي
- ✅ عكس التكاليف عند المرتجع يضمن دقة الأرباح
- ✅ حساب الهدر يعطي تكاليف واقعية

### واقعية تجارية:
- ✅ الدفع الجزئي يعكس الواقع
- ✅ طرق دفع متعددة
- ✅ رسوم إعادة التخزين

### إدارة أفضل:
- ✅ تنبيهات المخزون المنخفض
- ✅ SKU للتتبع الفريد
- ✅ تتبع المديونيات

---

## 📝 ملاحظات التطبيق

### الترتيب الموصى به:
1. تطبيق التعديلات على `create_tables_ordered.sql`
2. تحديث `step_1` (SKU + min_stock_level)
3. تحديث `step_3` (الدفع الجزئي)
4. تحديث `step_4` (Snapshot + waste_percentage)
5. تحديث `step_6` (عكس التكاليف + restock_fee)

### التوافق مع النظام الحالي:
- ✅ جميع التعديلات متوافقة مع البيانات الموجودة
- ✅ الحقول الجديدة لها قيم افتراضية
- ✅ لا حاجة لحذف بيانات

---

## ✅ حالة التطبيق

- [ ] تحديث `create_tables_ordered.sql`
- [ ] تحديث `step_1-تعريف_المنتج_والمخزون.txt`
- [ ] تحديث `step_3-عملية_البيع.txt`
- [ ] تحديث `step_4-التكاليف_والوصفات_جزء1.txt`
- [ ] تحديث `step_6-المرتجعات.txt`

---

**تاريخ الإنشاء:** 2024
**الإصدار:** v2.1
**الحالة:** جاهز للتطبيق
