# 🎯 Perfumes POS System - Complete Skills Package

## 📋 Table of Contents
1. [Laravel Best Practices](#1-laravel-best-practices)
2. [MySQL Database Design](#2-mysql-database-design)
3. [POS System Architecture](#3-pos-system-architecture)
4. [Security Best Practices](#4-security-best-practices)
5. [Performance Optimization](#5-performance-optimization)
6. [Business Logic (POS Specific)](#6-business-logic-pos-specific)
7. [Code Quality Standards](#7-code-quality-standards)
8. [API Design Principles](#8-api-design-principles)
9. [Master Skill Summary](#9-master-skill-summary)

---

## 1. Laravel Best Practices

### 🏗️ Project Structure

```
app/
├── Http/
│   ├── Controllers/        # Thin controllers (handle HTTP only)
│   ├── Requests/          # Form validation
│   ├── Resources/         # API response formatting
│   └── Middleware/        # Request filtering
├── Services/              # Business logic layer
├── Repositories/          # Data access layer
├── Models/                # Eloquent models
├── Policies/              # Authorization logic
├── Events/                # Event classes
├── Listeners/             # Event handlers
└── Exceptions/            # Custom exceptions
```

### 📦 Design Patterns

#### Repository Pattern
```php
// Interface
interface InvoiceRepositoryInterface
{
    public function create(array $data): Invoice;
    public function findById(int $id): ?Invoice;
    public function update(int $id, array $data): bool;
}

// Implementation
class InvoiceRepository implements InvoiceRepositoryInterface
{
    public function create(array $data): Invoice
    {
        return Invoice::create($data);
    }
    
    public function findById(int $id): ?Invoice
    {
        return Invoice::with(['items', 'customer'])->find($id);
    }
}
```

#### Service Layer Pattern
```php
class InvoiceService
{
    public function __construct(
        private InvoiceRepositoryInterface $invoiceRepo,
        private InventoryService $inventoryService,
        private CostCalculationService $costService
    ) {}
    
    public function createInvoice(array $data): Invoice
    {
        return DB::transaction(function () use ($data) {
            // 1. Create invoice
            $invoice = $this->invoiceRepo->create($data);
            
            // 2. Add items and update inventory
            foreach ($data['items'] as $item) {
                $this->addItemToInvoice($invoice, $item);
            }
            
            // 3. Calculate costs
            $this->costService->calculateInvoiceCost($invoice);
            
            return $invoice->fresh();
        });
    }
}
```

### ✅ Validation Rules

#### Form Request Example
```php
class StoreInvoiceRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()->can('create', Invoice::class);
    }
    
    public function rules(): array
    {
        return [
            'customer_id' => 'nullable|exists:customers,id',
            'items' => 'required|array|min:1',
            'items.*.product_id' => 'required|exists:products,id',
            'items.*.quantity' => 'required|numeric|min:0.01',
            'items.*.size_id' => 'nullable|exists:sizes,id',
            'payment_method_id' => 'required|exists:payment_methods,id',
        ];
    }
    
    public function messages(): array
    {
        return [
            'items.required' => 'Invoice must have at least one item',
            'items.*.product_id.exists' => 'Invalid product selected',
        ];
    }
}
```

### 🔐 Authorization with Policies

```php
class InvoicePolicy
{
    public function view(User $user, Invoice $invoice): bool
    {
        return $user->isAdmin() || $user->id === $invoice->user_id;
    }
    
    public function create(User $user): bool
    {
        return $user->hasRole(['admin', 'seller']);
    }
    
    public function cancel(User $user, Invoice $invoice): bool
    {
        return $user->isAdmin() && $invoice->status === 'completed';
    }
}
```

### 📊 Eloquent Best Practices

#### Model Definition
```php
class Invoice extends Model
{
    use HasFactory, SoftDeletes;
    
    protected $fillable = [
        'invoice_number',
        'customer_id',
        'user_id',
        'subtotal',
        'discount',
        'total',
        'status',
    ];
    
    protected $casts = [
        'subtotal' => 'decimal:2',
        'discount' => 'decimal:2',
        'total' => 'decimal:2',
        'created_at' => 'datetime',
    ];
    
    // Relationships
    public function customer(): BelongsTo
    {
        return $this->belongsTo(Customer::class);
    }
    
    public function items(): HasMany
    {
        return $this->hasMany(InvoiceItem::class);
    }
    
    public function payments(): HasMany
    {
        return $this->hasMany(Payment::class);
    }
    
    // Scopes
    public function scopeCompleted($query)
    {
        return $query->where('status', 'completed');
    }
    
    // Accessors
    public function getNetProfitAttribute(): float
    {
        return $this->total - ($this->invoiceCost->total_cost ?? 0);
    }
}
```

### 🎯 Code Standards

#### PSR-12 Compliance
```php
<?php

declare(strict_types=1);

namespace App\Services;

use App\Models\Invoice;
use App\Repositories\InvoiceRepositoryInterface;
use Illuminate\Support\Facades\DB;

class InvoiceService
{
    public function __construct(
        private InvoiceRepositoryInterface $invoiceRepository
    ) {
    }

    public function createInvoice(array $data): Invoice
    {
        // Implementation
    }
}
```

#### Type Hints & Return Types
```php
// ✅ Good
public function calculateTotal(Invoice $invoice): float
{
    return $invoice->items->sum('total_price');
}

// ❌ Bad
public function calculateTotal($invoice)
{
    return $invoice->items->sum('total_price');
}
```

### 🧪 Testing Standards

```php
class InvoiceServiceTest extends TestCase
{
    use RefreshDatabase;
    
    public function test_can_create_invoice_with_items(): void
    {
        // Arrange
        $user = User::factory()->create();
        $product = Product::factory()->create();
        
        $data = [
            'customer_id' => null,
            'user_id' => $user->id,
            'items' => [
                [
                    'product_id' => $product->id,
                    'quantity' => 5,
                    'unit_price' => 40,
                ]
            ]
        ];
        
        // Act
        $invoice = $this->invoiceService->createInvoice($data);
        
        // Assert
        $this->assertDatabaseHas('invoices', [
            'id' => $invoice->id,
            'user_id' => $user->id,
        ]);
        
        $this->assertCount(1, $invoice->items);
    }
}
```

---

## 2. MySQL Database Design

### 📐 Normalization Rules

#### Third Normal Form (3NF)
```
✅ Requirements:
1. Each column contains atomic values
2. No repeating groups
3. All non-key columns depend on primary key
4. No transitive dependencies

Example:
❌ Bad: invoices table with customer_name, customer_phone
✅ Good: invoices.customer_id → customers table
```

#### Denormalization (When Needed)
```sql
-- Acceptable denormalization for performance
-- Store calculated values that are expensive to compute

-- Example: total_purchases in customers table
-- Updated via triggers or application logic
CREATE TABLE customers (
    id BIGINT UNSIGNED PRIMARY KEY,
    name VARCHAR(255),
    total_purchases DECIMAL(10,2) DEFAULT 0,  -- Denormalized
    INDEX idx_total_purchases (total_purchases)
);
```

### 🏷️ Naming Conventions

```sql
-- Tables: plural, snake_case
users
invoice_items
inventory_movements

-- Columns: snake_case
created_at
user_id
unit_price

-- Foreign Keys: {table_singular}_id
user_id
product_id
invoice_id

-- Indexes: idx_{table}_{column(s)}
idx_invoices_customer_id
idx_invoices_created_at
idx_invoice_items_product_id

-- Unique Constraints: uq_{table}_{column(s)}
uq_users_email
uq_products_sku
uq_invoices_invoice_number

-- Foreign Key Constraints: fk_{table}_{referenced_table}
fk_invoices_customer
fk_invoice_items_product
```

### 📊 Data Types Best Practices

```sql
-- IDs: Always BIGINT UNSIGNED
id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY

-- Money: DECIMAL(10,2) for precision
price DECIMAL(10,2) NOT NULL
total DECIMAL(10,2) NOT NULL DEFAULT 0

-- Quantities: DECIMAL(10,2) for fractional amounts
quantity DECIMAL(10,2) NOT NULL

-- Percentages: DECIMAL(5,2)
discount_percentage DECIMAL(5,2) NULL
tax_rate DECIMAL(5,2) NOT NULL DEFAULT 0

-- Dates: TIMESTAMP with timezone awareness
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP

-- Enums: For fixed options
status ENUM('pending','approved','rejected','completed') NOT NULL DEFAULT 'pending'

-- Text: VARCHAR for limited, TEXT for unlimited
name VARCHAR(255) NOT NULL
description TEXT NULL
notes TEXT NULL

-- Booleans: BOOLEAN (TINYINT(1))
is_active BOOLEAN NOT NULL DEFAULT TRUE
is_returnable BOOLEAN NOT NULL DEFAULT TRUE
```

### 🔑 Indexing Strategy

```sql
-- Primary Key (automatic index)
PRIMARY KEY (id)

-- Foreign Keys (always index)
INDEX idx_invoices_customer_id (customer_id)
INDEX idx_invoice_items_invoice_id (invoice_id)

-- Frequently Queried Columns
INDEX idx_invoices_status (status)
INDEX idx_invoices_created_at (created_at)
INDEX idx_products_category_id (category_id)

-- Composite Indexes (order matters!)
INDEX idx_invoices_user_status (user_id, status)
INDEX idx_inventory_movements_product_type (product_id, movement_type)

-- Unique Indexes
UNIQUE KEY uq_users_email (email)
UNIQUE KEY uq_products_sku (sku)
UNIQUE KEY uq_invoices_number (invoice_number)

-- Full-Text Indexes (for search)
FULLTEXT INDEX ft_products_name (name)
```

### 🔗 Foreign Key Constraints

```sql
-- Standard Foreign Key
CONSTRAINT fk_invoices_customer 
    FOREIGN KEY (customer_id) 
    REFERENCES customers(id)
    ON DELETE SET NULL
    ON UPDATE CASCADE

-- Cascade Delete (for dependent records)
CONSTRAINT fk_invoice_items_invoice 
    FOREIGN KEY (invoice_id) 
    REFERENCES invoices(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE

-- Restrict Delete (prevent deletion if referenced)
CONSTRAINT fk_products_category 
    FOREIGN KEY (category_id) 
    REFERENCES categories(id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
```

### ⚡ Performance Optimization

```sql
-- Use InnoDB Engine (supports transactions & foreign keys)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Partitioning for Large Tables (optional)
CREATE TABLE invoices (
    id BIGINT UNSIGNED AUTO_INCREMENT,
    created_at TIMESTAMP,
    -- other columns
    PRIMARY KEY (id, created_at)
)
PARTITION BY RANGE (YEAR(created_at)) (
    PARTITION p2023 VALUES LESS THAN (2024),
    PARTITION p2024 VALUES LESS THAN (2025),
    PARTITION p2025 VALUES LESS THAN (2026)
);

-- Analyze Tables Regularly
ANALYZE TABLE invoices;
ANALYZE TABLE invoice_items;

-- Optimize Tables
OPTIMIZE TABLE invoices;
```

### 📝 Migration Best Practices

```php
// Create Table Migration
public function up(): void
{
    Schema::create('invoices', function (Blueprint $table) {
        $table->id();
        $table->string('invoice_number', 50)->unique();
        $table->foreignId('customer_id')->nullable()
              ->constrained()->nullOnDelete();
        $table->foreignId('user_id')
              ->constrained()->cascadeOnDelete();
        $table->decimal('subtotal', 10, 2)->default(0);
        $table->decimal('discount', 10, 2)->default(0);
        $table->decimal('total', 10, 2)->default(0);
        $table->enum('status', ['completed', 'cancelled', 'refunded'])
              ->default('completed');
        $table->text('notes')->nullable();
        $table->timestamps();
        $table->softDeletes();
        
        // Indexes
        $table->index('status');
        $table->index('created_at');
        $table->index(['user_id', 'status']);
    });
}

// Add Column Migration
public function up(): void
{
    Schema::table('invoices', function (Blueprint $table) {
        $table->decimal('paid_amount', 10, 2)->default(0)->after('total');
        $table->decimal('due_amount', 10, 2)->default(0)->after('paid_amount');
        $table->enum('payment_status', ['unpaid', 'partial', 'paid'])
              ->default('unpaid')->after('due_amount');
        
        $table->index('payment_status');
    });
}
```

---

## 3. POS System Architecture

### 🏛️ Layered Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                        │
│  Controllers, Views, API Resources, Blade Templates         │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                   Application Layer                          │
│  Services (Business Logic), DTOs, Events, Jobs              │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                     Domain Layer                             │
│  Models, Value Objects, Domain Events, Policies            │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                 Infrastructure Layer                         │
│  Repositories, Database, External APIs, File Storage        │
└─────────────────────────────────────────────────────────────┘
```

### 🎯 Design Patterns Implementation

#### 1. Repository Pattern
```php
// Contract
interface ProductRepositoryInterface
{
    public function all(): Collection;
    public function find(int $id): ?Product;
    public function findBySku(string $sku): ?Product;
    public function create(array $data): Product;
    public function update(int $id, array $data): bool;
    public function delete(int $id): bool;
    public function getByCategory(int $categoryId): Collection;
    public function getLowStock(): Collection;
}

// Implementation
class ProductRepository implements ProductRepositoryInterface
{
    public function getLowStock(): Collection
    {
        return Product::whereHas('inventory', function ($query) {
            $query->whereRaw('quantity < min_stock_level');
        })->with('inventory')->get();
    }
}
```

#### 2. Service Pattern
```php
class SalesService
{
    public function __construct(
        private InvoiceRepository $invoiceRepo,
        private InventoryService $inventoryService,
        private PricingService $pricingService,
        private CostCalculationService $costService
    ) {}
    
    public function processSale(array $saleData): Invoice
    {
        return DB::transaction(function () use ($saleData) {
            // 1. Validate stock availability
            $this->validateStockAvailability($saleData['items']);
            
            // 2. Create invoice
            $invoice = $this->invoiceRepo->create([
                'invoice_number' => $this->generateInvoiceNumber(),
                'customer_id' => $saleData['customer_id'] ?? null,
                'user_id' => auth()->id(),
                'status' => 'completed',
            ]);
            
            // 3. Process each item
            $subtotal = 0;
            foreach ($saleData['items'] as $itemData) {
                $item = $this->addInvoiceItem($invoice, $itemData);
                $subtotal += $item->total_price;
            }
            
            // 4. Apply discounts
            $discount = $this->calculateDiscount($invoice, $saleData);
            
            // 5. Update invoice totals
            $invoice->update([
                'subtotal' => $subtotal,
                'discount' => $discount,
                'total' => $subtotal - $discount,
            ]);
            
            // 6. Process payment
            $this->processPayment($invoice, $saleData['payment']);
            
            // 7. Calculate costs
            $this->costService->calculateInvoiceCost($invoice);
            
            return $invoice->fresh(['items', 'payments', 'invoiceCost']);
        });
    }
    
    private function validateStockAvailability(array $items): void
    {
        foreach ($items as $item) {
            $available = $this->inventoryService->getAvailableStock(
                $item['product_id']
            );
            
            if ($available < $item['quantity']) {
                throw new InsufficientStockException(
                    "Insufficient stock for product ID {$item['product_id']}"
                );
            }
        }
    }
}
```

#### 3. Observer Pattern (Event-Driven)
```php
// Event
class InvoiceCreated
{
    public function __construct(public Invoice $invoice) {}
}

// Listener
class UpdateInventoryOnSale
{
    public function handle(InvoiceCreated $event): void
    {
        foreach ($event->invoice->items as $item) {
            $this->inventoryService->deductStock(
                $item->product_id,
                $item->quantity,
                'sale',
                $item->id
            );
        }
    }
}

// Register in EventServiceProvider
protected $listen = [
    InvoiceCreated::class => [
        UpdateInventoryOnSale::class,
        CalculateInvoiceCost::class,
        SendInvoiceNotification::class,
    ],
];
```

#### 4. Strategy Pattern (Pricing)
```php
interface PricingStrategyInterface
{
    public function calculatePrice(Product $product, float $quantity, ?int $sizeId): float;
}

class DecantPricingStrategy implements PricingStrategyInterface
{
    public function calculatePrice(Product $product, float $quantity, ?int $sizeId): float
    {
        $tierPrice = TierPrice::where('tier_id', $product->price_tier_id)
                              ->where('size_id', $sizeId)
                              ->firstOrFail();
        
        return $tierPrice->price;
    }
}

class UnitBasedPricingStrategy implements PricingStrategyInterface
{
    public function calculatePrice(Product $product, float $quantity, ?int $sizeId): float
    {
        $unitPrice = UnitBasedPrice::where('product_id', $product->id)
                                   ->where('tier_id', $product->price_tier_id)
                                   ->firstOrFail();
        
        return $unitPrice->price_per_unit * $quantity;
    }
}

// Usage
class PricingService
{
    public function getPrice(Product $product, float $quantity, ?int $sizeId): float
    {
        $strategy = match($product->selling_type) {
            'DECANT_ONLY', 'FULL_ONLY', 'BOTH' => new DecantPricingStrategy(),
            'UNIT_BASED' => new UnitBasedPricingStrategy(),
        };
        
        return $strategy->calculatePrice($product, $quantity, $sizeId);
    }
}
```


#### 5. Factory Pattern
```php
class InvoiceFactory
{
    public static function createFromSaleData(array $data): Invoice
    {
        return new Invoice([
            'invoice_number' => self::generateInvoiceNumber(),
            'customer_id' => $data['customer_id'] ?? null,
            'user_id' => auth()->id(),
            'status' => 'completed',
        ]);
    }
    
    private static function generateInvoiceNumber(): string
    {
        $date = now()->format('Ymd');
        $sequence = Invoice::whereDate('created_at', today())->count() + 1;
        return "INV-{$date}-" . str_pad($sequence, 4, '0', STR_PAD_LEFT);
    }
}
```

### 🔄 Transaction Management

```php
class TransactionService
{
    /**
     * Execute operation within database transaction
     */
    public function executeInTransaction(callable $callback): mixed
    {
        return DB::transaction(function () use ($callback) {
            try {
                return $callback();
            } catch (\Exception $e) {
                Log::error('Transaction failed', [
                    'error' => $e->getMessage(),
                    'trace' => $e->getTraceAsString(),
                    'user_id' => auth()->id(),
                ]);
                throw $e;
            }
        });
    }
}

// Usage Example
class ReturnService
{
    public function processReturn(array $returnData): Return
    {
        return $this->transactionService->executeInTransaction(function () use ($returnData) {
            // 1. Create return record
            $return = $this->createReturn($returnData);
            
            // 2. Add return items
            $this->addReturnItems($return, $returnData['items']);
            
            // 3. Update inventory
            $this->restoreInventory($return);
            
            // 4. Reverse costs
            $this->reverseCosts($return);
            
            // 5. Process refund
            $this->processRefund($return);
            
            return $return;
        });
    }
}
```

### 📊 Audit Trail Implementation

```php
class InventoryMovementService
{
    public function recordMovement(
        int $productId,
        string $movementType,
        float $quantity,
        ?string $referenceType = null,
        ?int $referenceId = null,
        ?string $batchNumber = null,
        ?string $notes = null
    ): InventoryMovement {
        $inventory = Inventory::where('product_id', $productId)->firstOrFail();
        $quantityBefore = $inventory->quantity;
        
        // Update inventory
        $newQuantity = match($movementType) {
            'in', 'adjustment' => $quantityBefore + abs($quantity),
            'out' => $quantityBefore - abs($quantity),
        };
        
        $inventory->update(['quantity' => $newQuantity]);
        
        // Record movement
        return InventoryMovement::create([
            'product_id' => $productId,
            'movement_type' => $movementType,
            'quantity' => $quantity,
            'quantity_before' => $quantityBefore,
            'quantity_after' => $newQuantity,
            'reference_type' => $referenceType,
            'reference_id' => $referenceId,
            'batch_number' => $batchNumber,
            'user_id' => auth()->id(),
            'notes' => $notes,
        ]);
    }
}
```

---

## 4. Security Best Practices

### 🔐 Authentication & Authorization

#### Role-Based Access Control (RBAC)
```php
// Define Roles
enum UserRole: string
{
    case ADMIN = 'admin';
    case MANAGER = 'manager';
    case SELLER = 'seller';
    case WAREHOUSE = 'warehouse';
}

// User Model
class User extends Authenticatable
{
    public function hasRole(string|array $roles): bool
    {
        if (is_array($roles)) {
            return in_array($this->role, $roles);
        }
        return $this->role === $roles;
    }
    
    public function isAdmin(): bool
    {
        return $this->role === UserRole::ADMIN->value;
    }
    
    public function canManageInventory(): bool
    {
        return in_array($this->role, [
            UserRole::ADMIN->value,
            UserRole::MANAGER->value,
            UserRole::WAREHOUSE->value,
        ]);
    }
}

// Middleware
class CheckRole
{
    public function handle(Request $request, Closure $next, string ...$roles): Response
    {
        if (!$request->user()->hasRole($roles)) {
            abort(403, 'Unauthorized action.');
        }
        
        return $next($request);
    }
}

// Route Protection
Route::middleware(['auth', 'role:admin,manager'])->group(function () {
    Route::get('/reports/profit', [ReportController::class, 'profit']);
    Route::post('/products', [ProductController::class, 'store']);
});
```

#### API Authentication (Sanctum)
```php
// config/sanctum.php
'expiration' => 60 * 24, // 24 hours

// Login Controller
public function login(Request $request)
{
    $credentials = $request->validate([
        'email' => 'required|email',
        'password' => 'required',
    ]);
    
    if (!Auth::attempt($credentials)) {
        return response()->json([
            'message' => 'Invalid credentials'
        ], 401);
    }
    
    $user = Auth::user();
    $token = $user->createToken('api-token', [
        'role:' . $user->role
    ])->plainTextToken;
    
    return response()->json([
        'token' => $token,
        'user' => $user,
    ]);
}

// Protected Route
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/invoices', [InvoiceController::class, 'store']);
});
```

### 🛡️ Data Protection

#### Input Validation & Sanitization
```php
class StoreProductRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'name' => 'required|string|max:255|regex:/^[\pL\s\-]+$/u',
            'sku' => 'required|string|max:50|unique:products,sku|alpha_dash',
            'category_id' => 'required|exists:categories,id',
            'price_tier_id' => 'required|exists:price_tiers,id',
            'selling_type' => 'required|in:DECANT_ONLY,FULL_ONLY,BOTH,UNIT_BASED',
            'is_returnable' => 'boolean',
        ];
    }
    
    protected function prepareForValidation(): void
    {
        $this->merge([
            'name' => strip_tags($this->name),
            'sku' => strtoupper(trim($this->sku)),
        ]);
    }
}
```

#### SQL Injection Prevention
```php
// ✅ Good: Using Eloquent (parameterized queries)
$products = Product::where('category_id', $categoryId)
                   ->where('is_active', true)
                   ->get();

// ✅ Good: Using Query Builder with bindings
$products = DB::table('products')
              ->where('category_id', '=', $categoryId)
              ->get();

// ❌ Bad: Raw SQL without bindings
$products = DB::select("SELECT * FROM products WHERE category_id = $categoryId");

// ✅ Good: Raw SQL with bindings
$products = DB::select(
    "SELECT * FROM products WHERE category_id = ?",
    [$categoryId]
);
```

#### XSS Protection
```php
// Blade Templates (auto-escaping)
{{ $product->name }}  // ✅ Escaped
{!! $product->name !!}  // ❌ Not escaped (use only for trusted HTML)

// Manual Escaping
$safeName = e($product->name);
$safeHtml = htmlspecialchars($content, ENT_QUOTES, 'UTF-8');
```

#### Mass Assignment Protection
```php
class Product extends Model
{
    // Option 1: Whitelist (recommended)
    protected $fillable = [
        'name',
        'sku',
        'category_id',
        'price_tier_id',
        'selling_type',
        'is_returnable',
    ];
    
    // Option 2: Blacklist
    protected $guarded = [
        'id',
        'created_at',
        'updated_at',
    ];
}
```

### 🔒 Financial Security

#### Price Manipulation Prevention
```php
class InvoiceService
{
    public function addItemToInvoice(Invoice $invoice, array $itemData): InvoiceItem
    {
        // ❌ Never trust client-provided prices
        // $unitPrice = $itemData['unit_price']; // DANGEROUS!
        
        // ✅ Always calculate price server-side
        $product = Product::findOrFail($itemData['product_id']);
        $unitPrice = $this->pricingService->calculatePrice(
            $product,
            $itemData['quantity'],
            $itemData['size_id'] ?? null
        );
        
        // Validate against manipulation
        if (isset($itemData['unit_price']) && 
            abs($itemData['unit_price'] - $unitPrice) > 0.01) {
            Log::warning('Price manipulation attempt detected', [
                'user_id' => auth()->id(),
                'product_id' => $product->id,
                'expected_price' => $unitPrice,
                'provided_price' => $itemData['unit_price'],
            ]);
        }
        
        return InvoiceItem::create([
            'invoice_id' => $invoice->id,
            'product_id' => $product->id,
            'quantity' => $itemData['quantity'],
            'unit_price' => $unitPrice, // Server-calculated
            'total_price' => $unitPrice * $itemData['quantity'],
        ]);
    }
}
```

#### Audit Logging
```php
class AuditLogger
{
    public function logFinancialTransaction(
        string $action,
        Model $model,
        ?array $oldValues = null,
        ?array $newValues = null
    ): void {
        AuditLog::create([
            'user_id' => auth()->id(),
            'action' => $action,
            'auditable_type' => get_class($model),
            'auditable_id' => $model->id,
            'old_values' => $oldValues,
            'new_values' => $newValues,
            'ip_address' => request()->ip(),
            'user_agent' => request()->userAgent(),
        ]);
    }
}

// Usage
class InvoiceObserver
{
    public function created(Invoice $invoice): void
    {
        app(AuditLogger::class)->logFinancialTransaction(
            'invoice_created',
            $invoice,
            null,
            $invoice->toArray()
        );
    }
    
    public function updated(Invoice $invoice): void
    {
        app(AuditLogger::class)->logFinancialTransaction(
            'invoice_updated',
            $invoice,
            $invoice->getOriginal(),
            $invoice->getChanges()
        );
    }
}
```

### 🚨 Error Handling (Security)

```php
// app/Exceptions/Handler.php
public function render($request, Throwable $exception)
{
    // Don't expose internal errors in production
    if (app()->environment('production')) {
        if ($exception instanceof \PDOException) {
            return response()->json([
                'message' => 'Database error occurred'
            ], 500);
        }
        
        if ($exception instanceof \Exception) {
            Log::error('Application error', [
                'exception' => get_class($exception),
                'message' => $exception->getMessage(),
                'trace' => $exception->getTraceAsString(),
            ]);
            
            return response()->json([
                'message' => 'An error occurred'
            ], 500);
        }
    }
    
    return parent::render($request, $exception);
}
```

### 🔐 Environment Security

```env
# .env (NEVER commit to git)
APP_ENV=production
APP_DEBUG=false  # CRITICAL: false in production
APP_KEY=base64:...  # Generate with: php artisan key:generate

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=perfumes_pos
DB_USERNAME=secure_user
DB_PASSWORD=strong_random_password_here

# Session Security
SESSION_DRIVER=database
SESSION_LIFETIME=120
SESSION_SECURE_COOKIE=true
SESSION_HTTP_ONLY=true
SESSION_SAME_SITE=strict
```

---

## 5. Performance Optimization

### ⚡ Database Query Optimization

#### N+1 Query Problem
```php
// ❌ Bad: N+1 queries (1 + N queries)
$invoices = Invoice::all(); // 1 query
foreach ($invoices as $invoice) {
    echo $invoice->customer->name; // N queries
    echo $invoice->user->name; // N queries
}

// ✅ Good: Eager loading (3 queries total)
$invoices = Invoice::with(['customer', 'user'])->get();
foreach ($invoices as $invoice) {
    echo $invoice->customer->name;
    echo $invoice->user->name;
}

// ✅ Better: Eager loading with constraints
$invoices = Invoice::with([
    'customer:id,name,phone',
    'user:id,name',
    'items' => function ($query) {
        $query->select('id', 'invoice_id', 'product_id', 'quantity', 'total_price')
              ->with('product:id,name');
    }
])->get();
```

#### Select Only Needed Columns
```php
// ❌ Bad: Fetching all columns
$products = Product::all();

// ✅ Good: Select specific columns
$products = Product::select('id', 'name', 'sku', 'price_tier_id')->get();

// ✅ Good: With relationships
$products = Product::select('id', 'name', 'sku')
                   ->with('category:id,name')
                   ->get();
```

#### Chunking Large Datasets
```php
// ❌ Bad: Loading all records into memory
$invoices = Invoice::all(); // Memory intensive
foreach ($invoices as $invoice) {
    // Process
}

// ✅ Good: Chunk processing
Invoice::chunk(100, function ($invoices) {
    foreach ($invoices as $invoice) {
        // Process
    }
});

// ✅ Better: Lazy loading (Laravel 8+)
Invoice::lazy(100)->each(function ($invoice) {
    // Process
});
```

#### Query Optimization Examples
```php
// ❌ Bad: Multiple queries
$totalSales = Invoice::sum('total');
$totalCost = InvoiceCost::sum('total_cost');
$profit = $totalSales - $totalCost;

// ✅ Good: Single query with subquery
$result = DB::table('invoices')
    ->selectRaw('
        SUM(total) as total_sales,
        (SELECT SUM(total_cost) FROM invoice_costs) as total_cost,
        SUM(total) - (SELECT SUM(total_cost) FROM invoice_costs) as profit
    ')
    ->first();

// ✅ Good: Using joins
$results = Invoice::join('invoice_costs', 'invoices.id', '=', 'invoice_costs.invoice_id')
    ->selectRaw('
        invoices.id,
        invoices.total,
        invoice_costs.total_cost,
        (invoices.total - invoice_costs.total_cost) as profit
    ')
    ->get();
```

### 💾 Caching Strategy

#### Cache Configuration
```php
// config/cache.php
'default' => env('CACHE_DRIVER', 'redis'),

'stores' => [
    'redis' => [
        'driver' => 'redis',
        'connection' => 'cache',
    ],
],
```

#### Caching Examples
```php
class ProductService
{
    // Cache product list
    public function getAllProducts(): Collection
    {
        return Cache::remember('products.all', 3600, function () {
            return Product::with(['category', 'priceTier'])->get();
        });
    }
    
    // Cache tier prices
    public function getTierPrices(): Collection
    {
        return Cache::remember('tier_prices', 3600, function () {
            return TierPrice::with(['tier', 'size'])->get();
        });
    }
    
    // Clear cache on update
    public function updateProduct(int $id, array $data): Product
    {
        $product = Product::findOrFail($id);
        $product->update($data);
        
        // Clear related caches
        Cache::forget('products.all');
        Cache::forget("product.{$id}");
        
        return $product;
    }
}

// Cache tags (Redis/Memcached only)
Cache::tags(['products', 'prices'])->put('tier_prices', $prices, 3600);
Cache::tags(['products'])->flush(); // Clear all product-related caches
```

#### Query Result Caching
```php
// Cache expensive queries
public function getDailySalesReport(Carbon $date): array
{
    $cacheKey = "sales.daily.{$date->format('Y-m-d')}";
    
    return Cache::remember($cacheKey, 86400, function () use ($date) {
        return DB::table('invoices')
            ->whereDate('created_at', $date)
            ->selectRaw('
                COUNT(*) as total_invoices,
                SUM(total) as total_sales,
                AVG(total) as average_sale
            ')
            ->first();
    });
}
```

### 🚀 Code Optimization

#### Use Collections Efficiently
```php
// ❌ Bad: Multiple database queries
$products = Product::all();
$activeProducts = $products->where('is_active', true);
$expensiveProducts = $products->where('price', '>', 100);

// ✅ Good: Single query with filters
$products = Product::where('is_active', true)->get();
$expensiveProducts = $products->where('price', '>', 100);

// ✅ Good: Use collection methods
$totalRevenue = $invoices->sum('total');
$averageRevenue = $invoices->avg('total');
$groupedByStatus = $invoices->groupBy('status');
```

#### Lazy Loading vs Eager Loading
```php
// Use lazy loading for single record
$invoice = Invoice::find($id);
if ($invoice->customer) {
    // Load customer only if needed
}

// Use eager loading for collections
$invoices = Invoice::with('customer')->get();
```


### 📊 Database Connection Optimization

```php
// config/database.php
'mysql' => [
    'driver' => 'mysql',
    'host' => env('DB_HOST', '127.0.0.1'),
    'port' => env('DB_PORT', '3306'),
    'database' => env('DB_DATABASE', 'forge'),
    'username' => env('DB_USERNAME', 'forge'),
    'password' => env('DB_PASSWORD', ''),
    'charset' => 'utf8mb4',
    'collation' => 'utf8mb4_unicode_ci',
    'prefix' => '',
    'strict' => true,
    'engine' => 'InnoDB',
    'options' => [
        PDO::ATTR_PERSISTENT => true, // Connection pooling
        PDO::ATTR_EMULATE_PREPARES => false,
    ],
],
```

### 🎯 Response Optimization

```php
// API Resource for optimized responses
class InvoiceResource extends JsonResource
{
    public function toArray($request): array
    {
        return [
            'id' => $this->id,
            'invoice_number' => $this->invoice_number,
            'total' => $this->total,
            'status' => $this->status,
            'created_at' => $this->created_at->toIso8601String(),
            
            // Conditional loading
            'customer' => $this->whenLoaded('customer', function () {
                return [
                    'id' => $this->customer->id,
                    'name' => $this->customer->name,
                ];
            }),
            
            // Load items only when requested
            'items' => InvoiceItemResource::collection(
                $this->whenLoaded('items')
            ),
        ];
    }
}

// Pagination
public function index(Request $request)
{
    $invoices = Invoice::with(['customer:id,name'])
        ->latest()
        ->paginate(15);
    
    return InvoiceResource::collection($invoices);
}
```

---

## 6. Business Logic (POS Specific)

### 🛒 Sales Process Workflow

```php
class SalesService
{
    /**
     * Complete sales workflow
     */
    public function processSale(array $saleData): Invoice
    {
        return DB::transaction(function () use ($saleData) {
            // Step 1: Validate stock availability
            $this->validateStockAvailability($saleData['items']);
            
            // Step 2: Create invoice
            $invoice = $this->createInvoice($saleData);
            
            // Step 3: Add items and update inventory
            foreach ($saleData['items'] as $itemData) {
                $this->addItemToInvoice($invoice, $itemData);
            }
            
            // Step 4: Calculate totals
            $this->calculateInvoiceTotals($invoice);
            
            // Step 5: Apply discounts
            if (isset($saleData['discount_id'])) {
                $this->applyDiscount($invoice, $saleData['discount_id']);
            }
            
            // Step 6: Process payment
            $this->processPayment($invoice, $saleData['payment']);
            
            // Step 7: Calculate costs
            $this->calculateCosts($invoice);
            
            // Step 8: Fire events
            event(new InvoiceCreated($invoice));
            
            return $invoice->fresh(['items', 'payments', 'invoiceCost']);
        });
    }
    
    private function validateStockAvailability(array $items): void
    {
        foreach ($items as $item) {
            $product = Product::findOrFail($item['product_id']);
            $inventory = $product->inventory;
            
            $requiredQuantity = $this->calculateRequiredQuantity(
                $product,
                $item['quantity'],
                $item['size_id'] ?? null
            );
            
            if ($inventory->quantity < $requiredQuantity) {
                throw new InsufficientStockException(
                    "Insufficient stock for {$product->name}. " .
                    "Available: {$inventory->quantity}, Required: {$requiredQuantity}"
                );
            }
        }
    }
    
    private function calculateRequiredQuantity(
        Product $product,
        float $quantity,
        ?int $sizeId
    ): float {
        return match($product->selling_type) {
            'DECANT_ONLY', 'BOTH' => $this->getDecantQuantity($sizeId, $quantity),
            'FULL_ONLY' => $this->getFullBottleQuantity($product, $quantity),
            'UNIT_BASED' => $quantity,
        };
    }
}
```

### 💰 Pricing Logic

```php
class PricingService
{
    public function calculatePrice(
        Product $product,
        float $quantity,
        ?int $sizeId = null
    ): float {
        return match($product->selling_type) {
            'DECANT_ONLY', 'FULL_ONLY', 'BOTH' => $this->getTierPrice($product, $sizeId),
            'UNIT_BASED' => $this->getUnitBasedPrice($product, $quantity),
        };
    }
    
    private function getTierPrice(Product $product, int $sizeId): float
    {
        $tierPrice = TierPrice::where('tier_id', $product->price_tier_id)
            ->where('size_id', $sizeId)
            ->first();
        
        if (!$tierPrice) {
            throw new PriceNotFoundException(
                "Price not found for tier {$product->price_tier_id} and size {$sizeId}"
            );
        }
        
        return $tierPrice->price;
    }
    
    private function getUnitBasedPrice(Product $product, float $quantity): float
    {
        $unitPrice = UnitBasedPrice::where('product_id', $product->id)
            ->where('tier_id', $product->price_tier_id)
            ->first();
        
        if (!$unitPrice) {
            throw new PriceNotFoundException(
                "Unit price not found for product {$product->id}"
            );
        }
        
        return $unitPrice->price_per_unit * $quantity;
    }
}
```

### 📦 Inventory Management

```php
class InventoryService
{
    public function deductStock(
        int $productId,
        float $quantity,
        string $referenceType,
        int $referenceId,
        ?string $batchNumber = null
    ): void {
        $inventory = Inventory::where('product_id', $productId)
            ->lockForUpdate()
            ->firstOrFail();
        
        if ($inventory->quantity < $quantity) {
            throw new InsufficientStockException(
                "Cannot deduct {$quantity} from stock. Available: {$inventory->quantity}"
            );
        }
        
        $quantityBefore = $inventory->quantity;
        $quantityAfter = $quantityBefore - $quantity;
        
        // Update inventory
        $inventory->update(['quantity' => $quantityAfter]);
        
        // Record movement
        InventoryMovement::create([
            'product_id' => $productId,
            'movement_type' => 'out',
            'quantity' => -$quantity,
            'quantity_before' => $quantityBefore,
            'quantity_after' => $quantityAfter,
            'reference_type' => $referenceType,
            'reference_id' => $referenceId,
            'batch_number' => $batchNumber,
            'user_id' => auth()->id(),
            'notes' => "Stock deducted for {$referenceType} #{$referenceId}",
        ]);
        
        // Check low stock alert
        if ($quantityAfter <= $inventory->min_stock_level) {
            event(new LowStockAlert($inventory));
        }
    }
    
    public function addStock(
        int $productId,
        float $quantity,
        string $referenceType,
        int $referenceId,
        ?string $batchNumber = null
    ): void {
        $inventory = Inventory::where('product_id', $productId)
            ->lockForUpdate()
            ->firstOrFail();
        
        $quantityBefore = $inventory->quantity;
        $quantityAfter = $quantityBefore + $quantity;
        
        // Update inventory
        $inventory->update(['quantity' => $quantityAfter]);
        
        // Record movement
        InventoryMovement::create([
            'product_id' => $productId,
            'movement_type' => 'in',
            'quantity' => $quantity,
            'quantity_before' => $quantityBefore,
            'quantity_after' => $quantityAfter,
            'reference_type' => $referenceType,
            'reference_id' => $referenceId,
            'batch_number' => $batchNumber,
            'user_id' => auth()->id(),
            'notes' => "Stock added from {$referenceType} #{$referenceId}",
        ]);
    }
}
```

### 💸 Cost Calculation

```php
class CostCalculationService
{
    public function calculateInvoiceCost(Invoice $invoice): InvoiceCost
    {
        $productCost = 0;
        $materialCost = 0;
        
        foreach ($invoice->items as $item) {
            // Calculate product cost
            $productCost += $this->calculateProductCost($item);
            
            // Calculate material cost (from recipes)
            $materialCost += $this->calculateMaterialCost($item);
        }
        
        return InvoiceCost::updateOrCreate(
            ['invoice_id' => $invoice->id],
            [
                'product_cost' => $productCost,
                'material_cost' => $materialCost,
                'total_cost' => $productCost + $materialCost,
            ]
        );
    }
    
    private function calculateProductCost(InvoiceItem $item): float
    {
        // Use weighted average cost from purchases
        $avgCost = Purchase::where('product_id', $item->product_id)
            ->avg('unit_cost') ?? 0;
        
        return $avgCost * $item->quantity;
    }
    
    private function calculateMaterialCost(InvoiceItem $item): float
    {
        $product = $item->product;
        
        // Find recipe
        $recipe = Recipe::where('product_id', $product->id)
            ->where('size_id', $item->size_id)
            ->where('is_active', true)
            ->first();
        
        if (!$recipe) {
            return 0;
        }
        
        $totalMaterialCost = 0;
        
        foreach ($recipe->items as $recipeItem) {
            $material = $recipeItem->material;
            
            // Calculate quantity with waste
            $quantityUsed = $recipeItem->quantity * 
                (1 + ($recipeItem->waste_percentage / 100));
            
            // Calculate cost
            $cost = $quantityUsed * $material->avg_cost;
            $totalMaterialCost += $cost;
            
            // Record material usage
            MaterialUsage::create([
                'invoice_item_id' => $item->id,
                'material_id' => $material->id,
                'quantity_used' => $quantityUsed,
                'cost_per_unit_snapshot' => $material->avg_cost,
                'total_cost' => $cost,
            ]);
        }
        
        return $totalMaterialCost * $item->quantity;
    }
}
```

### 🔄 Returns Process

```php
class ReturnService
{
    public function processReturn(array $returnData): Return
    {
        return DB::transaction(function () use ($returnData) {
            $invoice = Invoice::findOrFail($returnData['invoice_id']);
            
            // Step 1: Validate return eligibility
            $this->validateReturn($invoice, $returnData);
            
            // Step 2: Create return record
            $return = $this->createReturn($invoice, $returnData);
            
            // Step 3: Add return items
            $this->addReturnItems($return, $returnData['items']);
            
            // Step 4: Calculate refund amount
            $refundAmount = $this->calculateRefundAmount($return);
            
            // Step 5: Apply restock fee if applicable
            $restockFee = $this->calculateRestockFee($refundAmount, $returnData);
            
            // Step 6: Update return with amounts
            $return->update([
                'refund_amount' => $refundAmount - $restockFee,
                'restock_fee' => $restockFee,
                'restock_fee_percentage' => $returnData['restock_fee_percentage'] ?? null,
                'status' => 'approved',
            ]);
            
            // Step 7: Restore inventory
            $this->restoreInventory($return);
            
            // Step 8: Reverse costs
            $this->reverseCosts($return);
            
            // Step 9: Update invoice status
            $invoice->update(['status' => 'refunded']);
            
            event(new ReturnProcessed($return));
            
            return $return->fresh(['items', 'invoice']);
        });
    }
    
    private function validateReturn(Invoice $invoice, array $returnData): void
    {
        // Check if invoice can be returned
        if ($invoice->status === 'cancelled') {
            throw new InvalidReturnException('Cannot return a cancelled invoice');
        }
        
        // Check return items
        foreach ($returnData['items'] as $itemData) {
            $product = Product::findOrFail($itemData['product_id']);
            
            if (!$product->is_returnable) {
                throw new InvalidReturnException(
                    "Product {$product->name} is not returnable"
                );
            }
            
            // Validate quantity
            $invoiceItem = $invoice->items()
                ->where('product_id', $itemData['product_id'])
                ->first();
            
            if (!$invoiceItem || $invoiceItem->quantity < $itemData['quantity']) {
                throw new InvalidReturnException(
                    "Invalid return quantity for {$product->name}"
                );
            }
        }
    }
    
    private function reverseCosts(Return $return): void
    {
        $invoice = $return->invoice;
        $invoiceCost = $invoice->invoiceCost;
        
        if (!$invoiceCost) {
            return;
        }
        
        // Calculate cost ratio
        $costRatio = $return->refund_amount / $invoice->total;
        
        // Calculate reversed costs
        $reversedProductCost = $invoiceCost->product_cost * $costRatio;
        $reversedMaterialCost = $invoiceCost->material_cost * $costRatio;
        
        // Create cost reversal record
        ReturnCostReversal::create([
            'return_id' => $return->id,
            'invoice_cost_id' => $invoiceCost->id,
            'product_cost' => $reversedProductCost,
            'material_cost' => $reversedMaterialCost,
            'total_cost' => $reversedProductCost + $reversedMaterialCost,
        ]);
    }
}
```

### 💳 Payment Processing

```php
class PaymentService
{
    public function processPayment(Invoice $invoice, array $paymentData): Payment
    {
        $payment = Payment::create([
            'invoice_id' => $invoice->id,
            'payment_method_id' => $paymentData['payment_method_id'],
            'amount' => $paymentData['amount'],
            'reference' => $paymentData['reference'] ?? null,
        ]);
        
        // Update invoice payment status
        $this->updateInvoicePaymentStatus($invoice);
        
        return $payment;
    }
    
    private function updateInvoicePaymentStatus(Invoice $invoice): void
    {
        $totalPaid = $invoice->payments()->sum('amount');
        $dueAmount = $invoice->total - $totalPaid;
        
        $paymentStatus = match(true) {
            $totalPaid == 0 => 'unpaid',
            $totalPaid < $invoice->total => 'partial',
            $totalPaid >= $invoice->total => 'paid',
        };
        
        $invoice->update([
            'paid_amount' => $totalPaid,
            'due_amount' => max(0, $dueAmount),
            'payment_status' => $paymentStatus,
        ]);
    }
}
```

### 🎁 Discount Management

```php
class DiscountService
{
    public function applyDiscount(Invoice $invoice, int $discountId): void
    {
        $discount = Discount::findOrFail($discountId);
        
        // Validate discount
        $this->validateDiscount($discount, $invoice);
        
        // Calculate discount amount
        $discountAmount = match($discount->type) {
            'percentage' => $invoice->subtotal * ($discount->value / 100),
            'fixed' => $discount->value,
        };
        
        // Apply to invoice
        $invoice->update([
            'discount' => $discountAmount,
            'discount_id' => $discount->id,
            'total' => $invoice->subtotal - $discountAmount,
        ]);
    }
    
    private function validateDiscount(Discount $discount, Invoice $invoice): void
    {
        // Check if active
        if (!$discount->is_active) {
            throw new InvalidDiscountException('Discount is not active');
        }
        
        // Check date range
        if ($discount->start_date && now()->lt($discount->start_date)) {
            throw new InvalidDiscountException('Discount not yet valid');
        }
        
        if ($discount->end_date && now()->gt($discount->end_date)) {
            throw new InvalidDiscountException('Discount has expired');
        }
        
        // Check minimum purchase
        if ($discount->min_purchase && $invoice->subtotal < $discount->min_purchase) {
            throw new InvalidDiscountException(
                "Minimum purchase of {$discount->min_purchase} required"
            );
        }
    }
}
```

---

## 7. Code Quality Standards

### 🎯 SOLID Principles

#### Single Responsibility Principle (SRP)
```php
// ❌ Bad: Class doing too much
class InvoiceManager
{
    public function createInvoice($data) { }
    public function calculateTax($invoice) { }
    public function sendEmail($invoice) { }
    public function generatePDF($invoice) { }
}

// ✅ Good: Each class has one responsibility
class InvoiceService
{
    public function createInvoice(array $data): Invoice { }
}

class TaxCalculator
{
    public function calculate(Invoice $invoice): float { }
}

class InvoiceNotifier
{
    public function send(Invoice $invoice): void { }
}

class InvoicePDFGenerator
{
    public function generate(Invoice $invoice): string { }
}
```

#### Open/Closed Principle (OCP)
```php
// Open for extension, closed for modification
interface PaymentGatewayInterface
{
    public function charge(float $amount): bool;
}

class CashPayment implements PaymentGatewayInterface
{
    public function charge(float $amount): bool
    {
        // Cash payment logic
        return true;
    }
}

class CardPayment implements PaymentGatewayInterface
{
    public function charge(float $amount): bool
    {
        // Card payment logic
        return true;
    }
}

// Easy to add new payment methods without modifying existing code
class BankTransferPayment implements PaymentGatewayInterface
{
    public function charge(float $amount): bool
    {
        // Bank transfer logic
        return true;
    }
}
```

#### Liskov Substitution Principle (LSP)
```php
// Subtypes must be substitutable for their base types
abstract class Report
{
    abstract public function generate(): string;
}

class SalesReport extends Report
{
    public function generate(): string
    {
        return "Sales Report Data";
    }
}

class InventoryReport extends Report
{
    public function generate(): string
    {
        return "Inventory Report Data";
    }
}

// Can use any report type
function printReport(Report $report): void
{
    echo $report->generate();
}
```

#### Interface Segregation Principle (ISP)
```php
// ❌ Bad: Fat interface
interface WorkerInterface
{
    public function work();
    public function eat();
    public function sleep();
}

// ✅ Good: Segregated interfaces
interface Workable
{
    public function work();
}

interface Eatable
{
    public function eat();
}

interface Sleepable
{
    public function sleep();
}

class Human implements Workable, Eatable, Sleepable
{
    public function work() { }
    public function eat() { }
    public function sleep() { }
}

class Robot implements Workable
{
    public function work() { }
}
```

#### Dependency Inversion Principle (DIP)
```php
// ❌ Bad: High-level module depends on low-level module
class InvoiceService
{
    private $repository;
    
    public function __construct()
    {
        $this->repository = new InvoiceRepository(); // Tight coupling
    }
}

// ✅ Good: Both depend on abstraction
interface InvoiceRepositoryInterface
{
    public function create(array $data): Invoice;
}

class InvoiceRepository implements InvoiceRepositoryInterface
{
    public function create(array $data): Invoice
    {
        return Invoice::create($data);
    }
}

class InvoiceService
{
    public function __construct(
        private InvoiceRepositoryInterface $repository
    ) {}
}
```


### 📝 Clean Code Practices

#### Meaningful Names
```php
// ❌ Bad
$d = 30; // elapsed time in days
$x = $invoice->total;

// ✅ Good
$elapsedTimeInDays = 30;
$invoiceTotal = $invoice->total;

// ❌ Bad function name
function getData() { }

// ✅ Good function name
function getActiveProducts(): Collection { }
```

#### Small Functions
```php
// ❌ Bad: Function doing too much
public function processInvoice($data)
{
    // 100 lines of code
    // Validation
    // Creation
    // Calculation
    // Notification
}

// ✅ Good: Small, focused functions
public function processInvoice(array $data): Invoice
{
    $this->validateInvoiceData($data);
    $invoice = $this->createInvoice($data);
    $this->calculateTotals($invoice);
    $this->sendNotification($invoice);
    
    return $invoice;
}

private function validateInvoiceData(array $data): void
{
    // Validation logic
}

private function createInvoice(array $data): Invoice
{
    // Creation logic
}
```

#### No Magic Numbers
```php
// ❌ Bad
if ($invoice->total > 1000) {
    $discount = $invoice->total * 0.1;
}

// ✅ Good
const DISCOUNT_THRESHOLD = 1000;
const DISCOUNT_PERCENTAGE = 0.1;

if ($invoice->total > self::DISCOUNT_THRESHOLD) {
    $discount = $invoice->total * self::DISCOUNT_PERCENTAGE;
}
```

#### Comments for "Why", Not "What"
```php
// ❌ Bad: Obvious comment
// Get the product
$product = Product::find($id);

// ✅ Good: Explains why
// Lock the product row to prevent race conditions during stock update
$product = Product::where('id', $id)->lockForUpdate()->first();

// ✅ Good: Complex business logic explanation
// Apply 10% discount for orders above 1000 SAR as per marketing campaign Q1-2024
if ($invoice->total > 1000) {
    $discount = $invoice->total * 0.1;
}
```

### 🧪 Testing Standards

#### Unit Test Example
```php
class PricingServiceTest extends TestCase
{
    use RefreshDatabase;
    
    private PricingService $pricingService;
    
    protected function setUp(): void
    {
        parent::setUp();
        $this->pricingService = app(PricingService::class);
    }
    
    /** @test */
    public function it_calculates_decant_price_correctly(): void
    {
        // Arrange
        $tier = PriceTier::factory()->create(['name' => 'A']);
        $size = Size::factory()->create(['value' => 5, 'name' => '5ml']);
        $tierPrice = TierPrice::factory()->create([
            'tier_id' => $tier->id,
            'size_id' => $size->id,
            'price' => 40.00,
        ]);
        
        $product = Product::factory()->create([
            'price_tier_id' => $tier->id,
            'selling_type' => 'DECANT_ONLY',
        ]);
        
        // Act
        $price = $this->pricingService->calculatePrice($product, 1, $size->id);
        
        // Assert
        $this->assertEquals(40.00, $price);
    }
    
    /** @test */
    public function it_throws_exception_when_price_not_found(): void
    {
        // Arrange
        $product = Product::factory()->create(['selling_type' => 'DECANT_ONLY']);
        
        // Assert
        $this->expectException(PriceNotFoundException::class);
        
        // Act
        $this->pricingService->calculatePrice($product, 1, 999);
    }
}
```

#### Feature Test Example
```php
class InvoiceCreationTest extends TestCase
{
    use RefreshDatabase;
    
    /** @test */
    public function authenticated_user_can_create_invoice(): void
    {
        // Arrange
        $user = User::factory()->create(['role' => 'seller']);
        $product = Product::factory()->create();
        Inventory::factory()->create([
            'product_id' => $product->id,
            'quantity' => 100,
        ]);
        
        $data = [
            'items' => [
                [
                    'product_id' => $product->id,
                    'quantity' => 5,
                    'size_id' => 1,
                ]
            ],
            'payment' => [
                'payment_method_id' => 1,
                'amount' => 40,
            ]
        ];
        
        // Act
        $response = $this->actingAs($user)
            ->postJson('/api/invoices', $data);
        
        // Assert
        $response->assertStatus(201)
            ->assertJsonStructure([
                'data' => [
                    'id',
                    'invoice_number',
                    'total',
                    'items',
                ]
            ]);
        
        $this->assertDatabaseHas('invoices', [
            'user_id' => $user->id,
        ]);
        
        $this->assertDatabaseHas('inventory', [
            'product_id' => $product->id,
            'quantity' => 95, // 100 - 5
        ]);
    }
}
```

### 🚨 Error Handling

```php
// Custom Exceptions
class InsufficientStockException extends Exception
{
    public function __construct(string $message = "Insufficient stock")
    {
        parent::__construct($message, 422);
    }
}

class PriceNotFoundException extends Exception
{
    public function __construct(string $message = "Price not found")
    {
        parent::__construct($message, 404);
    }
}

// Exception Handler
public function render($request, Throwable $exception)
{
    if ($exception instanceof InsufficientStockException) {
        return response()->json([
            'message' => $exception->getMessage(),
            'error' => 'insufficient_stock',
        ], 422);
    }
    
    if ($exception instanceof ValidationException) {
        return response()->json([
            'message' => 'Validation failed',
            'errors' => $exception->errors(),
        ], 422);
    }
    
    return parent::render($request, $exception);
}
```

---

## 8. API Design Principles

### 🌐 RESTful API Structure

```
Base URL: https://api.example.com/api/v1

Resources:
GET    /products              - List all products
GET    /products/{id}         - Get single product
POST   /products              - Create product
PUT    /products/{id}         - Update product
DELETE /products/{id}         - Delete product

GET    /invoices              - List invoices
GET    /invoices/{id}         - Get invoice
POST   /invoices              - Create invoice
GET    /invoices/{id}/items   - Get invoice items

GET    /inventory             - List inventory
GET    /inventory/{id}        - Get inventory item
POST   /inventory/adjust      - Adjust inventory

GET    /reports/sales         - Sales report
GET    /reports/profit        - Profit report
GET    /reports/inventory     - Inventory report
```

### 📦 Response Format

```php
// Success Response
{
    "success": true,
    "data": {
        "id": 1,
        "invoice_number": "INV-20240115-0001",
        "total": 150.00,
        "status": "completed"
    },
    "message": "Invoice created successfully",
    "meta": {
        "timestamp": "2024-01-15T10:30:00Z",
        "version": "1.0"
    }
}

// Error Response
{
    "success": false,
    "message": "Validation failed",
    "errors": {
        "product_id": ["The product field is required"],
        "quantity": ["The quantity must be at least 0.01"]
    },
    "meta": {
        "timestamp": "2024-01-15T10:30:00Z"
    }
}

// Pagination Response
{
    "success": true,
    "data": [...],
    "meta": {
        "current_page": 1,
        "from": 1,
        "last_page": 10,
        "per_page": 15,
        "to": 15,
        "total": 150
    },
    "links": {
        "first": "https://api.example.com/api/v1/invoices?page=1",
        "last": "https://api.example.com/api/v1/invoices?page=10",
        "prev": null,
        "next": "https://api.example.com/api/v1/invoices?page=2"
    }
}
```

### 🔢 HTTP Status Codes

```php
// Success
200 OK              - Successful GET, PUT, PATCH
201 Created         - Successful POST
204 No Content      - Successful DELETE

// Client Errors
400 Bad Request     - Invalid request format
401 Unauthorized    - Authentication required
403 Forbidden       - Authenticated but not authorized
404 Not Found       - Resource not found
422 Unprocessable   - Validation error

// Server Errors
500 Internal Error  - Server error
503 Service Unavailable - Maintenance mode
```

### 🎯 API Controller Example

```php
class InvoiceController extends Controller
{
    public function __construct(
        private InvoiceService $invoiceService
    ) {}
    
    /**
     * Display a listing of invoices
     */
    public function index(Request $request): JsonResponse
    {
        $invoices = Invoice::with(['customer:id,name', 'user:id,name'])
            ->when($request->status, fn($q) => $q->where('status', $request->status))
            ->when($request->from_date, fn($q) => $q->whereDate('created_at', '>=', $request->from_date))
            ->when($request->to_date, fn($q) => $q->whereDate('created_at', '<=', $request->to_date))
            ->latest()
            ->paginate(15);
        
        return response()->json([
            'success' => true,
            'data' => InvoiceResource::collection($invoices),
            'meta' => [
                'current_page' => $invoices->currentPage(),
                'total' => $invoices->total(),
                'per_page' => $invoices->perPage(),
            ]
        ]);
    }
    
    /**
     * Store a newly created invoice
     */
    public function store(StoreInvoiceRequest $request): JsonResponse
    {
        try {
            $invoice = $this->invoiceService->processSale($request->validated());
            
            return response()->json([
                'success' => true,
                'data' => new InvoiceResource($invoice),
                'message' => 'Invoice created successfully',
            ], 201);
            
        } catch (InsufficientStockException $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
                'error' => 'insufficient_stock',
            ], 422);
        }
    }
    
    /**
     * Display the specified invoice
     */
    public function show(int $id): JsonResponse
    {
        $invoice = Invoice::with([
            'customer',
            'user',
            'items.product',
            'payments.paymentMethod',
            'invoiceCost'
        ])->findOrFail($id);
        
        $this->authorize('view', $invoice);
        
        return response()->json([
            'success' => true,
            'data' => new InvoiceResource($invoice),
        ]);
    }
}
```

### 🔍 Filtering & Sorting

```php
// Query Parameters
GET /api/v1/products?category_id=1&price_tier=A&sort=-created_at&per_page=20

// Controller
public function index(Request $request): JsonResponse
{
    $products = Product::query()
        ->when($request->category_id, fn($q) => $q->where('category_id', $request->category_id))
        ->when($request->price_tier, fn($q) => $q->whereHas('priceTier', fn($q) => $q->where('name', $request->price_tier)))
        ->when($request->search, fn($q) => $q->where('name', 'like', "%{$request->search}%"))
        ->when($request->sort, function($q) use ($request) {
            $direction = str_starts_with($request->sort, '-') ? 'desc' : 'asc';
            $field = ltrim($request->sort, '-');
            return $q->orderBy($field, $direction);
        })
        ->paginate($request->per_page ?? 15);
    
    return response()->json([
        'success' => true,
        'data' => ProductResource::collection($products),
    ]);
}
```

---

## 9. Master Skill Summary

### 🎯 Project Context

**System:** Perfumes POS (Point of Sale)  
**Stack:** Laravel 10+ with MySQL 8+  
**Purpose:** Retail management for perfume shop with decant sales support

### 📊 Database Schema Overview

- **Total Tables:** 29
- **Cost Method:** Weighted Average
- **Audit Trail:** inventory_movements table
- **Special Features:** 
  - Batch tracking
  - Partial payments
  - Cost reversal on returns
  - Multi-tier pricing

### 🔑 Key Business Rules

1. **Product Types:**
   - DECANT_ONLY: Sold by ml/g only
   - FULL_ONLY: Sold as complete bottle
   - BOTH: Supports both methods
   - UNIT_BASED: Sold by piece/gram (incense/wax)

2. **Pricing:**
   - Central pricing via tier_prices (Tier + Size → Price)
   - Unit-based pricing for special products
   - Discount support at item and invoice level

3. **Inventory:**
   - All changes tracked in inventory_movements
   - Stock validation before sale
   - Low stock alerts via min_stock_level
   - Batch tracking for recalls

4. **Costs:**
   - Product cost from purchases (weighted average)
   - Material cost from recipes
   - Cost snapshot at sale time
   - Cost reversal on returns

5. **Returns:**
   - Support for partial returns
   - Restock fee capability
   - Cost reversal tracking
   - Product-level return policy (is_returnable)

### 🏗️ Architecture Requirements

```
✅ Repository Pattern for data access
✅ Service Layer for business logic
✅ Event-Driven for side effects
✅ Transaction-Based for data integrity
✅ Policy-Based authorization
✅ API-First design (RESTful)
```

### 🔒 Security Checklist

```
✅ Role-based access control (Admin, Manager, Seller, Warehouse)
✅ Audit all financial transactions
✅ Track user_id for all changes
✅ Validate stock before sale
✅ Server-side price calculation (prevent manipulation)
✅ Input validation and sanitization
✅ SQL injection prevention (Eloquent ORM)
✅ XSS protection (Blade escaping)
✅ CSRF protection
✅ API rate limiting
```

### ⚡ Performance Checklist

```
✅ Eager loading to prevent N+1 queries
✅ Index all foreign keys
✅ Cache frequently accessed data (prices, products)
✅ Paginate large lists
✅ Use database transactions
✅ Select only needed columns
✅ Chunk large datasets
✅ Use Redis for caching
```

### 📝 Code Quality Checklist

```
✅ PSR-12 coding standard
✅ SOLID principles
✅ Type hints everywhere
✅ Meaningful variable names
✅ Small, focused functions
✅ DRY (Don't Repeat Yourself)
✅ Comprehensive tests (Unit + Feature)
✅ Clear documentation
✅ Proper error handling
✅ Logging for debugging
```

### 🚀 Development Workflow

```
1. Read requirements from steps_v2 folder
2. Apply all skills from this document
3. Create migrations (database schema)
4. Create models with relationships
5. Create repositories (data access)
6. Create services (business logic)
7. Create controllers (HTTP handling)
8. Create form requests (validation)
9. Create resources (API responses)
10. Create policies (authorization)
11. Write tests (unit + feature)
12. Document API endpoints
```

### 📚 Key Files Structure

```
app/
├── Http/
│   ├── Controllers/
│   │   ├── InvoiceController.php
│   │   ├── ProductController.php
│   │   ├── InventoryController.php
│   │   └── ReturnController.php
│   ├── Requests/
│   │   ├── StoreInvoiceRequest.php
│   │   └── StoreProductRequest.php
│   ├── Resources/
│   │   ├── InvoiceResource.php
│   │   └── ProductResource.php
│   └── Middleware/
│       └── CheckRole.php
├── Services/
│   ├── InvoiceService.php
│   ├── InventoryService.php
│   ├── PricingService.php
│   ├── CostCalculationService.php
│   └── ReturnService.php
├── Repositories/
│   ├── InvoiceRepository.php
│   ├── ProductRepository.php
│   └── InventoryRepository.php
├── Models/
│   ├── Invoice.php
│   ├── InvoiceItem.php
│   ├── Product.php
│   ├── Inventory.php
│   └── InventoryMovement.php
├── Policies/
│   ├── InvoicePolicy.php
│   └── ProductPolicy.php
└── Exceptions/
    ├── InsufficientStockException.php
    └── PriceNotFoundException.php
```

### 🎯 Critical Implementation Notes

1. **Always use database transactions** for multi-step operations
2. **Never trust client-provided prices** - calculate server-side
3. **Lock inventory rows** during stock updates (lockForUpdate)
4. **Record all inventory movements** for audit trail
5. **Snapshot costs at sale time** for accurate profit calculation
6. **Validate stock availability** before creating invoice
7. **Use eager loading** to prevent N+1 queries
8. **Cache tier prices** for performance
9. **Log all financial operations** for debugging
10. **Test edge cases** thoroughly

---

## 🎓 Usage Instructions

When starting the project, provide this entire SKILLS.md file to the AI along with the steps_v2 folder, then say:

```
"Build a Perfumes POS System using Laravel 10+ and MySQL 8+.

Apply ALL skills from SKILLS.md:
- Laravel Best Practices
- MySQL Database Design
- POS Architecture
- Security Best Practices
- Performance Optimization
- Business Logic (POS Specific)
- Code Quality Standards
- API Design Principles

Use the database schema from steps_v2 folder as the foundation.

Start by creating the project structure, then implement each module following the patterns and principles defined in the skills document."
```

---

## 📖 Additional Resources

- Laravel Documentation: https://laravel.com/docs
- PSR-12 Standard: https://www.php-fig.org/psr/psr-12/
- SOLID Principles: https://en.wikipedia.org/wiki/SOLID
- RESTful API Design: https://restfulapi.net/
- MySQL Performance: https://dev.mysql.com/doc/refman/8.0/en/optimization.html

---

**Version:** 1.0  
**Last Updated:** 2024-01-15  
**Maintained By:** Perfumes POS Development Team

---

## ✅ Checklist Before Starting Development

- [ ] Read entire SKILLS.md document
- [ ] Review steps_v2 database schema
- [ ] Understand business rules
- [ ] Set up Laravel 10+ project
- [ ] Configure MySQL 8+ database
- [ ] Install required packages (Sanctum, etc.)
- [ ] Set up testing environment
- [ ] Configure code quality tools (PHPStan, PHP CS Fixer)
- [ ] Set up Git repository
- [ ] Create development branch
- [ ] Start implementing following the skills!

---

**🚀 Ready to build an amazing POS system! Good luck!**
