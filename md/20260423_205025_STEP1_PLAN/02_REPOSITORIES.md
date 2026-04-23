# 02 - Repositories

## 🎯 المطلوب: 5 Repositories + Interfaces

1. UnitRepository
2. CategoryRepository
3. ProductRepository
4. InventoryRepository
5. ProductImageRepository

---

## 📋 الهيكل

```
app/
├── Repositories/
│   ├── Contracts/
│   │   ├── UnitRepositoryInterface.php
│   │   ├── CategoryRepositoryInterface.php
│   │   ├── ProductRepositoryInterface.php
│   │   ├── InventoryRepositoryInterface.php
│   │   └── ProductImageRepositoryInterface.php
│   ├── UnitRepository.php
│   ├── CategoryRepository.php
│   ├── ProductRepository.php
│   ├── InventoryRepository.php
│   └── ProductImageRepository.php
```

---

## 📝 التفاصيل

### 1. UnitRepositoryInterface

**الملف:** `app/Repositories/Contracts/UnitRepositoryInterface.php`

```php
<?php

namespace App\Repositories\Contracts;

use App\Models\Unit;
use Illuminate\Support\Collection;

interface UnitRepositoryInterface
{
    public function all(): Collection;
    public function find(int $id): ?Unit;
    public function findBySymbol(string $symbol): ?Unit;
    public function create(array $data): Unit;
    public function update(int $id, array $data): bool;
    public function delete(int $id): bool;
}
```

### UnitRepository

**الملف:** `app/Repositories/UnitRepository.php`

```php
<?php

namespace App\Repositories;

use App\Models\Unit;
use App\Repositories\Contracts\UnitRepositoryInterface;
use Illuminate\Support\Collection;

class UnitRepository implements UnitRepositoryInterface
{
    public function all(): Collection
    {
        return Unit::all();
    }

    public function find(int $id): ?Unit
    {
        return Unit::find($id);
    }

    public function findBySymbol(string $symbol): ?Unit
    {
        return Unit::where('symbol', $symbol)->first();
    }

    public function create(array $data): Unit
    {
        return Unit::create($data);
    }

    public function update(int $id, array $data): bool
    {
        return Unit::where('id', $id)->update($data);
    }

    public function delete(int $id): bool
    {
        return Unit::destroy($id) > 0;
    }
}
```

---

### 2. CategoryRepositoryInterface

**الملف:** `app/Repositories/Contracts/CategoryRepositoryInterface.php`

```php
<?php

namespace App\Repositories\Contracts;

use App\Models\Category;
use Illuminate\Support\Collection;

interface CategoryRepositoryInterface
{
    public function all(): Collection;
    public function find(int $id): ?Category;
    public function create(array $data): Category;
    public function update(int $id, array $data): bool;
    public function delete(int $id): bool;
    public function getWithUnit(): Collection;
    public function getByUnit(int $unitId): Collection;
}
```

### CategoryRepository

**الملف:** `app/Repositories/CategoryRepository.php`

```php
<?php

namespace App\Repositories;

use App\Models\Category;
use App\Repositories\Contracts\CategoryRepositoryInterface;
use Illuminate\Support\Collection;

class CategoryRepository implements CategoryRepositoryInterface
{
    public function all(): Collection
    {
        return Category::all();
    }

    public function find(int $id): ?Category
    {
        return Category::with('unit')->find($id);
    }

    public function create(array $data): Category
    {
        return Category::create($data);
    }

    public function update(int $id, array $data): bool
    {
        return Category::where('id', $id)->update($data);
    }

    public function delete(int $id): bool
    {
        return Category::destroy($id) > 0;
    }

    public function getWithUnit(): Collection
    {
        return Category::with('unit')->get();
    }

    public function getByUnit(int $unitId): Collection
    {
        return Category::where('unit_id', $unitId)->get();
    }
}
```

---

### 3. ProductRepositoryInterface

**الملف:** `app/Repositories/Contracts/ProductRepositoryInterface.php`

