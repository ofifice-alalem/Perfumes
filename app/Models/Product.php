<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Builder;

class Product extends Model
{
    protected $fillable = [
        'name',
        'sku',
        'category_id',
        'price_tier_id',
        'selling_type',
        'is_returnable',
    ];

    protected $casts = [
        'is_returnable' => 'boolean',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    // Relationships
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

    public function returnItems(): HasMany
    {
        return $this->hasMany(ReturnItem::class);
    }

    public function tierPrices(): HasMany
    {
        // tier_prices لا يحتوي على product_id، بل يرتبط عبر price_tier_id
        // سنستخدم hasManyThrough أو نجلبها يدوياً
        return $this->hasMany(TierPrice::class, 'tier_id', 'price_tier_id');
    }

    public function unitBasedPrices(): HasMany
    {
        return $this->hasMany(UnitBasedPrice::class);
    }

    // Scopes
    public function scopeActive(Builder $query): Builder
    {
        return $query->whereHas('inventory', function($q) {
            $q->where('quantity', '>', 0);
        });
    }

    public function scopeReturnable(Builder $query): Builder
    {
        return $query->where('is_returnable', true);
    }

    public function scopeBySellingType(Builder $query, string $type): Builder
    {
        return $query->where('selling_type', $type);
    }

    public function scopeLowStock(Builder $query): Builder
    {
        return $query->whereHas('inventory', function($q) {
            $q->whereRaw('quantity <= min_stock_level');
        });
    }

    // Accessors
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
}
