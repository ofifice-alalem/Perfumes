================================================================================
                    جداول قاعدة البيانات — بالترتيب الصحيح للإنشاء
================================================================================

📌 القاعدة: كل جدول يحتوي FK يأتي بعد الجدول الذي يحتوي PK المرتبط به.

================================================================================


-- ============================================================
-- 1. units
-- لا يعتمد على أي جدول
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
-- ============================================================
CREATE TABLE products (
    id             BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name           VARCHAR(255) NOT NULL,
    category_id    BIGINT UNSIGNED NOT NULL,
    price_tier_id  BIGINT UNSIGNED NOT NULL,
    selling_type   ENUM('DECANT_ONLY','FULL_ONLY','BOTH','UNIT_BASED') NOT NULL,
    created_at     TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    updated_at     TIMESTAMP    DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_products_category  FOREIGN KEY (category_id)   REFERENCES categories(id),
    CONSTRAINT fk_products_tier      FOREIGN KEY (price_tier_id) REFERENCES price_tiers(id),
    INDEX idx_products_selling_type (selling_type)
);


-- ============================================================
-- 10. inventory
-- يعتمد على: products, units
-- ============================================================
CREATE TABLE inventory (
    id         BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    product_id BIGINT UNSIGNED NOT NULL,
    quantity   DECIMAL(10,2)   NOT NULL DEFAULT 0,
    unit_id    BIGINT UNSIGNED NOT NULL,
    created_at TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP       DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_inventory_product FOREIGN KEY (product_id) REFERENCES products(id),
    CONSTRAINT fk_inventory_unit    FOREIGN KEY (unit_id)    REFERENCES units(id),
    UNIQUE KEY uq_inventory_product (product_id)
);


-- ============================================================
-- 11. product_images
-- يعتمد على: products
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
-- ============================================================
CREATE TABLE material_types (
    id            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name          VARCHAR(100)    NOT NULL,
    unit          VARCHAR(10)     NOT NULL,
    cost_per_unit DECIMAL(10,2)   NOT NULL,
    created_at    TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP       DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);


-- ============================================================
-- 15. invoices
-- يعتمد على: customers, users
-- ============================================================
CREATE TABLE invoices (
    id             BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    invoice_number VARCHAR(50)     NOT NULL,
    customer_id    BIGINT UNSIGNED NULL,
    user_id        BIGINT UNSIGNED NOT NULL,
    subtotal       DECIMAL(10,2)   NOT NULL DEFAULT 0,
    discount       DECIMAL(10,2)   NOT NULL DEFAULT 0,
    total          DECIMAL(10,2)   NOT NULL DEFAULT 0,
    status         ENUM('completed','cancelled','refunded') NOT NULL DEFAULT 'completed',
    notes          TEXT            NULL,
    created_at     TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    updated_at     TIMESTAMP       DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_invoices_customer FOREIGN KEY (customer_id) REFERENCES customers(id),
    CONSTRAINT fk_invoices_user     FOREIGN KEY (user_id)     REFERENCES users(id),
    UNIQUE KEY uq_invoices_number (invoice_number),
    INDEX idx_invoices_customer (customer_id),
    INDEX idx_invoices_status (status),
    INDEX idx_invoices_created_at (created_at)
);


-- ============================================================
-- 16. sales
-- يعتمد على: users, customers, invoices, products, sizes
-- ============================================================
CREATE TABLE sales (
    id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id     BIGINT UNSIGNED NOT NULL,
    customer_id BIGINT UNSIGNED NULL,
    invoice_id  BIGINT UNSIGNED NULL,
    product_id  BIGINT UNSIGNED NOT NULL,
    sale_type   ENUM('decant','full','unit_based') NOT NULL,
    size_id     BIGINT UNSIGNED NULL,
    quantity    DECIMAL(10,2)   NOT NULL,
    price       DECIMAL(10,2)   NOT NULL,
    created_at  TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_sales_user     FOREIGN KEY (user_id)     REFERENCES users(id),
    CONSTRAINT fk_sales_customer FOREIGN KEY (customer_id) REFERENCES customers(id),
    CONSTRAINT fk_sales_invoice  FOREIGN KEY (invoice_id)  REFERENCES invoices(id),
    CONSTRAINT fk_sales_product  FOREIGN KEY (product_id)  REFERENCES products(id),
    CONSTRAINT fk_sales_size     FOREIGN KEY (size_id)     REFERENCES sizes(id),
    INDEX idx_sales_product    (product_id),
    INDEX idx_sales_created_at (created_at)
);


