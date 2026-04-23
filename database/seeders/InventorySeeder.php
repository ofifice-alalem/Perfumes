<?php

namespace Database\Seeders;

use App\Models\Inventory;
use App\Models\Product;
use App\Models\Unit;
use Illuminate\Database\Seeder;

class InventorySeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $products = Product::all();
        $mlUnit = Unit::where('symbol', 'ml')->first();
        $gUnit = Unit::where('symbol', 'g')->first();

        foreach ($products as $product) {
            // Determine unit based on category
            $unitId = $product->category->unit_id;
            
            // Set different quantities based on selling type
            $quantity = match($product->selling_type) {
                'DECANT_ONLY' => rand(500, 2000),
                'FULL_ONLY' => rand(20, 100),
                'BOTH' => rand(500, 2000),
                'UNIT_BASED' => rand(50, 200),
            };

            $minStockLevel = match($product->selling_type) {
                'DECANT_ONLY' => 200,
                'FULL_ONLY' => 10,
                'BOTH' => 200,
                'UNIT_BASED' => 20,
            };

            Inventory::create([
                'product_id' => $product->id,
                'quantity' => $quantity,
                'min_stock_level' => $minStockLevel,
                'unit_id' => $unitId,
            ]);
        }
    }
}