```php
<?php

namespace App\Repositories\Contracts;

use App\Models\Product;
use Illuminate\Support\Collection;
use Illuminate\Pagination\LengthAwarePaginator;

interface ProductRepositoryInterface
{
    public function all(): Collection;
    public function paginate(int $perPage = 15): LengthAwarePaginator;
    public function find(int $id): ?Product;
    public function findBySku(string $sku): ?Product;
    public function create(array $data): Product;
    public function update(int $id, array $data): bool;
    public function delete(int $id): bool;
    public function getByCategory(int $categoryId): Collection;
    public function getLowStock(): Collection;
    public function search(string $query): Collection;
    public function getReturnable(): Collection;
    public function getBySellingType(string $type): Collection;
}
```

### ProductRepository

**الملف:** `app/Repositories/ProductRepository.php`

```php
<?php

namespace App\Repositories;

use App\Models\Product;
use App\Repositories\Contracts\ProductRepositoryInterface;
use Illuminate\Support\Collection;
use Illuminate\Pagination\LengthAwarePaginator;

class ProductRepository implements ProductRepositoryInterface
{
    public function all(): Collection
    {
        return Product::with(['category', 'inventory', 'images'])->get();
    }

    public function paginate(int $perPage = 15): LengthAwarePaginator
    {
        return Product::with(['category', 'inventory', 'images'])
            ->latest()
            ->paginate($perPage);
    }

    public function find(int $id): ?Product
    {
        return Product::with(['category', 'inventory', 'images'])->find($id);
    }

    public function findBySku(string $sku): ?Product
    {
        return Product::where('sku', $sku)->first();
    }

    public function create(array $data): Product
    {
        return Product::create($data);
    }

    public function update(int $id, array $data): bool
    {
        return Product::where('id', $id)->update($data);
    }

    public function delete(int $id): bool
    {
        return Product::destroy($id) > 0;
    }

    public function getByCategory(int $categoryId): Collection
    {
        return Product::where('category_id', $categoryId)
            ->with(['inventory', 'images'])
            ->get();
    }

    public function getLowStock(): Collection
    {
        return Product::lowStock()
            ->with(['category', 'inventory'])
            ->get();
    }

    public function search(string $query): Collection
    {
        return Product::where('name', 'like', "%{$query}%")
            ->orWhere('sku', 'like', "%{$query}%")
            ->with(['category', 'inventory', 'images'])
            ->get();
    }

    public function getReturnable(): Collection
    {
        return Product::returnable()->get();
    }

    public function getBySellingType(string $type): Collection
    {
        return Product::bySellingType($type)->get();
    }
}
```

---

### 4. InventoryRepositoryInterface

**الملف:** `app/Repositories/Contracts/InventoryRepositoryInterface.php`

```php
<?php

namespace App\Repositories\Contracts;

use App\Models\Inventory;
use Illuminate\Support\Collection;

interface InventoryRepositoryInterface
{
    public function all(): Collection;
    public function find(int $id): ?Inventory;
    public function findByProduct(int $productId): ?Inventory;
    public function create(array $data): Inventory;
    public function update(int $id, array $data): bool;
    public function updateQuantity(int $productId, float $quantity): bool;
    public function getLowStock(): Collection;
    public function getOutOfStock(): Collection;
}
```

### InventoryRepository

**الملف:** `app/Repositories/InventoryRepository.php`

```php
<?php

namespace App\Repositories;

use App\Models\Inventory;
use App\Repositories\Contracts\InventoryRepositoryInterface;
use Illuminate\Support\Collection;

class InventoryRepository implements InventoryRepositoryInterface
{
    public function all(): Collection
    {
        return Inventory::with(['product', 'unit'])->get();
    }

    public function find(int $id): ?Inventory
    {
        return Inventory::with(['product', 'unit'])->find($id);
    }

    public function findByProduct(int $productId): ?Inventory
    {
        return Inventory::where('product_id', $productId)
            ->with(['product', 'unit'])
            ->first();
    }

    public function create(array $data): Inventory
    {
        return Inventory::create($data);
    }

    public function update(int $id, array $data): bool
    {
        return Inventory::where('id', $id)->update($data);
    }

    public function updateQuantity(int $productId, float $quantity): bool
    {
        return Inventory::where('product_id', $productId)
            ->update(['quantity' => $quantity]);
    }

    public function getLowStock(): Collection
    {
        return Inventory::whereRaw('quantity <= min_stock_level')
            ->with(['product', 'unit'])
            ->get();
    }

    public function getOutOfStock(): Collection
    {
        return Inventory::where('quantity', '<=', 0)
            ->with(['product', 'unit'])
            ->get();
    }
}
```