-- ============================================================
-- 17. invoice_items
-- يعتمد على: invoices, products, sizes
-- ============================================================
CREATE TABLE invoice_items (
    id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    invoice_id  BIGINT UNSIGNED NOT NULL,
    product_id  BIGINT UNSIGNED NOT NULL,
    sale_type   ENUM('decant','full','unit_based') NOT NULL,
    size_id     BIGINT UNSIGNED NULL,
    quantity    DECIMAL(10,2)   NOT NULL,
    unit_price  DECIMAL(10,2)   NOT NULL,
    discount    DECIMAL(10,2)   NOT NULL DEFAULT 0,
    total_price DECIMAL(10,2)   NOT NULL,
    created_at  TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_invoice_items_invoice FOREIGN KEY (invoice_id) REFERENCES invoices(id) ON DELETE CASCADE,
    CONSTRAINT fk_invoice_items_product FOREIGN KEY (product_id) REFERENCES products(id),
    CONSTRAINT fk_invoice_items_size    FOREIGN KEY (size_id)    REFERENCES sizes(id),
    INDEX idx_invoice_items_invoice (invoice_id),
    INDEX idx_invoice_items_product (product_id)
);


-- ============================================================
-- 18. payments
-- يعتمد على: sales, invoices, payment_methods
-- ============================================================
CREATE TABLE payments (
    id                BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    sale_id           BIGINT UNSIGNED NULL,
    invoice_id        BIGINT UNSIGNED NULL,
    payment_method_id BIGINT UNSIGNED NOT NULL,
    amount            DECIMAL(10,2)   NOT NULL,
    reference         VARCHAR(100)    NULL,
    created_at        TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_payments_sale   FOREIGN KEY (sale_id)           REFERENCES sales(id),
    CONSTRAINT fk_payments_invoice FOREIGN KEY (invoice_id)       REFERENCES invoices(id),
    CONSTRAINT fk_payments_method FOREIGN KEY (payment_method_id) REFERENCES payment_methods(id),
    INDEX idx_payments_sale    (sale_id),
    INDEX idx_payments_invoice (invoice_id),
    INDEX idx_payments_created_at (created_at)
);


-- ============================================================
-- 19. purchase_batches
-- يعتمد على: products, suppliers
-- ============================================================
CREATE TABLE purchase_batches (
    id            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    product_id    BIGINT UNSIGNED NOT NULL,
    supplier_id   BIGINT UNSIGNED NULL,
    quantity      DECIMAL(10,2)   NOT NULL,
    unit_cost     DECIMAL(10,2)   NOT NULL,
    total_cost    DECIMAL(10,2)   NOT NULL,
    purchase_date DATE            NOT NULL,
    created_at    TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_batches_product  FOREIGN KEY (product_id)  REFERENCES products(id),
    CONSTRAINT fk_batches_supplier FOREIGN KEY (supplier_id) REFERENCES suppliers(id),
    INDEX idx_batches_product       (product_id),
    INDEX idx_batches_purchase_date (purchase_date)
);


-- ============================================================
-- 20. batch_inventory
-- يعتمد على: purchase_batches, products
-- ============================================================
CREATE TABLE batch_inventory (
    id                 BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    batch_id           BIGINT UNSIGNED NOT NULL,
    product_id         BIGINT UNSIGNED NOT NULL,
    remaining_quantity DECIMAL(10,2)   NOT NULL,
    created_at         TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    updated_at         TIMESTAMP       DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_batch_inv_batch   FOREIGN KEY (batch_id)   REFERENCES purchase_batches(id),
    CONSTRAINT fk_batch_inv_product FOREIGN KEY (product_id) REFERENCES products(id),
    INDEX idx_batch_inv_batch   (batch_id),
    INDEX idx_batch_inv_product (product_id)
);


