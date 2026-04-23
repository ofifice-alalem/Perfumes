<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateProductRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        $productId = $this->route('product');
        
        return [
            'name' => 'required|string|max:255',
            'sku' => [
                'nullable',
                'string',
                'max:50',
                Rule::unique('products', 'sku')->ignore($productId)
            ],
            'category_id' => 'required|exists:categories,id',
            'price_tier_id' => 'required|exists:price_tiers,id',
            'selling_type' => 'required|in:DECANT_ONLY,FULL_ONLY,BOTH,UNIT_BASED',
            'is_returnable' => 'boolean',
            'inventory' => 'nullable|array',
            'inventory.min_stock_level' => 'nullable|numeric|min:0',
            'inventory.unit_id' => 'required_with:inventory|exists:units,id',
        ];
    }
}
