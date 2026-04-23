<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ProductResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'sku' => $this->sku,
            'category_id' => $this->category_id,
            'price_tier_id' => $this->price_tier_id,
            'selling_type' => $this->selling_type,
            'is_returnable' => $this->is_returnable,
            
            // Relationships
            'category' => new CategoryResource($this->whenLoaded('category')),
            'inventory' => new InventoryResource($this->whenLoaded('inventory')),
            'images' => ProductImageResource::collection($this->whenLoaded('images')),
            
            // Computed attributes
            'available_stock' => $this->when(
                $this->relationLoaded('inventory'),
                fn() => $this->available_stock
            ),
            'is_low_stock' => $this->when(
                $this->relationLoaded('inventory'),
                fn() => $this->is_low_stock
            ),
            'primary_image' => $this->when(
                $this->relationLoaded('images'),
                fn() => $this->primary_image ? asset('storage/' . $this->primary_image) : null
            ),
            
            'created_at' => $this->created_at?->toIso8601String(),
            'updated_at' => $this->updated_at?->toIso8601String(),
        ];
    }
}
