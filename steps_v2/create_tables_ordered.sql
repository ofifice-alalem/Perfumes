================================================================================
                    جداول قاعدة البيانات — النظام المبسط (v2)
================================================================================

📌 التحسينات الرئيسية:
   ✅ تقليل الجداول من 44 إلى 28 جدول
   ✅ إزالة تعقيد FIFO المزدوج واستبداله بمتوسط التكلفة
   ✅ دمج الجداول المتشابهة
   ✅ إزالة الميزات المتقدمة غير الضرورية في البداية
   ✅ الحفاظ على نفس آلية العمل والدقة

📌 القاعدة: كل جدول يحتوي FK يأتي بعد الجدول الذي يحتوي PK المرتبط به.

================================================================================


-- ============================================================
-- 1. units
-- لا يعتمد على أي جدول
-- الوحدات الأساسية للقياس (ml, g, pcs)
-- ============================================================
CREATE TABLE units (
    id         BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name       VARCHAR(50)  NOT NULL,
    symbol     VARCHAR(10)  NOT NULL,
    created_at TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP    DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_units_symbol (symbol)
);


-- ============================================================
-- 2. price_tiers
-- لا يعتمد على أي جدول
-- مستويات الجودة (A, B, C) للتسعير المركزي
-- ============================================================
CREATE TABLE price_tiers (
    id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(10)  NOT NULL,
    description TEXT         NULL,
    created_at  TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP    DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_price_tiers_name (name)
);


-- ============================================================
-- 3. categories
-- يعتمد على: units
-- تصنيفات المنتجات مع وحدة القياس
-- ============================================================
CREATE TABLE categories (
    id         BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name       VARCHAR(255) NOT NULL,
    unit_id    BIGINT UNSIGNED NOT NULL,
    created_at TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP    DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_categories_unit FOREIGN KEY (unit_id) REFERENCES units(id)
);


-- ============================================================
-- 4. sizes
-- يعتمد على: units
-- أحجام البيع المتاحة (1ml, 3ml, 5ml, 200ml, ...)
-- ============================================================
CREATE TABLE sizes (
    id         BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name       VARCHAR(50)    NOT NULL,
    value      DECIMAL(10,2)  NOT NULL,
    unit_id    BIGINT UNSIGNED NOT NULL,
    created_at TIMESTAMP      DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP      DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_sizes_unit FOREIGN KEY (unit_id) REFERENCES units(id)
);


-- ============================================================
-- 5. payment_methods
-- لا يعتمد على أي جدول
-- طرق الدفع المتاحة (نقدي، بطاقة، تحويل)
-- ============================================================
CREATE TABLE payment_methods (
    id         BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name       VARCHAR(50)  NOT NULL,
    is_active  BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP    DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_payment_methods_name (name)
);


-- ============================================================
-- 6. users
-- لا يعتمد على أي جدول
-- المستخدمين (Admin, Seller)
-- ============================================================
CREATE TABLE users (
    id                BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name              VARCHAR(255) NOT NULL,
    email             VARCHAR(255) NOT NULL,
    password          VARCHAR(255) NOT NULL,
    role              VARCHAR(50)  NOT NULL,
    is_active         BOOLEAN      NOT NULL DEFAULT TRUE,
    email_verified_at TIMESTAMP    NULL,
    remember_token    VARCHAR(100) NULL,
    created_at        TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    updated_at        TIMESTAMP    DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_users_email (email),
    INDEX idx_users_role (role)
);


-- ============================================================
-- 7. customers
-- لا يعتمد على أي جدول
-- بيانات العملاء
-- ============================================================
CREATE TABLE customers (
    id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name            VARCHAR(255)    NOT NULL,
    phone           VARCHAR(20)     NULL,
    email           VARCHAR(255)    NULL,
    address         TEXT            NULL,
    total_purchases DECIMAL(10,2)   NOT NULL DEFAULT 0,
    is_active       BOOLEAN         NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP       DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_customers_phone (phone),
    INDEX idx_customers_is_active (is_active)
);


-- ============================================================
-- 8. suppliers
-- لا يعتمد على أي جدول
-- بيانات الموردين
-- ============================================================
CREATE TABLE suppliers (
    id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name            VARCHAR(255)    NOT NULL,
    phone           VARCHAR(20)     NULL,
    email           VARCHAR(255)    NULL,
    address         TEXT            NULL,
    total_purchases DECIMAL(10,2)   NOT NULL DEFAULT 0,
    is_active       BOOLEAN         NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP       DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_suppliers_phone (phone),
    INDEX idx_suppliers_is_active (is_active)
);


