# 03 - Services

## 🎯 المطلوب: 2 Services

1. ProductService
2. InventoryService

---

## 📋 الهيكل

```
app/
├── Services/
│   ├── ProductService.php
│   └── InventoryService.php
```

---

## 📝 التفاصيل

### 1. ProductService

**الملف:** `app/Services/ProductService.php`

```php
<?php

namespace App\Services;

use App\Models\Product;
use App\Repositories\Contracts\ProductRepositoryInterface;
use App\Repositories\Contracts\InventoryRepositoryInterface;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;

class ProductService
{
    public function __construct(
        private ProductRepositoryInterface $productRepo,
        private InventoryRepositoryInterface $inventoryRepo
    ) {}

    /**
     * إنشاء منتج جديد مع المخزون
     */
    public function createProduct(array $data): Product
    {
        return DB::transaction(function () use ($data) {
            // إنشاء المنتج
            $product = $this->productRepo->create([
                'name' => $data['name'],
                'sku' => $data['sku'] ?? $this->generateSku(),
                'category_id' => $data['category_id'],
                'price_tier_id' => $data['price_tier_id'],
                'selling_type' => $data['selling_type'],
                'is_returnable' => $data['is_returnable'] ?? true,
            ]);

            // إنشاء المخزون
            if (isset($data['inventory'])) {
                $this->inventoryRepo->create([
                    'product_id' => $product->id,
                    'quantity' => $data['inventory']['quantity'] ?? 0,
                    'min_stock_level' => $data['inventory']['min_stock_level'] ?? 0,
                    'unit_id' => $data['inventory']['unit_id'],
                ]);
            }

            return $product->fresh(['category', 'inventory', 'images']);
        });
    }

    /**
     * تحديث منتج
     */
    public function updateProduct(int $id, array $data): Product
    {
        return DB::transaction(function () use ($id, $data) {
            // تحديث المنتج
            $this->productRepo->update($id, [
                'name' => $data['name'],
                'sku' => $data['sku'],
                'category_id' => $data['category_id'],
                'price_tier_id' => $data['price_tier_id'],
                'selling_type' => $data['selling_type'],
                'is_returnable' => $data['is_returnable'] ?? true,
            ]);

            // تحديث المخزون إذا وجد
            if (isset($data['inventory'])) {
                $inventory = $this->inventoryRepo->findByProduct($id);
                if ($inventory) {
                    $this->inventoryRepo->update($inventory->id, [
                        'min_stock_level' => $data['inventory']['min_stock_level'],
                        'unit_id' => $data['inventory']['unit_id'],
                    ]);
                }
            }

            return $this->productRepo->find($id);
        });
    }

    /**
     * حذف منتج
     */
    public function deleteProduct(int $id): bool
    {
        return DB::transaction(function () use ($id) {
            // حذف المخزون
            $inventory = $this->inventoryRepo->findByProduct($id);
            if ($inventory) {
                $this->inventoryRepo->update($inventory->id, ['quantity' => 0]);
            }

            // حذف المنتج
            return $this->productRepo->delete($id);
        });
    }

    /**
     * الحصول على منتج مع جميع العلاقات
     */
    public function getProductWithInventory(int $id): ?Product
    {
        return $this->productRepo->find($id);
    }

    /**
     * الحصول على المنتجات منخفضة المخزون
     */
    public function getLowStockProducts(): Collection
    {
        return $this->productRepo->getLowStock();
    }

    /**
     * البحث عن منتجات
     */
    public function searchProducts(string $query): Collection
    {
        return $this->productRepo->search($query);
    }

    /**
     * توليد SKU تلقائي
     */
    private function generateSku(): string
    {
        $prefix = 'PRD';
        $timestamp = now()->format('ymd');
        $random = strtoupper(substr(md5(uniqid()), 0, 4));
        
        return "{$prefix}-{$timestamp}-{$random}";
    }

    /**
     * الحصول على المنتجات حسب الفئة
     */
    public function getProductsByCategory(int $categoryId): Collection
    {
        return $this->productRepo->getByCategory($categoryId);
    }

    /**
     * الحصول على المنتجات القابلة للإرجاع
     */
    public function getReturnableProducts(): Collection
    {
        return $this->productRepo->getReturnable();
    }
}
```

---

### 2. InventoryService

**الملف:** `app/Services/InventoryService.php`