---

### 5. ProductImageRepositoryInterface

**الملف:** `app/Repositories/Contracts/ProductImageRepositoryInterface.php`

```php
<?php

namespace App\Repositories\Contracts;

use App\Models\ProductImage;
use Illuminate\Support\Collection;

interface ProductImageRepositoryInterface
{
    public function find(int $id): ?ProductImage;
    public function getByProduct(int $productId): Collection;
    public function create(array $data): ProductImage;
    public function update(int $id, array $data): bool;
    public function delete(int $id): bool;
    public function setPrimary(int $productId, int $imageId): bool;
}
```

### ProductImageRepository

**الملف:** `app/Repositories/ProductImageRepository.php`

```php
<?php

namespace App\Repositories;

use App\Models\ProductImage;
use App\Repositories\Contracts\ProductImageRepositoryInterface;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;

class ProductImageRepository implements ProductImageRepositoryInterface
{
    public function find(int $id): ?ProductImage
    {
        return ProductImage::find($id);
    }

    public function getByProduct(int $productId): Collection
    {
        return ProductImage::where('product_id', $productId)
            ->ordered()
            ->get();
    }

    public function create(array $data): ProductImage
    {
        return ProductImage::create($data);
    }

    public function update(int $id, array $data): bool
    {
        return ProductImage::where('id', $id)->update($data);
    }

    public function delete(int $id): bool
    {
        $image = ProductImage::find($id);
        if ($image && file_exists(public_path($image->image_path))) {
            unlink(public_path($image->image_path));
        }
        return ProductImage::destroy($id) > 0;
    }

    public function setPrimary(int $productId, int $imageId): bool
    {
        return DB::transaction(function () use ($productId, $imageId) {
            // Remove primary from all images
            ProductImage::where('product_id', $productId)
                ->update(['is_primary' => false]);
            
            // Set new primary
            return ProductImage::where('id', $imageId)
                ->where('product_id', $productId)
                ->update(['is_primary' => true]);
        });
    }
}
```

---

## 🔧 Service Provider Binding

**الملف:** `app/Providers/RepositoryServiceProvider.php`

```php
<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;

class RepositoryServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        $this->app->bind(
            \App\Repositories\Contracts\UnitRepositoryInterface::class,
            \App\Repositories\UnitRepository::class
        );

        $this->app->bind(
            \App\Repositories\Contracts\CategoryRepositoryInterface::class,
            \App\Repositories\CategoryRepository::class
        );

        $this->app->bind(
            \App\Repositories\Contracts\ProductRepositoryInterface::class,
            \App\Repositories\ProductRepository::class
        );

        $this->app->bind(
            \App\Repositories\Contracts\InventoryRepositoryInterface::class,
            \App\Repositories\InventoryRepository::class
        );

        $this->app->bind(
            \App\Repositories\Contracts\ProductImageRepositoryInterface::class,
            \App\Repositories\ProductImageRepository::class
        );
    }
}
```

**تسجيل في:** `config/app.php`

```php
'providers' => [
    // ...
    App\Providers\RepositoryServiceProvider::class,
],
```

---

## ✅ Checklist

- [ ] إنشاء مجلد Repositories
- [ ] إنشاء مجلد Contracts
- [ ] 5 Interfaces
- [ ] 5 Repositories
- [ ] RepositoryServiceProvider
- [ ] تسجيل في config/app.php

---

**الحالة:** 📝 جاهز للتنفيذ  
**التالي:** Services