-- ============================================================
-- 9. products
-- يعتمد على: categories, price_tiers
-- المنتجات مع نوع البيع
-- 📌 v2.1: إضافة SKU للتتبع الفريد
-- ============================================================
CREATE TABLE products (
    id             BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name           VARCHAR(255) NOT NULL,
    sku            VARCHAR(50)  NULL,
    category_id    BIGINT UNSIGNED NOT NULL,
    price_tier_id  BIGINT UNSIGNED NOT NULL,
    selling_type   ENUM('DECANT_ONLY','FULL_ONLY','BOTH','UNIT_BASED') NOT NULL,
    created_at     TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    updated_at     TIMESTAMP    DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_products_category  FOREIGN KEY (category_id)   REFERENCES categories(id),
    CONSTRAINT fk_products_tier      FOREIGN KEY (price_tier_id) REFERENCES price_tiers(id),
    UNIQUE KEY uq_products_sku (sku),
    INDEX idx_products_selling_type (selling_type)
);


-- ============================================================
-- 10. inventory
-- يعتمد على: products, units
-- المخزون الحالي لكل منتج
-- 📌 v2.1: إضافة min_stock_level للتنبيهات
-- ============================================================
CREATE TABLE inventory (
    id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    product_id      BIGINT UNSIGNED NOT NULL,
    quantity        DECIMAL(10,2)   NOT NULL DEFAULT 0,
    min_stock_level DECIMAL(10,2)   NULL DEFAULT 0,
    unit_id         BIGINT UNSIGNED NOT NULL,
    created_at      TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP       DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_inventory_product FOREIGN KEY (product_id) REFERENCES products(id),
    CONSTRAINT fk_inventory_unit    FOREIGN KEY (unit_id)    REFERENCES units(id),
    UNIQUE KEY uq_inventory_product (product_id)
);


-- ============================================================
-- 11. product_images
-- يعتمد على: products
-- صور المنتجات
-- ============================================================
CREATE TABLE product_images (
    id         BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    product_id BIGINT UNSIGNED NOT NULL,
    image_path VARCHAR(255)    NOT NULL,
    is_primary BOOLEAN         NOT NULL DEFAULT FALSE,
    order_num  INT             NOT NULL DEFAULT 0,
    created_at TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_product_images_product FOREIGN KEY (product_id) REFERENCES products(id),
    INDEX idx_product_images_product (product_id),
    INDEX idx_product_images_primary (is_primary)
);


-- ============================================================
-- 12. tier_prices
-- يعتمد على: price_tiers, sizes
-- جدول الأسعار المركزي (Tier + Size → Price)
-- ============================================================
CREATE TABLE tier_prices (
    id         BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    tier_id    BIGINT UNSIGNED NOT NULL,
    size_id    BIGINT UNSIGNED NOT NULL,
    price      DECIMAL(10,2)   NOT NULL,
    created_at TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP       DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_tier_prices_tier FOREIGN KEY (tier_id) REFERENCES price_tiers(id),
    CONSTRAINT fk_tier_prices_size FOREIGN KEY (size_id) REFERENCES sizes(id),
    UNIQUE KEY uq_tier_prices (tier_id, size_id)
);


-- ============================================================
-- 13. unit_based_prices
-- يعتمد على: products, price_tiers
-- تسعير المنتجات UNIT_BASED (بخور/وشق)
-- ============================================================
CREATE TABLE unit_based_prices (
    id             BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    product_id     BIGINT UNSIGNED NOT NULL,
    tier_id        BIGINT UNSIGNED NOT NULL,
    price_per_unit DECIMAL(10,2)   NOT NULL,
    created_at     TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    updated_at     TIMESTAMP       DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_unit_prices_product FOREIGN KEY (product_id) REFERENCES products(id),
    CONSTRAINT fk_unit_prices_tier    FOREIGN KEY (tier_id)    REFERENCES price_tiers(id),
    UNIQUE KEY uq_unit_based_prices (product_id, tier_id)
);


-- ============================================================
-- 14. material_types
-- لا يعتمد على أي جدول
-- المواد التشغيلية (كحول، زجاج، عبوات)
-- 📌 التبسيط: avg_cost يُحدث تلقائياً عند كل شراء (Weighted Average)
-- ============================================================
CREATE TABLE material_types (
    id            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name          VARCHAR(100)    NOT NULL,
    unit          VARCHAR(10)     NOT NULL,
    avg_cost      DECIMAL(10,2)   NOT NULL DEFAULT 0,
    total_quantity DECIMAL(10,2)  NOT NULL DEFAULT 0,
    created_at    TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP       DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);


