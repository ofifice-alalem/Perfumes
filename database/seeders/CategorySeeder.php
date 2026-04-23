<?php

namespace Database\Seeders;

use App\Models\Category;
use App\Models\Unit;
use Illuminate\Database\Seeder;

class CategorySeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $mlUnit = Unit::where('symbol', 'ml')->first();
        $gUnit = Unit::where('symbol', 'g')->first();
        $pcsUnit = Unit::where('symbol', 'pcs')->first();

        $categories = [
            [
                'name' => 'عطور رجالية',
                'unit_id' => $mlUnit->id,
            ],
            [
                'name' => 'عطور نسائية',
                'unit_id' => $mlUnit->id,
            ],
            [
                'name' => 'عطور مشتركة',
                'unit_id' => $mlUnit->id,
            ],
            [
                'name' => 'بخور',
                'unit_id' => $gUnit->id,
            ],
            [
                'name' => 'دهن عود',
                'unit_id' => $mlUnit->id,
            ],
            [
                'name' => 'معطرات',
                'unit_id' => $pcsUnit->id,
            ],
        ];

        foreach ($categories as $category) {
            Category::create($category);
        }
    }
}