```php
<?php

namespace App\Services;

use App\Models\Inventory;
use App\Repositories\Contracts\InventoryRepositoryInterface;
use App\Exceptions\InsufficientStockException;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;

class InventoryService
{
    public function __construct(
        private InventoryRepositoryInterface $inventoryRepo
    ) {}

    /**
     * الحصول على مخزون منتج
     */
    public function getInventory(int $productId): ?Inventory
    {
        return $this->inventoryRepo->findByProduct($productId);
    }

    /**
     * تحديث كمية المخزون
     */
    public function updateQuantity(int $productId, float $quantity): Inventory
    {
        $this->inventoryRepo->updateQuantity($productId, $quantity);
        return $this->inventoryRepo->findByProduct($productId);
    }

    /**
     * إضافة كمية للمخزون
     */
    public function addStock(
        int $productId,
        float $quantity,
        ?string $referenceType = null,
        ?int $referenceId = null,
        ?string $notes = null
    ): void {
        $inventory = $this->inventoryRepo->findByProduct($productId);
        
        if (!$inventory) {
            throw new \Exception("Inventory not found for product {$productId}");
        }

        DB::transaction(function () use ($inventory, $quantity, $referenceType, $referenceId, $notes) {
            $quantityBefore = $inventory->quantity;
            $quantityAfter = $quantityBefore + $quantity;

            // تحديث المخزون
            $this->inventoryRepo->updateQuantity($inventory->product_id, $quantityAfter);

            // تسجيل الحركة (سيتم في Step 5)
            // InventoryMovement::create([...]);
        });
    }

    /**
     * خصم كمية من المخزون
     */
    public function deductStock(
        int $productId,
        float $quantity,
        ?string $referenceType = null,
        ?int $referenceId = null,
        ?string $notes = null
    ): void {
        $inventory = $this->inventoryRepo->findByProduct($productId);
        
        if (!$inventory) {
            throw new \Exception("Inventory not found for product {$productId}");
        }

        if ($inventory->quantity < $quantity) {
            throw new InsufficientStockException(
                "Insufficient stock for product {$productId}. Available: {$inventory->quantity}, Required: {$quantity}"
            );
        }

        DB::transaction(function () use ($inventory, $quantity, $referenceType, $referenceId, $notes) {
            $quantityBefore = $inventory->quantity;
            $quantityAfter = $quantityBefore - $quantity;

            // تحديث المخزون
            $this->inventoryRepo->updateQuantity($inventory->product_id, $quantityAfter);

            // تسجيل الحركة (سيتم في Step 5)
            // InventoryMovement::create([...]);
        });
    }

    /**
     * فحص المخزون المنخفض
     */
    public function checkLowStock(): Collection
    {
        return $this->inventoryRepo->getLowStock();
    }

    /**
     * الحصول على حالة المخزون
     */
    public function getStockStatus(int $productId): string
    {
        $inventory = $this->inventoryRepo->findByProduct($productId);
        
        if (!$inventory) {
            return 'unknown';
        }

        return $inventory->stock_status;
    }

    /**
     * الحصول على المنتجات النافدة
     */
    public function getOutOfStock(): Collection
    {
        return $this->inventoryRepo->getOutOfStock();
    }

    /**
     * التحقق من توفر الكمية
     */
    public function isAvailable(int $productId, float $quantity): bool
    {
        $inventory = $this->inventoryRepo->findByProduct($productId);
        
        if (!$inventory) {
            return false;
        }

        return $inventory->quantity >= $quantity;
    }

    /**
     * الحصول على الكمية المتاحة
     */
    public function getAvailableQuantity(int $productId): float
    {
        $inventory = $this->inventoryRepo->findByProduct($productId);
        
        return $inventory?->quantity ?? 0;
    }
}
```

---

## 🚨 Exception

**الملف:** `app/Exceptions/InsufficientStockException.php`

```php
<?php

namespace App\Exceptions;

use Exception;

class InsufficientStockException extends Exception
{
    public function __construct(string $message = "Insufficient stock")
    {
        parent::__construct($message, 422);
    }

    public function render()
    {
        return response()->json([
            'success' => false,
            'message' => $this->getMessage(),
            'error' => 'insufficient_stock',
        ], 422);
    }
}
```

---

## ✅ Checklist

- [ ] ProductService مع جميع الوظائف
- [ ] InventoryService مع جميع الوظائف
- [ ] InsufficientStockException
- [ ] Type Hints في كل مكان
- [ ] DB Transactions للعمليات المعقدة

---

**الحالة:** 📝 جاهز للتنفيذ  
**التالي:** Requests (Validation)