-- ============================================================
-- 15. invoices
-- يعتمد على: customers, users
-- رأس الفاتورة
-- 📌 v2.1: إضافة دعم الدفع الجزئي
-- ============================================================
CREATE TABLE invoices (
    id             BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    invoice_number VARCHAR(50)     NOT NULL,
    customer_id    BIGINT UNSIGNED NULL,
    user_id        BIGINT UNSIGNED NOT NULL,
    subtotal       DECIMAL(10,2)   NOT NULL DEFAULT 0,
    discount       DECIMAL(10,2)   NOT NULL DEFAULT 0,
    total          DECIMAL(10,2)   NOT NULL DEFAULT 0,
    paid_amount    DECIMAL(10,2)   NOT NULL DEFAULT 0,
    due_amount     DECIMAL(10,2)   NOT NULL DEFAULT 0,
    payment_status ENUM('unpaid','partial','paid') NOT NULL DEFAULT 'unpaid',
    status         ENUM('completed','cancelled','refunded') NOT NULL DEFAULT 'completed',
    notes          TEXT            NULL,
    created_at     TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    updated_at     TIMESTAMP       DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_invoices_customer FOREIGN KEY (customer_id) REFERENCES customers(id),
    CONSTRAINT fk_invoices_user     FOREIGN KEY (user_id)     REFERENCES users(id),
    UNIQUE KEY uq_invoices_number (invoice_number),
    INDEX idx_invoices_customer (customer_id),
    INDEX idx_invoices_status (status),
    INDEX idx_invoices_payment_status (payment_status),
    INDEX idx_invoices_created_at (created_at)
);


-- ============================================================
-- 16. invoice_items
-- يعتمد على: invoices, products, sizes
-- تفاصيل المنتجات في الفاتورة
-- 📌 v2.1: إضافة product_unit_cost (snapshot للتكلفة)
-- ============================================================
CREATE TABLE invoice_items (
    id                BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    invoice_id        BIGINT UNSIGNED NOT NULL,
    product_id        BIGINT UNSIGNED NOT NULL,
    sale_type         ENUM('decant','full','unit_based') NOT NULL,
    size_id           BIGINT UNSIGNED NULL,
    quantity          DECIMAL(10,2)   NOT NULL,
    unit_price        DECIMAL(10,2)   NOT NULL,
    product_unit_cost DECIMAL(10,2)   NULL,
    discount          DECIMAL(10,2)   NOT NULL DEFAULT 0,
    total_price       DECIMAL(10,2)   NOT NULL,
    created_at        TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_invoice_items_invoice FOREIGN KEY (invoice_id) REFERENCES invoices(id) ON DELETE CASCADE,
    CONSTRAINT fk_invoice_items_product FOREIGN KEY (product_id) REFERENCES products(id),
    CONSTRAINT fk_invoice_items_size    FOREIGN KEY (size_id)    REFERENCES sizes(id),
    INDEX idx_invoice_items_invoice (invoice_id),
    INDEX idx_invoice_items_product (product_id)
);


-- ============================================================
-- 17. payments
-- يعتمد على: invoices, payment_methods
-- سجل الدفع
-- ============================================================
CREATE TABLE payments (
    id                BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    invoice_id        BIGINT UNSIGNED NOT NULL,
    payment_method_id BIGINT UNSIGNED NOT NULL,
    amount            DECIMAL(10,2)   NOT NULL,
    reference         VARCHAR(100)    NULL,
    created_at        TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_payments_invoice FOREIGN KEY (invoice_id)       REFERENCES invoices(id),
    CONSTRAINT fk_payments_method  FOREIGN KEY (payment_method_id) REFERENCES payment_methods(id),
    INDEX idx_payments_invoice (invoice_id),
    INDEX idx_payments_created_at (created_at)
);


