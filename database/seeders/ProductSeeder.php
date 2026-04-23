<?php

namespace Database\Seeders;

use App\Models\Category;
use App\Models\Product;
use Illuminate\Database\Seeder;

class ProductSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $menCategory = Category::where('name', 'عطور رجالية')->first();
        $womenCategory = Category::where('name', 'عطور نسائية')->first();
        $incenseCategory = Category::where('name', 'بخور')->first();

        $products = [
            // Men's Perfumes
            [
                'name' => 'عود ملكي',
                'sku' => 'PRD-001',
                'category_id' => $menCategory->id,
                'price_tier_id' => 1,
                'selling_type' => 'BOTH',
                'is_returnable' => true,
            ],
            [
                'name' => 'مسك الليل',
                'sku' => 'PRD-002',
                'category_id' => $menCategory->id,
                'price_tier_id' => 1,
                'selling_type' => 'DECANT_ONLY',
                'is_returnable' => true,
            ],
            [
                'name' => 'عنبر فاخر',
                'sku' => 'PRD-003',
                'category_id' => $menCategory->id,
                'price_tier_id' => 1,
                'selling_type' => 'FULL_ONLY',
                'is_returnable' => true,
            ],
            
            // Women's Perfumes
            [
                'name' => 'وردة الصباح',
                'sku' => 'PRD-004',
                'category_id' => $womenCategory->id,
                'price_tier_id' => 1,
                'selling_type' => 'BOTH',
                'is_returnable' => true,
            ],
            [
                'name' => 'ياسمين الشام',
                'sku' => 'PRD-005',
                'category_id' => $womenCategory->id,
                'price_tier_id' => 1,
                'selling_type' => 'DECANT_ONLY',
                'is_returnable' => true,
            ],
            
            // Incense
            [
                'name' => 'بخور كمبودي',
                'sku' => 'PRD-006',
                'category_id' => $incenseCategory->id,
                'price_tier_id' => 1,
                'selling_type' => 'UNIT_BASED',
                'is_returnable' => false,
            ],
            [
                'name' => 'بخور هندي',
                'sku' => 'PRD-007',
                'category_id' => $incenseCategory->id,
                'price_tier_id' => 1,
                'selling_type' => 'UNIT_BASED',
                'is_returnable' => false,
            ],
        ];

        foreach ($products as $product) {
            Product::create($product);
        }
    }
}
