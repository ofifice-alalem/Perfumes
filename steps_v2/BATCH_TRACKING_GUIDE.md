# 🆕 v3.0: تتبع الدفعات وسحب المنتجات (Batch Tracking & Product Recall)

## نظرة عامة
هذا الملف يوثق استخدام batch_number لتتبع دفعات المشتريات وسحب منتجات معينة عند اكتشاف مشاكل جودة.

---

## 📋 التعديلات المطبقة

### 1. جدول purchases
```sql
ALTER TABLE purchases 
ADD COLUMN batch_number VARCHAR(50) NULL AFTER purchase_date,
ADD INDEX idx_purchases_batch (batch_number);
```

### 2. جدول inventory_movements
```sql
ALTER TABLE inventory_movements 
ADD COLUMN batch_number VARCHAR(50) NULL AFTER reference_id,
ADD INDEX idx_inventory_movements_batch (batch_number);
```

---

## 📝 أمثلة الاستخدام

### مثال 1: تسجيل شراء مع رقم دفعة

```sql
-- شراء 200ml من Lacoste White
INSERT INTO purchases (product_id, supplier_id, quantity, unit_cost, total_cost, 
                       purchase_date, batch_number)
VALUES (1, 1, 200, 0.5, 100, '2024-01-15', 'BATCH-2024-001');

-- تحديث المخزون
UPDATE inventory SET quantity = quantity + 200 WHERE product_id = 1;

-- تسجيل الحركة مع رقم الدفعة
INSERT INTO inventory_movements (product_id, movement_type, quantity, 
                                  quantity_before, quantity_after,
                                  reference_type, reference_id, batch_number,
                                  user_id, notes)
VALUES (1, 'in', 200, 0, 200, 'purchase', LAST_INSERT_ID(), 'BATCH-2024-001', 1, 
        'شراء من المورد - دفعة يناير 2024');
```

---

### مثال 2: تتبع البيع مع رقم الدفعة (اختياري)

```sql
-- عند البيع، يمكن تسجيل رقم الدفعة
INSERT INTO inventory_movements (product_id, movement_type, quantity,
                                  quantity_before, quantity_after,
                                  reference_type, reference_id, batch_number,
                                  user_id, notes)
VALUES (1, 'out', 5, 200, 195, 'sale', 1, 'BATCH-2024-001', 1,
        'بيع 5ml من دفعة يناير');
```

---

### مثال 3: سحب منتج (Product Recall) - سيناريو كامل

#### الخطوة 1: اكتشاف مشكلة في دفعة معينة
```sql
-- تحديث حالة الدفعة
UPDATE purchases 
SET notes = '⚠️ موقوف - مشكلة جودة - تم اكتشاف تلوث'
WHERE batch_number = 'BATCH-2024-001';
```

#### الخطوة 2: معرفة الكمية المتبقية من هذه الدفعة
```sql
SELECT 
    p.name as product_name,
    SUM(CASE WHEN im.movement_type = 'in' THEN im.quantity ELSE 0 END) as total_in,
    SUM(CASE WHEN im.movement_type = 'out' THEN im.quantity ELSE 0 END) as total_out,
    SUM(CASE WHEN im.movement_type = 'in' THEN im.quantity ELSE 0 END) - 
    SUM(CASE WHEN im.movement_type = 'out' THEN im.quantity ELSE 0 END) as remaining_quantity
FROM inventory_movements im
JOIN products p ON im.product_id = p.id
WHERE im.batch_number = 'BATCH-2024-001'
GROUP BY p.id, p.name;
```

**النتيجة:**
```
| product_name   | total_in | total_out | remaining_quantity |
|----------------|----------|-----------|-------------------|
| Lacoste White  | 200      | 50        | 150               |
```

