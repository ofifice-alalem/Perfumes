<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreInventoryRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'product_id' => 'required|exists:products,id|unique:inventory,product_id',
            'quantity' => 'required|numeric|min:0',
            'min_stock_level' => 'nullable|numeric|min:0',
            'unit_id' => 'required|exists:units,id',
        ];
    }
}
