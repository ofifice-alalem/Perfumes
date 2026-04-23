<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Builder;

class ProductImage extends Model
{
    public $timestamps = false;
    
    protected $fillable = [
        'product_id',
        'image_path',
        'is_primary',
        'order_num',
    ];

    protected $casts = [
        'is_primary' => 'boolean',
        'order_num' => 'integer',
        'created_at' => 'datetime',
    ];

    // Relationships
    public function product(): BelongsTo
    {
        return $this->belongsTo(Product::class);
    }

    // Scopes
    public function scopePrimary(Builder $query): Builder
    {
        return $query->where('is_primary', true);
    }

    public function scopeOrdered(Builder $query): Builder
    {
        return $query->orderBy('order_num');
    }
}