#### الخطوة 3: معرفة من اشترى من هذه الدفعة
```sql
SELECT 
    i.invoice_number,
    i.created_at as sale_date,
    c.name as customer_name,
    c.phone as customer_phone,
    c.email as customer_email,
    p.name as product_name,
    ii.quantity,
    im.batch_number
FROM inventory_movements im
JOIN invoice_items ii ON im.reference_id = ii.id AND im.reference_type = 'sale'
JOIN invoices i ON ii.invoice_id = i.id
JOIN products p ON im.product_id = p.id
LEFT JOIN customers c ON i.customer_id = c.id
WHERE im.batch_number = 'BATCH-2024-001'
  AND im.movement_type = 'out'
ORDER BY i.created_at DESC;
```

**النتيجة:**
```
| invoice_number | sale_date  | customer_name | customer_phone | product_name  | quantity |
|----------------|------------|---------------|----------------|---------------|----------|
| INV-2024-001   | 2024-01-16 | أحمد محمد     | 0501234567     | Lacoste White | 5        |
| INV-2024-005   | 2024-01-17 | فاطمة علي     | 0509876543     | Lacoste White | 10       |
| INV-2024-012   | 2024-01-18 | NULL          | NULL           | Lacoste White | 3        |
```

#### الخطوة 4: إيقاف بيع المنتج من هذه الدفعة
```sql
-- تحديث المنتج مؤقتاً
UPDATE products 
SET notes = CONCAT(COALESCE(notes, ''), ' - ⚠️ دفعة BATCH-2024-001 موقوفة')
WHERE id = 1;

-- أو إنشاء جدول مؤقت للدفعات الموقوفة
CREATE TABLE IF NOT EXISTS suspended_batches (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    batch_number VARCHAR(50) NOT NULL,
    product_id BIGINT UNSIGNED NOT NULL,
    reason TEXT NOT NULL,
    suspended_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_suspended_batches_product FOREIGN KEY (product_id) REFERENCES products(id)
);

INSERT INTO suspended_batches (batch_number, product_id, reason)
VALUES ('BATCH-2024-001', 1, 'تلوث في المنتج - يجب سحبه من السوق');
```

#### الخطوة 5: التواصل مع العملاء
```sql
-- قائمة العملاء للتواصل معهم
SELECT DISTINCT
    c.name,
    c.phone,
    c.email,
    'عزيزي العميل، نود إعلامك بسحب منتج Lacoste White من دفعة يناير 2024 لأسباب تتعلق بالجودة. يرجى التواصل معنا لاستبدال المنتج.' as message
FROM inventory_movements im
JOIN invoice_items ii ON im.reference_id = ii.id AND im.reference_type = 'sale'
JOIN invoices i ON ii.invoice_id = i.id
JOIN customers c ON i.customer_id = c.id
WHERE im.batch_number = 'BATCH-2024-001'
  AND im.movement_type = 'out'
  AND c.phone IS NOT NULL;
```

#### الخطوة 6: سحب الكمية المتبقية من المخزون
```sql
-- حساب الكمية المتبقية
SELECT @remaining := 
    SUM(CASE WHEN movement_type = 'in' THEN quantity ELSE 0 END) - 
    SUM(CASE WHEN movement_type = 'out' THEN quantity ELSE 0 END)
FROM inventory_movements
WHERE batch_number = 'BATCH-2024-001';

-- سحب من المخزون
UPDATE inventory 
SET quantity = quantity - @remaining
WHERE product_id = 1;

-- تسجيل الحركة
INSERT INTO inventory_movements (product_id, movement_type, quantity,
                                  quantity_before, quantity_after,
                                  reference_type, batch_number, user_id, notes)
SELECT 1, 'adjustment', -@remaining, 
       (SELECT quantity FROM inventory WHERE product_id = 1) + @remaining,
       (SELECT quantity FROM inventory WHERE product_id = 1),
       'recall', 'BATCH-2024-001', 1,
       'سحب منتج - دفعة BATCH-2024-001 - مشكلة جودة';
```

