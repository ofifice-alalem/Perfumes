<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ProductImageResource extends JsonResource
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
            'product_id' => $this->product_id,
            'image_path' => $this->image_path,
            'image_url' => asset('storage/' . $this->image_path),
            'is_primary' => $this->is_primary,
            'order_num' => $this->order_num,
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }
}
