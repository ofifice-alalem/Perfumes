# 04-13 - الملفات المتبقية (مرجع سريع)

## 04 - Requests (6 Files)

```
app/Http/Requests/
├── StoreProductRequest.php
├── UpdateProductRequest.php
├── StoreCategoryRequest.php
├── UpdateCategoryRequest.php
├── StoreInventoryRequest.php
└── UpdateInventoryRequest.php
```

**مثال:**
```php
class StoreProductRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'name' => 'required|string|max:255',
            'sku' => 'nullable|string|max:50|unique:products,sku',
            'category_id' => 'required|exists:categories,id',
            'price_tier_id' => 'required|exists:price_tiers,id',
            'selling_type' => 'required|in:DECANT_ONLY,FULL_ONLY,BOTH,UNIT_BASED',
            'is_returnable' => 'boolean',
        ];
    }
}
```

---

## 05 - Resources (5 Files)

```
app/Http/Resources/
├── UnitResource.php
├── CategoryResource.php
├── ProductResource.php
├── InventoryResource.php
└── ProductImageResource.php
```

**مثال:**
```php
class ProductResource extends JsonResource
{
    public function toArray($request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'sku' => $this->sku,
            'selling_type' => $this->selling_type,
            'is_returnable' => $this->is_returnable,
            'category' => new CategoryResource($this->whenLoaded('category')),
            'inventory' => new InventoryResource($this->whenLoaded('inventory')),
            'images' => ProductImageResource::collection($this->whenLoaded('images')),
            'created_at' => $this->created_at->toIso8601String(),
        ];
    }
}
```

---

## 06 - Controllers (5 Files)

```
app/Http/Controllers/
├── UnitController.php
├── CategoryController.php
├── ProductController.php
├── InventoryController.php
└── ProductImageController.php
```

**مثال:**
```php
class ProductController extends Controller
{
    public function __construct(private ProductService $productService) {}

    public function index(): JsonResponse
    {
        $products = $this->productService->getAllProducts();
        return response()->json(ProductResource::collection($products));
    }

    public function store(StoreProductRequest $request): JsonResponse
    {
        $product = $this->productService->createProduct($request->validated());
        return response()->json(new ProductResource($product), 201);
    }
}
```

---

## 07 - Routes

**الملف:** `routes/api.php`

```php
Route::middleware('auth:sanctum')->group(function () {
    Route::apiResource('units', UnitController::class);
    Route::apiResource('categories', CategoryController::class);
    Route::apiResource('products', ProductController::class);
    Route::get('products/low-stock', [ProductController::class, 'lowStock']);
    Route::apiResource('inventory', InventoryController::class);
    Route::apiResource('product-images', ProductImageController::class);
});
```

---

## 08 - Policies (3 Files)

```
app/Policies/
├── ProductPolicy.php
├── CategoryPolicy.php
└── InventoryPolicy.php
```

**مثال:**
```php
class ProductPolicy
{
    public function viewAny(User $user): bool
    {
        return true;
    }

    public function create(User $user): bool
    {
        return $user->hasRole(['admin', 'manager']);
    }

    public function update(User $user, Product $product): bool
    {
        return $user->hasRole(['admin', 'manager']);
    }
}
```

---

## 09 - Seeders (4 Files)

```
database/seeders/
├── UnitSeeder.php
├── CategorySeeder.php
├── ProductSeeder.php
└── InventorySeeder.php
```

**مثال:**
```php
class UnitSeeder extends Seeder
{
    public function run(): void
    {
        Unit::create(['name' => 'Milliliter', 'symbol' => 'ml']);
        Unit::create(['name' => 'Gram', 'symbol' => 'g']);
        Unit::create(['name' => 'Piece', 'symbol' => 'pcs']);
    }
}
```

---

## 10 - Factories (4 Files)

```
database/factories/
├── UnitFactory.php
├── CategoryFactory.php
├── ProductFactory.php
└── InventoryFactory.php
```

**مثال:**
```php
class ProductFactory extends Factory
{
    public function definition(): array
    {
        return [
            'name' => $this->faker->words(3, true),
            'sku' => 'PRD-' . $this->faker->unique()->numerify('######'),
            'category_id' => Category::factory(),
            'price_tier_id' => 1,
            'selling_type' => $this->faker->randomElement(['DECANT_ONLY', 'FULL_ONLY', 'BOTH']),
            'is_returnable' => true,
        ];
    }
}
```

---

## 11 - Tests

```
tests/
├── Unit/
│   ├── ProductTest.php
│   ├── InventoryTest.php
│   └── CategoryTest.php
└── Feature/
    ├── ProductApiTest.php
    ├── InventoryApiTest.php
    └── CategoryApiTest.php
```

---

## 12 - Frontend Pages

```
resources/js/Pages/
├── Products/
│   ├── Index.tsx
│   ├── Create.tsx
│   ├── Edit.tsx
│   └── Show.tsx
├── Inventory/
│   └── Index.tsx
└── Categories/
    └── Index.tsx
```

---

## 13 - Frontend Components

```
resources/js/Components/
├── ProductCard.tsx
├── ProductForm.tsx
├── ProductTable.tsx
├── InventoryTable.tsx
└── StockBadge.tsx
```

---

## ✅ الأوامر السريعة

```bash
# Models
php artisan make:model Unit
php artisan make:model Category
php artisan make:model Product
php artisan make:model Inventory
php artisan make:model ProductImage

# Controllers
php artisan make:controller ProductController --api
php artisan make:controller CategoryController --api
php artisan make:controller InventoryController --api

# Requests
php artisan make:request StoreProductRequest
php artisan make:request UpdateProductRequest

# Resources
php artisan make:resource ProductResource
php artisan make:resource CategoryResource

# Policies
php artisan make:policy ProductPolicy --model=Product

# Seeders
php artisan make:seeder ProductSeeder

# Factories
php artisan make:factory ProductFactory --model=Product

# Tests
php artisan make:test ProductApiTest
```

---

**الحالة:** 📝 مرجع سريع جاهز