-- ============================================================
-- 18. purchases
-- يعتمد على: products, suppliers
-- 📌 التبسيط: دمج purchase_batches + batch_inventory في جدول واحد
-- تسجيل المشتريات مع متوسط التكلفة
-- ============================================================
CREATE TABLE purchases (
    id            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    product_id    BIGINT UNSIGNED NOT NULL,
    supplier_id   BIGINT UNSIGNED NULL,
    quantity      DECIMAL(10,2)   NOT NULL,
    unit_cost     DECIMAL(10,2)   NOT NULL,
    total_cost    DECIMAL(10,2)   NOT NULL,
    purchase_date DATE            NOT NULL,
    created_at    TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_purchases_product  FOREIGN KEY (product_id)  REFERENCES products(id),
    CONSTRAINT fk_purchases_supplier FOREIGN KEY (supplier_id) REFERENCES suppliers(id),
    INDEX idx_purchases_product       (product_id),
    INDEX idx_purchases_purchase_date (purchase_date)
);


-- ============================================================
-- 19. material_purchases
-- يعتمد على: material_types, suppliers
-- 📌 التبسيط: دمج material_batches + material_inventory
-- شراء المواد التشغيلية مع تحديث متوسط التكلفة تلقائياً
-- ============================================================
CREATE TABLE material_purchases (
    id            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    material_id   BIGINT UNSIGNED NOT NULL,
    supplier_id   BIGINT UNSIGNED NULL,
    quantity      DECIMAL(10,2)   NOT NULL,
    unit_cost     DECIMAL(10,2)   NOT NULL,
    total_cost    DECIMAL(10,2)   NOT NULL,
    purchase_date DATE            NOT NULL,
    created_at    TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_material_purchases_material FOREIGN KEY (material_id) REFERENCES material_types(id),
    CONSTRAINT fk_material_purchases_supplier FOREIGN KEY (supplier_id) REFERENCES suppliers(id),
    INDEX idx_material_purchases_material (material_id),
    INDEX idx_material_purchases_date (purchase_date)
);


-- ============================================================
-- 20. recipes
-- يعتمد على: products, sizes
-- وصفات الإنتاج لكل منتج
-- ============================================================
CREATE TABLE recipes (
    id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    product_id  BIGINT UNSIGNED NOT NULL,
    recipe_type ENUM('size_based','unit_based') NOT NULL,
    size_id     BIGINT UNSIGNED NULL,
    is_active   BOOLEAN         NOT NULL DEFAULT TRUE,
    created_at  TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP       DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_recipes_product FOREIGN KEY (product_id) REFERENCES products(id),
    CONSTRAINT fk_recipes_size    FOREIGN KEY (size_id)    REFERENCES sizes(id),
    UNIQUE KEY uq_recipes_product_size (product_id, size_id)
);


-- ============================================================
-- 21. recipe_items
-- يعتمد على: recipes, material_types
-- مكونات كل وصفة (كحول، زجاجة، تغليف...)
-- 📌 v2.1: إضافة waste_percentage لحساب الهدر
-- ============================================================
CREATE TABLE recipe_items (
    id               BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    recipe_id        BIGINT UNSIGNED NOT NULL,
    material_id      BIGINT UNSIGNED NOT NULL,
    quantity         DECIMAL(10,2)   NOT NULL,
    waste_percentage DECIMAL(5,2)    NOT NULL DEFAULT 0,
    unit             VARCHAR(10)     NOT NULL,
    created_at       TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    updated_at       TIMESTAMP       DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_recipe_items_recipe   FOREIGN KEY (recipe_id)   REFERENCES recipes(id),
    CONSTRAINT fk_recipe_items_material FOREIGN KEY (material_id) REFERENCES material_types(id)
);


-- ============================================================
-- 22. material_usage
-- يعتمد على: invoice_items, material_types
-- 📌 التبسيط: إزالة material_batch_id (لا حاجة لـ FIFO)
-- تسجيل استهلاك المواد مع snapshot التكلفة
-- ============================================================
CREATE TABLE material_usage (
    id                     BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    invoice_item_id        BIGINT UNSIGNED NOT NULL,
    material_id            BIGINT UNSIGNED NOT NULL,
    quantity_used          DECIMAL(10,2)   NOT NULL,
    cost_per_unit_snapshot DECIMAL(10,2)   NOT NULL,
    total_cost             DECIMAL(10,2)   NOT NULL,
    created_at             TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_material_usage_invoice_item FOREIGN KEY (invoice_item_id) REFERENCES invoice_items(id),
    CONSTRAINT fk_material_usage_material     FOREIGN KEY (material_id)     REFERENCES material_types(id),
    INDEX idx_material_usage_invoice_item (invoice_item_id),
    INDEX idx_material_usage_material (material_id)
);


