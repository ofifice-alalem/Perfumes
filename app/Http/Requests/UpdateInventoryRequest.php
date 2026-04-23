<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class UpdateInventoryRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'quantity' => 'nullable|numeric|min:0',
            'min_stock_level' => 'nullable|numeric|min:0',
            'unit_id' => 'nullable|exists:units,id',
        ];
    }
}
