# خطة تعديل مجلد steps

---

## 📌 المبدأ العام
- الجداول المرتبطة بعملية موجودة → تُضمَّن في الـ step الخاص بها
- الجداول التي تمثل عملية مستقلة → step جديد

---

## ✏️ تعديلات على steps موجودة

---

### step 1 — تعريف المنتج والمخزون

**إضافة:**
- `product_images` — صور المنتجات، تابعة للمنتج مباشرة

---

### step 3 — عملية البيع

**إضافة:**
- `customers` — العميل جزء من عملية البيع (اختياري في POS)
- `invoices` — الفاتورة تجمع عدة مبيعات في سجل واحد
- `invoice_items` — تفاصيل منتجات الفاتورة
- `payment_methods` — طرق الدفع تُحدد عند البيع
- `payments` — تسجيل الدفع المرتبط بالبيع أو الفاتورة

**تعديل على جدول موجود:**
- `sales` ← إضافة حقل `invoice_id` (nullable — FK → invoices)
- `sales` ← إضافة حقل `customer_id` (nullable — FK → customers)

---

### step 4 — التكاليف التشغيلية

**إضافة:**
- `suppliers` — المورد مرتبط بعملية الشراء
- `material_batches` — دفعات شراء المواد التشغيلية
- `material_inventory` — مخزون المواد مع FIFO

**تعديل على جدول موجود:**
- `purchase_batches` ← استبدال `supplier_name` VARCHAR بـ `supplier_id` FK → suppliers
- `material_usage` ← إضافة `cost_per_unit_snapshot`, `total_cost`, `material_batch_id`

---

## 🆕 steps جديدة

---

### step 7 — تتبع حركات المخزون

**جداول جديدة:**
- `inventory_movements` — سجل موحد لكل حركات المخزون (إضافة / خصم / تعديل / فاقد / مرتجع)

**السبب:** هذا الجدول يتأثر من جميع العمليات (بيع، شراء، فاقد، مرتجع) لذا يستحق step مستقل يشرح كيف يتغذى من كل العمليات السابقة.

---

### step 8 — المرتجعات

**جداول جديدة:**
- `returns` — رأس المرتجع
- `return_items` — تفاصيل المنتجات المرتجعة

**السبب:** عملية مستقلة لها flow خاص (إنشاء → موافقة → إعادة مخزون → تعديل محاسبة).

---

### step 9 — الخصومات والعروض

**جداول جديدة:**
- `discounts` — تعريف الخصومات
- `discount_products` — ربط الخصومات بالمنتجات

**السبب:** منطق مستقل يتدخل في عملية التسعير والبيع.

---

### step 10 — ميزات متقدمة

**جداول جديدة:**
- `notifications` — إشعارات النظام
- `loyalty_programs` — برامج الولاء
- `customer_points` — نقاط العملاء
- `expenses` — المصروفات التشغيلية
- `reports_cache` — تخزين التقارير المحسوبة

**السبب:** ميزات مستقبلية لا تؤثر على المنطق الأساسي، تُجمع في step واحد.

---

## 📊 ملخص التغييرات

| النوع | العدد | التفاصيل |
|-------|-------|----------|
| steps تُعدَّل | 3 | step 1, step 3, step 4 |
| steps جديدة | 4 | step 7, step 8, step 9, step 10 |
| جداول تُضاف لـ steps موجودة | 10 | product_images, customers, invoices, invoice_items, payment_methods, payments, suppliers, material_batches, material_inventory |
| جداول في steps جديدة | 7 | inventory_movements, returns, return_items, discounts, discount_products, notifications, loyalty_programs, customer_points, expenses, reports_cache |
| جداول تُعدَّل (حقول تُضاف) | 3 | sales, purchase_batches, material_usage |

---

## 🔢 ترتيب التنفيذ

1. تعديل `step 1` ← إضافة product_images
2. تعديل `step 3` ← إضافة customers + invoices + invoice_items + payment_methods + payments + تعديل sales
3. تعديل `step 4` ← إضافة suppliers + material_batches + material_inventory + تعديل purchase_batches + material_usage
4. إنشاء `step 7` ← inventory_movements
5. إنشاء `step 8` ← returns + return_items
6. إنشاء `step 9` ← discounts + discount_products
7. إنشاء `step 10` ← ميزات متقدمة

---

## ⚠️ ملاحظات

- لا يوجد `step 3_5` أو `step 3_6` — الترقيم يبدأ من 7 مباشرة بعد 6
- `customers` يُضاف في step 3 لأن البيع هو السياق الأساسي له
- `suppliers` يُضاف في step 4 لأن الشراء هو السياق الأساسي له
- `inventory_movements` يأخذ step مستقل لأنه يتغذى من جميع العمليات