-- ============================================================
-- 23. invoice_costs
-- يعتمد على: invoices
-- التكلفة الإجمالية لكل فاتورة
-- ============================================================
CREATE TABLE invoice_costs (
    id            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    invoice_id    BIGINT UNSIGNED NOT NULL,
    product_cost  DECIMAL(10,2)   NOT NULL,
    material_cost DECIMAL(10,2)   NOT NULL,
    total_cost    DECIMAL(10,2)   NOT NULL,
    created_at    TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_invoice_costs_invoice FOREIGN KEY (invoice_id) REFERENCES invoices(id),
    UNIQUE KEY uq_invoice_costs_invoice (invoice_id)
);


-- ============================================================
-- 24. inventory_movements
-- يعتمد على: products, users
-- سجل موحد لكل حركات المخزون
-- ============================================================
CREATE TABLE inventory_movements (
    id             BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    product_id     BIGINT UNSIGNED NOT NULL,
    movement_type  ENUM('in','out','adjustment') NOT NULL,
    quantity       DECIMAL(10,2)   NOT NULL,
    quantity_before DECIMAL(10,2)  NOT NULL,
    quantity_after DECIMAL(10,2)   NOT NULL,
    reference_type VARCHAR(50)     NULL,
    reference_id   BIGINT UNSIGNED NULL,
    user_id        BIGINT UNSIGNED NOT NULL,
    notes          TEXT            NULL,
    created_at     TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_inventory_movements_product FOREIGN KEY (product_id) REFERENCES products(id),
    CONSTRAINT fk_inventory_movements_user    FOREIGN KEY (user_id)    REFERENCES users(id),
    INDEX idx_inventory_movements_product (product_id),
    INDEX idx_inventory_movements_type    (movement_type),
    INDEX idx_inventory_movements_ref     (reference_type, reference_id),
    INDEX idx_inventory_movements_created (created_at)
);


-- ============================================================
-- 25. returns
-- يعتمد على: invoices, users
-- رأس طلب المرتجع
-- 📌 v2.1: إضافة restock_fee لرسوم إعادة التخزين
-- ============================================================
CREATE TABLE returns (
    id                     BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    invoice_id             BIGINT UNSIGNED NOT NULL,
    user_id                BIGINT UNSIGNED NOT NULL,
    reason                 TEXT            NULL,
    refund_amount          DECIMAL(10,2)   NOT NULL DEFAULT 0,
    restock_fee            DECIMAL(10,2)   NOT NULL DEFAULT 0,
    restock_fee_percentage DECIMAL(5,2)    NULL,
    status                 ENUM('pending','approved','rejected','completed') NOT NULL DEFAULT 'pending',
    created_at             TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    updated_at             TIMESTAMP       DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_returns_invoice FOREIGN KEY (invoice_id) REFERENCES invoices(id),
    CONSTRAINT fk_returns_user    FOREIGN KEY (user_id)    REFERENCES users(id),
    INDEX idx_returns_invoice (invoice_id),
    INDEX idx_returns_status (status)
);


-- ============================================================
-- 26. return_items
-- يعتمد على: returns, products, sizes
-- تفاصيل المنتجات المرتجعة
-- ============================================================
CREATE TABLE return_items (
    id            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    return_id     BIGINT UNSIGNED NOT NULL,
    product_id    BIGINT UNSIGNED NOT NULL,
    size_id       BIGINT UNSIGNED NULL,
    quantity      DECIMAL(10,2)   NOT NULL,
    refund_amount DECIMAL(10,2)   NOT NULL,
    created_at    TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_return_items_return  FOREIGN KEY (return_id)  REFERENCES returns(id) ON DELETE CASCADE,
    CONSTRAINT fk_return_items_product FOREIGN KEY (product_id) REFERENCES products(id),
    CONSTRAINT fk_return_items_size    FOREIGN KEY (size_id)    REFERENCES sizes(id),
    INDEX idx_return_items_return  (return_id),
    INDEX idx_return_items_product (product_id)
);


-- ============================================================
-- 27. discounts
-- لا يعتمد على أي جدول
-- الخصومات والعروض الترويجية
-- ============================================================
CREATE TABLE discounts (
    id           BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name         VARCHAR(255)    NOT NULL,
    type         ENUM('percentage','fixed') NOT NULL,
    value        DECIMAL(10,2)   NOT NULL,
    min_purchase DECIMAL(10,2)   NULL,
    start_date   DATE            NULL,
    end_date     DATE            NULL,
    is_active    BOOLEAN         NOT NULL DEFAULT TRUE,
    created_at   TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    updated_at   TIMESTAMP       DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_discounts_active (is_active),
    INDEX idx_discounts_dates  (start_date, end_date)
);


