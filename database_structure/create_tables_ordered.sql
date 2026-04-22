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
-- 5. users
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
-- 6. products
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
-- 7. inventory
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
-- 8. tier_prices
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
-- 9. unit_based_prices
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
-- 10. sales
-- يعتمد على: users, products, sizes
-- ============================================================
CREATE TABLE sales (
    id         BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id    BIGINT UNSIGNED NOT NULL,
    product_id BIGINT UNSIGNED NOT NULL,
    sale_type  ENUM('decant','full','unit_based') NOT NULL,
    size_id    BIGINT UNSIGNED NULL,
    quantity   DECIMAL(10,2)   NOT NULL,
    price      DECIMAL(10,2)   NOT NULL,
    created_at TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_sales_user    FOREIGN KEY (user_id)    REFERENCES users(id),
    CONSTRAINT fk_sales_product FOREIGN KEY (product_id) REFERENCES products(id),
    CONSTRAINT fk_sales_size    FOREIGN KEY (size_id)    REFERENCES sizes(id),
    INDEX idx_sales_product    (product_id),
    INDEX idx_sales_created_at (created_at)
);


-- ============================================================
-- 11. purchase_batches
-- يعتمد على: products
-- ============================================================
CREATE TABLE purchase_batches (
    id            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    product_id    BIGINT UNSIGNED NOT NULL,
    quantity      DECIMAL(10,2)   NOT NULL,
    unit_cost     DECIMAL(10,2)   NOT NULL,
    total_cost    DECIMAL(10,2)   NOT NULL,
    supplier_name VARCHAR(255)    NULL,
    purchase_date DATE            NOT NULL,
    created_at    TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_batches_product FOREIGN KEY (product_id) REFERENCES products(id),
    INDEX idx_batches_product       (product_id),
    INDEX idx_batches_purchase_date (purchase_date)
);


-- ============================================================
-- 12. batch_inventory
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
    INDEX idx_batch_inv_product    (product_id),
    INDEX idx_batch_inv_created_at (created_at)   -- للـ FIFO
);


-- ============================================================
-- 13. material_types
-- لا يعتمد على أي جدول
-- ============================================================
CREATE TABLE material_types (
    id            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name          VARCHAR(100)  NOT NULL,
    unit          VARCHAR(10)   NOT NULL,
    cost_per_unit DECIMAL(10,2) NOT NULL,
    created_at    TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);


-- ============================================================
-- 14. material_usage
-- يعتمد على: sales, material_types
-- ============================================================
CREATE TABLE material_usage (
    id            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    sale_id       BIGINT UNSIGNED NOT NULL,
    material_id   BIGINT UNSIGNED NOT NULL,
    quantity_used DECIMAL(10,2)   NOT NULL,
    created_at    TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_mat_usage_sale     FOREIGN KEY (sale_id)     REFERENCES sales(id),
    CONSTRAINT fk_mat_usage_material FOREIGN KEY (material_id) REFERENCES material_types(id),
    INDEX idx_mat_usage_sale     (sale_id),
    INDEX idx_mat_usage_material (material_id)
);


-- ============================================================
-- 15. sale_costs
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
-- 16. inventory_losses
-- يعتمد على: products
-- ============================================================
CREATE TABLE inventory_losses (
    id         BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    product_id BIGINT UNSIGNED NOT NULL,
    quantity   DECIMAL(10,2)   NOT NULL,
    reason     TEXT            NULL,
    loss_cost  DECIMAL(10,2)   NULL,
    created_at TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_inv_losses_product FOREIGN KEY (product_id) REFERENCES products(id),
    INDEX idx_inv_losses_product    (product_id),
    INDEX idx_inv_losses_created_at (created_at)
);


-- ============================================================
-- 17. recipes
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
    UNIQUE KEY uq_recipes (product_id, size_id),
    INDEX idx_recipes_active (is_active)
);


-- ============================================================
-- 18. recipe_items
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
    CONSTRAINT fk_recipe_items_material FOREIGN KEY (material_id) REFERENCES material_types(id),
    INDEX idx_recipe_items_recipe (recipe_id)
);