-- ============================================================
-- 21. material_batches
-- يعتمد على: material_types, suppliers
-- ============================================================
CREATE TABLE material_batches (
    id            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    material_id   BIGINT UNSIGNED NOT NULL,
    supplier_id   BIGINT UNSIGNED NULL,
    quantity      DECIMAL(10,2)   NOT NULL,
    unit_cost     DECIMAL(10,2)   NOT NULL,
    total_cost    DECIMAL(10,2)   NOT NULL,
    purchase_date DATE            NOT NULL,
    created_at    TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_material_batches_material FOREIGN KEY (material_id) REFERENCES material_types(id),
    CONSTRAINT fk_material_batches_supplier FOREIGN KEY (supplier_id) REFERENCES suppliers(id)
);


-- ============================================================
-- 22. material_inventory
-- يعتمد على: material_batches, material_types
-- ============================================================
CREATE TABLE material_inventory (
    id                 BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    material_batch_id  BIGINT UNSIGNED NOT NULL,
    material_id        BIGINT UNSIGNED NOT NULL,
    remaining_quantity DECIMAL(10,2)   NOT NULL,
    created_at         TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    updated_at         TIMESTAMP       DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_material_inv_batch    FOREIGN KEY (material_batch_id) REFERENCES material_batches(id),
    CONSTRAINT fk_material_inv_material FOREIGN KEY (material_id)       REFERENCES material_types(id)
);


-- ============================================================
-- 23. sale_batch_usage
-- يعتمد على: sales, purchase_batches
-- ============================================================
CREATE TABLE sale_batch_usage (
    id               BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    sale_id          BIGINT UNSIGNED NOT NULL,
    batch_id         BIGINT UNSIGNED NOT NULL,
    quantity_used    DECIMAL(10,2)   NOT NULL,
    unit_cost        DECIMAL(10,2)   NOT NULL,
    created_at       TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_sale_batch_sale  FOREIGN KEY (sale_id)  REFERENCES sales(id),
    CONSTRAINT fk_sale_batch_batch FOREIGN KEY (batch_id) REFERENCES purchase_batches(id),
    INDEX idx_sale_batch_sale  (sale_id),
    INDEX idx_sale_batch_batch (batch_id)
);


-- ============================================================
-- 24. material_usage
-- يعتمد على: sales, material_types, material_batches
-- ============================================================
CREATE TABLE material_usage (
    id                     BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    sale_id                BIGINT UNSIGNED NOT NULL,
    material_id            BIGINT UNSIGNED NOT NULL,
    material_batch_id      BIGINT UNSIGNED NULL,
    quantity_used          DECIMAL(10,2)   NOT NULL,
    cost_per_unit_snapshot DECIMAL(10,2)   NOT NULL,
    total_cost             DECIMAL(10,2)   NOT NULL,
    created_at             TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_material_usage_sale  FOREIGN KEY (sale_id)            REFERENCES sales(id),
    CONSTRAINT fk_material_usage_material FOREIGN KEY (material_id)     REFERENCES material_types(id),
    CONSTRAINT fk_material_usage_batch FOREIGN KEY (material_batch_id)  REFERENCES material_batches(id)
);


-- ============================================================
-- 25. sale_costs
-- يعتمد على: sales
-- ============================================================
CREATE TABLE sale_costs (
    id            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    sale_id       BIGINT UNSIGNED NOT NULL,
    product_cost  DECIMAL(10,2)   NOT NULL,
    material_cost DECIMAL(10,2)   NOT NULL,
    total_cost    DECIMAL(10,2)   NOT NULL,
    created_at    TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_sale_costs_sale FOREIGN KEY (sale_id) REFERENCES sales(id),
    UNIQUE KEY uq_sale_costs_sale (sale_id)
);


-- ============================================================
-- 26. inventory_losses
-- يعتمد على: products
-- ============================================================
CREATE TABLE inventory_losses (
    id         BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    product_id BIGINT UNSIGNED NOT NULL,
    quantity   DECIMAL(10,2)   NOT NULL,
    reason     TEXT            NULL,
    loss_cost  DECIMAL(10,2)   NULL,
    created_at TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_inventory_losses_product FOREIGN KEY (product_id) REFERENCES products(id)
);