-- ============================================================
-- 28. discount_products
-- يعتمد على: discounts, products
-- ربط الخصومات بالمنتجات المحددة
-- ============================================================
CREATE TABLE discount_products (
    id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    discount_id BIGINT UNSIGNED NOT NULL,
    product_id  BIGINT UNSIGNED NOT NULL,
    created_at  TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_discount_products_discount FOREIGN KEY (discount_id) REFERENCES discounts(id),
    CONSTRAINT fk_discount_products_product  FOREIGN KEY (product_id)  REFERENCES products(id),
    UNIQUE KEY uq_discount_products (discount_id, product_id),
    INDEX idx_discount_products_discount (discount_id),
    INDEX idx_discount_products_product  (product_id)
);


-- ============================================================
-- 29. return_cost_reversals
-- يعتمد على: returns, invoice_costs
-- عكس التكاليف عند المرتجع
-- 📌 v2.1: جدول جديد لدقة حساب الأرباح
-- ============================================================
CREATE TABLE return_cost_reversals (
    id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    return_id       BIGINT UNSIGNED NOT NULL,
    invoice_cost_id BIGINT UNSIGNED NOT NULL,
    product_cost    DECIMAL(10,2)   NOT NULL DEFAULT 0,
    material_cost   DECIMAL(10,2)   NOT NULL DEFAULT 0,
    total_cost      DECIMAL(10,2)   NOT NULL DEFAULT 0,
    created_at      TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_return_cost_reversals_return       FOREIGN KEY (return_id)       REFERENCES returns(id),
    CONSTRAINT fk_return_cost_reversals_invoice_cost FOREIGN KEY (invoice_cost_id) REFERENCES invoice_costs(id),
    UNIQUE KEY uq_return_cost_reversals_return (return_id),
    INDEX idx_return_cost_reversals_invoice_cost (invoice_cost_id)
);


================================================================================
                    📊 ملخص التحسينات
================================================================================

✅ الجداول المحذوفة (16 جدول):
   ❌ batch_inventory          → دُمج في purchases
   ❌ material_batches          → دُمج في material_purchases
   ❌ material_inventory        → دُمج في material_purchases
   ❌ production_logs           → غير ضروري (material_usage يكفي)
   ❌ inventory_losses          → يُسجل في inventory_movements
   ❌ transactions              → تعقيد زائد لنظام صغير
   ❌ inventory_reservations    → تعقيد زائد لنظام صغير
   ❌ audit_logs                → يمكن إضافته لاحقاً
   ❌ accounting_ledger         → invoice_costs يكفي
   ❌ role_permissions          → يُدار في الكود
   ❌ system_health_logs        → يُدار في الكود
   ❌ notifications             → ميزة متقدمة
   ❌ loyalty_programs          → ميزة متقدمة
   ❌ customer_points           → ميزة متقدمة
   ❌ expenses                  → يمكن إضافته لاحقاً
   ❌ reports_cache             → يمكن إضافته لاحقاً
   ❌ activity_logs             → يمكن إضافته لاحقاً

✅ الجداول المبسطة (3 جداول):
   📌 material_types: إضافة avg_cost + total_quantity (Weighted Average)
   📌 purchases: دمج purchase_batches + batch_inventory
   📌 material_purchases: دمج material_batches + material_inventory

✅ النتيجة النهائية:
   📊 من 44 جدول → 29 جدول (تقليل 34%)
   ⚡ نفس الوظائف الأساسية
   ✅ نفس الدقة في حساب التكاليف
   🚀 أسهل في التطوير والصيانة
   🆕 دعم الدفع الجزئي والتكاليف الدقيقة


================================================================================
                    🎯 آلية حساب التكلفة المبسطة
================================================================================

عند شراء مواد:
   material_purchases → تحديث material_types.avg_cost تلقائياً
   avg_cost = (old_total_cost + new_total_cost) / (old_quantity + new_quantity)

عند البيع:
   1. قراءة الوصفة (recipes + recipe_items)
   2. حساب التكلفة من material_types.avg_cost
   3. تسجيل في material_usage مع snapshot
   4. تسجيل في invoice_costs

الربح = invoices.total - invoice_costs.total_cost


================================================================================
                                    انتهى
================================================================================