-- ============================================================
-- 19. production_logs
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
    CONSTRAINT fk_prod_logs_sale    FOREIGN KEY (sale_id)    REFERENCES sales(id),
    CONSTRAINT fk_prod_logs_recipe  FOREIGN KEY (recipe_id)  REFERENCES recipes(id),
    CONSTRAINT fk_prod_logs_product FOREIGN KEY (product_id) REFERENCES products(id),
    CONSTRAINT fk_prod_logs_size    FOREIGN KEY (size_id)    REFERENCES sizes(id),
    INDEX idx_prod_logs_sale       (sale_id),
    INDEX idx_prod_logs_created_at (created_at)
);


-- ============================================================
-- 20. transactions
-- لا يعتمد على أي جدول
-- ============================================================
CREATE TABLE transactions (
    id           BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    type         VARCHAR(50) NOT NULL,
    status       ENUM('pending','committed','failed') NOT NULL DEFAULT 'pending',
    started_at   TIMESTAMP   DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP   NULL,
    INDEX idx_transactions_status     (status),
    INDEX idx_transactions_started_at (started_at)
);


-- ============================================================
-- 21. inventory_reservations
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
    CONSTRAINT fk_inv_res_transaction FOREIGN KEY (transaction_id) REFERENCES transactions(id),
    CONSTRAINT fk_inv_res_product     FOREIGN KEY (product_id)     REFERENCES products(id),
    INDEX idx_inv_res_product (product_id),
    INDEX idx_inv_res_status  (status)
);


-- ============================================================
-- 22. audit_logs
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
    CONSTRAINT fk_audit_logs_user FOREIGN KEY (user_id) REFERENCES users(id),
    INDEX idx_audit_logs_user          (user_id),
    INDEX idx_audit_logs_entity        (entity_type, entity_id),
    INDEX idx_audit_logs_created_at    (created_at)
);


-- ============================================================
-- 23. accounting_ledger
-- يعتمد على: sales
-- ============================================================
CREATE TABLE accounting_ledger (
    id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    sale_id     BIGINT UNSIGNED NOT NULL,
    type        ENUM('revenue','cost','profit') NOT NULL,
    amount      DECIMAL(10,2)   NOT NULL,
    description TEXT            NULL,
    created_at  TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_ledger_sale FOREIGN KEY (sale_id) REFERENCES sales(id),
    INDEX idx_ledger_sale       (sale_id),
    INDEX idx_ledger_type       (type),
    INDEX idx_ledger_created_at (created_at)
);


-- ============================================================
-- 24. role_permissions
-- لا يعتمد على أي جدول
-- ============================================================
CREATE TABLE role_permissions (
    id         BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    role       VARCHAR(50)  NOT NULL,
    permission VARCHAR(100) NOT NULL,
    created_at TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_role_permissions (role, permission),
    INDEX idx_role_permissions_role (role)
);


-- ============================================================
-- 25. system_health_logs
-- لا يعتمد على أي جدول
-- ============================================================
CREATE TABLE system_health_logs (
    id         BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    level      ENUM('info','warning','error') NOT NULL,
    message    TEXT        NOT NULL,
    context    JSON        NULL,
    created_at TIMESTAMP   DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_health_logs_level      (level),
    INDEX idx_health_logs_created_at (created_at)
);


================================================================================
                        ترتيب الإنشاء (ملخص)
================================================================================

المستوى 1 — لا تعتمد على شيء:
   1.  units
   2.  price_tiers
   5.  users
   13. material_types
   20. transactions
   24. role_permissions
   25. system_health_logs

المستوى 2 — تعتمد على المستوى 1:
   3.  categories        (← units)
   4.  sizes             (← units)

المستوى 3 — تعتمد على المستوى 2:
   6.  products          (← categories, price_tiers)

المستوى 4 — تعتمد على المستوى 3:
   7.  inventory         (← products, units)
   8.  tier_prices       (← price_tiers, sizes)
   9.  unit_based_prices (← products, price_tiers)
   11. purchase_batches  (← products)
   17. recipes           (← products, sizes)

المستوى 5 — تعتمد على المستوى 4:
   10. sales             (← users, products, sizes)
   12. batch_inventory   (← purchase_batches, products)
   18. recipe_items      (← recipes, material_types)
   21. inventory_reservations (← transactions, products)

المستوى 6 — تعتمد على المستوى 5:
   14. material_usage    (← sales, material_types)
   15. sale_costs        (← sales)
   16. inventory_losses  (← products)
   19. production_logs   (← sales, recipes, products, sizes)
   22. audit_logs        (← users)
   23. accounting_ledger (← sales)

================================================================================