-- ============================================================
-- 27. recipes
-- يعتمد على: products, sizes
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
-- 28. recipe_items
-- يعتمد على: recipes, material_types
-- ============================================================
CREATE TABLE recipe_items (
    id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    recipe_id   BIGINT UNSIGNED NOT NULL,
    material_id BIGINT UNSIGNED NOT NULL,
    quantity    DECIMAL(10,2)   NOT NULL,
    unit        VARCHAR(10)     NOT NULL,
    created_at  TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP       DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_recipe_items_recipe   FOREIGN KEY (recipe_id)   REFERENCES recipes(id),
    CONSTRAINT fk_recipe_items_material FOREIGN KEY (material_id) REFERENCES material_types(id)
);


-- ============================================================
-- 29. production_logs
-- يعتمد على: sales, recipes, products, sizes
-- ============================================================
CREATE TABLE production_logs (
    id                BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    sale_id           BIGINT UNSIGNED NOT NULL,
    recipe_id         BIGINT UNSIGNED NOT NULL,
    product_id        BIGINT UNSIGNED NOT NULL,
    size_id           BIGINT UNSIGNED NULL,
    quantity_produced DECIMAL(10,2)   NOT NULL,
    created_at        TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_production_logs_sale    FOREIGN KEY (sale_id)    REFERENCES sales(id),
    CONSTRAINT fk_production_logs_recipe  FOREIGN KEY (recipe_id)  REFERENCES recipes(id),
    CONSTRAINT fk_production_logs_product FOREIGN KEY (product_id) REFERENCES products(id),
    CONSTRAINT fk_production_logs_size    FOREIGN KEY (size_id)    REFERENCES sizes(id)
);


-- ============================================================
-- 30. expenses
-- يعتمد على: users
-- ============================================================
CREATE TABLE expenses (
    id           BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id      BIGINT UNSIGNED NOT NULL,
    category     VARCHAR(100)    NOT NULL,
    amount       DECIMAL(10,2)   NOT NULL,
    description  TEXT            NULL,
    expense_date DATE            NOT NULL,
    created_at   TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_expenses_user FOREIGN KEY (user_id) REFERENCES users(id),
    INDEX idx_expenses_category (category),
    INDEX idx_expenses_date     (expense_date)
);


-- ============================================================
-- 31. transactions
-- لا يعتمد على أي جدول
-- ============================================================
CREATE TABLE transactions (
    id           BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    type         VARCHAR(50)     NOT NULL,
    status       ENUM('pending','committed','failed') NOT NULL DEFAULT 'pending',
    started_at   TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP       NULL
);


-- ============================================================
-- 32. inventory_reservations
-- يعتمد على: transactions, products
-- ============================================================
CREATE TABLE inventory_reservations (
    id             BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    transaction_id BIGINT UNSIGNED NOT NULL,
    product_id     BIGINT UNSIGNED NOT NULL,
    quantity       DECIMAL(10,2)   NOT NULL,
    status         ENUM('reserved','released') NOT NULL DEFAULT 'reserved',
    created_at     TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    updated_at     TIMESTAMP       DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_inventory_reservations_transaction FOREIGN KEY (transaction_id) REFERENCES transactions(id),
    CONSTRAINT fk_inventory_reservations_product     FOREIGN KEY (product_id)     REFERENCES products(id)
);


-- ============================================================
-- 33. audit_logs
-- يعتمد على: users
-- ============================================================
CREATE TABLE audit_logs (
    id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id     BIGINT UNSIGNED NOT NULL,
    action      VARCHAR(50)     NOT NULL,
    entity_type VARCHAR(50)     NOT NULL,
    entity_id   BIGINT UNSIGNED NOT NULL,
    changes     JSON            NULL,
    created_at  TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_audit_logs_user FOREIGN KEY (user_id) REFERENCES users(id)
);


-- ============================================================
-- 34. accounting_ledger
-- يعتمد على: sales
-- ============================================================
CREATE TABLE accounting_ledger (
    id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    sale_id     BIGINT UNSIGNED NOT NULL,
    type        ENUM('revenue','cost','profit') NOT NULL,
    amount      DECIMAL(10,2)   NOT NULL,
    description TEXT            NULL,
    created_at  TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_accounting_ledger_sale FOREIGN KEY (sale_id) REFERENCES sales(id)
);


-- ============================================================
-- 35. role_permissions
-- لا يعتمد على أي جدول
-- ============================================================
CREATE TABLE role_permissions (
    id         BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    role       VARCHAR(50)  NOT NULL,
    permission VARCHAR(100) NOT NULL,
    created_at TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_role_permissions (role, permission)
);


