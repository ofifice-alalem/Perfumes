<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Inventory extends Model
{
    protected $table = 'inventory';

    protected $fillable = [
        'product_id',
        'quantity',
        'min_stock_level',
        'unit_id',
    ];

    protected $casts = [
        'quantity' => 'decimal:2',
        'min_stock_level' => 'decimal:2',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    protected $appends = [
        'is_low_stock',
        'stock_status',
        'stock_percentage',
    ];

    // Relationships
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

    // Accessors
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
}
