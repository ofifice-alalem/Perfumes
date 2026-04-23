<?php

namespace Database\Seeders;

use App\Models\Size;
use App\Models\Unit;
use Illuminate\Database\Seeder;

class SizeSeeder extends Seeder
{
    public function run(): void
    {
        $mlUnit = Unit::where('symbol', 'ml')->first();
        $gUnit = Unit::where('symbol', 'g')->first();

        $sizes = [
            // Perfume sizes (ml)
            ['name' => '3 مل', 'value' => 3, 'unit_id' => $mlUnit->id],
            ['name' => '6 مل', 'value' => 6, 'unit_id' => $mlUnit->id],
            ['name' => '12 مل', 'value' => 12, 'unit_id' => $mlUnit->id],
            ['name' => '30 مل', 'value' => 30, 'unit_id' => $mlUnit->id],
            ['name' => '50 مل', 'value' => 50, 'unit_id' => $mlUnit->id],
            ['name' => '100 مل', 'value' => 100, 'unit_id' => $mlUnit->id],
            
            // Incense sizes (g)
            ['name' => '10 جرام', 'value' => 10, 'unit_id' => $gUnit->id],
            ['name' => '25 جرام', 'value' => 25, 'unit_id' => $gUnit->id],
            ['name' => '50 جرام', 'value' => 50, 'unit_id' => $gUnit->id],
            ['name' => '100 جرام', 'value' => 100, 'unit_id' => $gUnit->id],
        ];

        foreach ($sizes as $size) {
            Size::create($size);
        }
    }
}
