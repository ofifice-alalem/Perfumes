<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreCategoryRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => 'required|string|max:255',
            'unit_id' => 'required|exists:units,id',
        ];
    }

    public function messages(): array
    {
        return [
            'name.required' => 'اسم التصنيف مطلوب',
            'unit_id.required' => 'وحدة القياس مطلوبة',
            'unit_id.exists' => 'وحدة القياس المحددة غير موجودة',
        ];
    }
}