---

## 📊 التقارير المفيدة

### 1. تقرير الدفعات النشطة
```sql
SELECT 
    pu.batch_number,
    p.name as product_name,
    s.name as supplier_name,
    pu.purchase_date,
    pu.quantity as purchased_quantity,
    COALESCE(SUM(CASE WHEN im.movement_type = 'out' THEN im.quantity ELSE 0 END), 0) as sold_quantity,
    pu.quantity - COALESCE(SUM(CASE WHEN im.movement_type = 'out' THEN im.quantity ELSE 0 END), 0) as remaining_quantity
FROM purchases pu
JOIN products p ON pu.product_id = p.id
LEFT JOIN suppliers s ON pu.supplier_id = s.id
LEFT JOIN inventory_movements im ON pu.batch_number = im.batch_number AND im.movement_type = 'out'
WHERE pu.batch_number IS NOT NULL
GROUP BY pu.batch_number, p.name, s.name, pu.purchase_date, pu.quantity
HAVING remaining_quantity > 0
ORDER BY pu.purchase_date DESC;
```

### 2. تقرير المبيعات حسب الدفعة
```sql
SELECT 
    im.batch_number,
    p.name as product_name,
    COUNT(DISTINCT i.id) as invoices_count,
    SUM(ii.quantity) as total_quantity_sold,
    SUM(ii.total_price) as total_revenue,
    MIN(i.created_at) as first_sale,
    MAX(i.created_at) as last_sale
FROM inventory_movements im
JOIN invoice_items ii ON im.reference_id = ii.id AND im.reference_type = 'sale'
JOIN invoices i ON ii.invoice_id = i.id
JOIN products p ON im.product_id = p.id
WHERE im.batch_number IS NOT NULL
  AND im.movement_type = 'out'
GROUP BY im.batch_number, p.name
ORDER BY total_revenue DESC;
```

### 3. تقرير الدفعات القديمة (FEFO - First Expired First Out)
```sql
SELECT 
    pu.batch_number,
    p.name as product_name,
    pu.purchase_date,
    DATEDIFF(CURDATE(), pu.purchase_date) as days_in_stock,
    pu.quantity - COALESCE(SUM(CASE WHEN im.movement_type = 'out' THEN im.quantity ELSE 0 END), 0) as remaining_quantity
FROM purchases pu
JOIN products p ON pu.product_id = p.id
LEFT JOIN inventory_movements im ON pu.batch_number = im.batch_number AND im.movement_type = 'out'
WHERE pu.batch_number IS NOT NULL
GROUP BY pu.batch_number, p.name, pu.purchase_date, pu.quantity
HAVING remaining_quantity > 0 AND days_in_stock > 90
ORDER BY days_in_stock DESC;
```

---

## 🎯 الفوائد

✅ **تتبع دقيق:** معرفة مصدر كل منتج  
✅ **سحب سريع:** إمكانية سحب دفعة كاملة بسرعة  
✅ **حماية العملاء:** التواصل الفوري عند اكتشاف مشاكل  
✅ **تحليل الموردين:** معرفة أي مورد يسبب مشاكل  
✅ **إدارة المخزون:** تتبع الدفعات القديمة (FEFO)  

---

## ⚠️ ملاحظات مهمة

1. ✅ batch_number اختياري (NULL) - ليس إلزامياً لجميع المشتريات
2. ✅ يُنصح باستخدامه للمنتجات الحساسة (عطور، مواد غذائية)
3. ✅ يمكن استخدام نظام ترقيم موحد: `BATCH-YYYY-NNN`
4. ✅ عند البيع، تسجيل batch_number اختياري (للتتبع الكامل)
5. ✅ لا يتطلب نظام FIFO معقد - فقط للتتبع والسحب

---

**تاريخ الإنشاء:** 2024  
**الإصدار:** v3.0  
**الحالة:** ✅ مكتمل