-- ============================================================
-- 36. system_health_logs
-- لا يعتمد على أي جدول
-- ============================================================
CREATE TABLE system_health_logs (
    id         BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    level      ENUM('info','warning','error') NOT NULL,
    message    TEXT        NOT NULL,
    context    JSON        NULL,
    created_at TIMESTAMP   DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================
-- 37. inventory_movements
-- يعتمد على: products, users
-- ============================================================
CREATE TABLE inventory_movements (
    id             BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    product_id     BIGINT UNSIGNED NOT NULL,
    movement_type  ENUM('in','out','adjustment','transfer') NOT NULL,
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
-- 38. returns
-- يعتمد على: sales, users
-- ============================================================
CREATE TABLE returns (
    id            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    sale_id       BIGINT UNSIGNED NOT NULL,
    user_id       BIGINT UNSIGNED NOT NULL,
    reason        TEXT            NULL,
    refund_amount DECIMAL(10,2)   NOT NULL DEFAULT 0,
    status        ENUM('pending','approved','rejected','completed') NOT NULL DEFAULT 'pending',
    created_at    TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP       DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_returns_sale FOREIGN KEY (sale_id) REFERENCES sales(id),
    CONSTRAINT fk_returns_user FOREIGN KEY (user_id) REFERENCES users(id)
);


-- ============================================================
-- 39. return_items
-- يعتمد على: returns, products, sizes
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
-- 40. discounts
-- لا يعتمد على أي جدول
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
-- 41. discount_products
-- يعتمد على: discounts, products
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
-- 42. notifications
-- يعتمد على: users
-- ============================================================
CREATE TABLE notifications (
    id         BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id    BIGINT UNSIGNED NULL,
    type       VARCHAR(50)     NOT NULL,
    title      VARCHAR(255)    NOT NULL,
    message    TEXT            NOT NULL,
    is_read    BOOLEAN         NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_notifications_user FOREIGN KEY (user_id) REFERENCES users(id),
    INDEX idx_notifications_user    (user_id),
    INDEX idx_notifications_is_read (is_read),
    INDEX idx_notifications_created (created_at)
);


-- ============================================================
-- 43. loyalty_programs
-- لا يعتمد على أي جدول
-- ============================================================
CREATE TABLE loyalty_programs (
    id                BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name              VARCHAR(255)    NOT NULL,
    points_per_unit   DECIMAL(10,2)   NOT NULL,
    min_points_redeem INT             NOT NULL,
    is_active         BOOLEAN         NOT NULL DEFAULT TRUE,
    created_at        TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    updated_at        TIMESTAMP       DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_loyalty_programs_active (is_active)
);


-- ============================================================
-- 44. customer_points
-- يعتمد على: customers
-- ============================================================
CREATE TABLE customer_points (
    id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    customer_id BIGINT UNSIGNED NOT NULL,
    points      INT             NOT NULL DEFAULT 0,
    created_at  TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP       DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_customer_points_customer FOREIGN KEY (customer_id) REFERENCES customers(id),
    UNIQUE KEY uq_customer_points_customer (customer_id)
);


-- ============================================================
-- 45. reports_cache
-- لا يعتمد على أي جدول
-- ============================================================
CREATE TABLE reports_cache (
    id           BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    report_type  VARCHAR(50)  NOT NULL,
    period       VARCHAR(50)  NOT NULL,
    data         JSON         NOT NULL,
    generated_at TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_reports_cache_type   (report_type, period),
    INDEX idx_reports_cache_generated (generated_at)
);


-- ============================================================
-- 46. activity_logs
-- يعتمد على: users
-- ============================================================
CREATE TABLE activity_logs (
    id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id     BIGINT UNSIGNED NULL,
    action      VARCHAR(100)    NOT NULL,
    entity_type VARCHAR(50)     NULL,
    entity_id   BIGINT UNSIGNED NULL,
    details     TEXT            NULL,
    created_at  TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_activity_logs_user FOREIGN KEY (user_id) REFERENCES users(id),
    INDEX idx_activity_logs_user       (user_id),
    INDEX idx_activity_logs_entity     (entity_type, entity_id),
    INDEX idx_activity_logs_created_at (created_at)
);


================================================================================
                                    انتهى
================================================================================X idx_batch_inv_product    (product_id),
