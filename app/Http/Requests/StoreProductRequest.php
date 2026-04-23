<?php

namespace App\Http\Requests;

use Illuminate\Contracts\Validation\ValidationRule;
use Illuminate\Foundation\Http\FormRequest;

class StoreProductRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'name' => 'required|string|max:255',
            'sku' => 'nullable|string|max:50|unique:products,sku',
            'category_id' => 'required|exists:categories,id',
            'price_tier_id' => 'required|exists:price_tiers,id',
            'selling_type' => 'required|in:DECANT_ONLY,FULL_ONLY,BOTH,UNIT_BASED',
            'is_returnable' => 'boolean',
            'inventory' => 'nullable|array',
            'inventory.quantity' => 'required_with:inventory|numeric|min:0',
            'inventory.min_stock_level' => 'nullable|numeric|min:0',
            'inventory.unit_id' => 'required_with:inventory|exists:units,id',
        ];
    }

    /**
     * Get custom messages for validator errors.
     */
    public function messages(): array
    {
        return [
            'name.required' => 'اسم المنتج مطلوب',
            'category_id.required' => 'التصنيف مطلوب',
            'category_id.exists' => 'التصنيف المحدد غير موجود',
            'price_tier_id.required' => 'مستوى السعر مطلوب',
            'selling_type.required' => 'نوع البيع مطلوب',
            'selling_type.in' => 'نوع البيع غير صحيح',
        ];
    }
}
