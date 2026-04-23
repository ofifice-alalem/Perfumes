# 01 - Models

## 🎯 المطلوب: 5 Models

1. Unit
2. Category
3. Product
4. Inventory
5. ProductImage

---

## 📋 التفاصيل الكاملة

### 1. Unit Model

**الملف:** `app/Models/Unit.php`

**الحقول:**
- id (bigint)
- name (string)
- symbol (string)
- timestamps

**Relationships:**
```php
public function categories(): HasMany
{
    return $this->hasMany(Category::class);
}

public function sizes(): HasMany
{
    return $this->hasMany(Size::class);
}

public function inventories(): HasMany
{
    return $this->hasMany(Inventory::class);
}
```

**Fillable:**
```php
protected $fillable = ['name', 'symbol'];
```

**Casts:**
```php
protected $casts = [
    'created_at' => 'datetime',
    'updated_at' => 'datetime',
];
```

---

### 2. Category Model

**الملف:** `app/Models/Category.php`

**الحقول:**
- id
- name
- unit_id
- timestamps

**Relationships:**
```php
public function unit(): BelongsTo
{
    return $this->belongsTo(Unit::class);
}

public function products(): HasMany
{
    return $this->hasMany(Product::class);
}
```

**Fillable:**
```php
protected $fillable = ['name', 'unit_id'];
```

**Casts:**
```php
protected $casts = [
    'created_at' => 'datetime',
    'updated_at' => 'datetime',
];
```

---

### 3. Product Model

**الملف:** `app/Models/Product.php`

**الحقول:**
- id
- name
- sku
- category_id
- price_tier_id
- selling_type (enum)
- is_returnable
- timestamps

**Relationships:**
```php
public function category(): BelongsTo
{
    return $this->belongsTo(Category::class);
}

public function priceTier(): BelongsTo
{
    return $this->belongsTo(PriceTier::class);
}

public function inventory(): HasOne
{
    return $this->hasOne(Inventory::class);
}

public function images(): HasMany
{
    return $this->hasMany(ProductImage::class);
}

public function invoiceItems(): HasMany
{
    return $this->hasMany(InvoiceItem::class);
}

public function purchases(): HasMany
{
    return $this->hasMany(Purchase::class);
}

public function recipes(): HasMany
{
    return $this->hasMany(Recipe::class);
}

public function discounts(): BelongsToMany
{
    return $this->belongsToMany(Discount::class, 'discount_products');
}
```

**Fillable:**
```php
protected $fillable = [
    'name',
    'sku',
    'category_id',
    'price_tier_id',
    'selling_type',
    'is_returnable',
];
```

**Casts:**
```php
protected $casts = [
    'is_returnable' => 'boolean',
    'created_at' => 'datetime',
    'updated_at' => 'datetime',
];
```

**Scopes:**
```php
public function scopeActive($query)
{
    return $query->whereHas('inventory', function($q) {
        $q->where('quantity', '>', 0);
    });
}

public function scopeReturnable($query)
{
    return $query->where('is_returnable', true);
}

public function scopeBySellingType($query, string $type)
{
    return $query->where('selling_type', $type);
}

public function scopeLowStock($query)
{
    return $query->whereHas('inventory', function($q) {
        $q->whereRaw('quantity <= min_stock_level');
    });
}
```

**Accessors:**
```php
public function getAvailableStockAttribute(): float
{
    return $this->inventory?->quantity ?? 0;
}

public function getIsLowStockAttribute(): bool
{
    if (!$this->inventory) {
        return false;
    }
    
    return $this->inventory->quantity <= $this->inventory->min_stock_level;
}

public function getPrimaryImageAttribute(): ?string
{
    return $this->images()->where('is_primary', true)->first()?->image_path;
}
```

---

### 4. Inventory Model

**الملف:** `app/Models/Inventory.php`

**الحقول:**
- id
- product_id
- quantity
- min_stock_level
- unit_id
- timestamps

**Relationships:**
```php
public function product(): BelongsTo
{
    return $this->belongsTo(Product::class);
}

public function unit(): BelongsTo
{
    return $this->belongsTo(Unit::class);
}

public function movements(): HasMany
{
    return $this->hasMany(InventoryMovement::class, 'product_id', 'product_id');
}
```

**Fillable:**
```php
protected $fillable = [
    'product_id',
    'quantity',
    'min_stock_level',
    'unit_id',
];
```

**Casts:**
```php
protected $casts = [
    'quantity' => 'decimal:2',
    'min_stock_level' => 'decimal:2',
    'created_at' => 'datetime',
    'updated_at' => 'datetime',
];
```

**Accessors:**
```php
public function getIsLowStockAttribute(): bool
{
    return $this->quantity <= $this->min_stock_level;
}

public function getStockStatusAttribute(): string
{
    if ($this->quantity <= 0) {
        return 'out_of_stock';
    }
    
    if ($this->is_low_stock) {
        return 'low_stock';
    }
    
    return 'in_stock';
}

public function getStockPercentageAttribute(): float
{
    if ($this->min_stock_level <= 0) {
        return 100;
    }
    
    return ($this->quantity / $this->min_stock_level) * 100;
}
```

---

### 5. ProductImage Model

**الملف:** `app/Models/ProductImage.php`

**الحقول:**
- id
- product_id
- image_path
- is_primary
- order_num
- created_at

**Relationships:**
```php
public function product(): BelongsTo
{
    return $this->belongsTo(Product::class);
}
```

**Fillable:**
```php
protected $fillable = [
    'product_id',
    'image_path',
    'is_primary',
    'order_num',
];
```

**Casts:**
```php
protected $casts = [
    'is_primary' => 'boolean',
    'order_num' => 'integer',
    'created_at' => 'datetime',
];
```

**Scopes:**
```php
public function scopePrimary($query)
{
    return $query->where('is_primary', true);
}

public function scopeOrdered($query)
{
    return $query->orderBy('order_num');
}
```

---

## 🎯 الأوامر

```bash
# إنشاء Models
php artisan make:model Unit
php artisan make:model Category
php artisan make:model Product
php artisan make:model Inventory
php artisan make:model ProductImage
```

---

## ✅ Checklist

- [ ] Unit Model مع Relationships
- [ ] Category Model مع Relationships
- [ ] Product Model مع Relationships + Scopes + Accessors
- [ ] Inventory Model مع Relationships + Accessors
- [ ] ProductImage Model مع Relationships + Scopes
- [ ] جميع Fillable محددة
- [ ] جميع Casts محددة
- [ ] Type Hints في كل مكان

---

**الحالة:** 📝 جاهز للتنفيذ  
**التالي:** Repositories
