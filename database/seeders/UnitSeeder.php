<?php

namespace Database\Seeders;

use App\Models\Unit;
use Illuminate\Database\Seeder;

class UnitSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $units = [
            [
                'name' => 'Milliliter',
                'symbol' => 'ml',
            ],
            [
                'name' => 'Gram',
                'symbol' => 'g',
            ],
            [
                'name' => 'Piece',
                'symbol' => 'pcs',
            ],
            [
                'name' => 'Liter',
                'symbol' => 'L',
            ],
            [
                'name' => 'Kilogram',
                'symbol' => 'kg',
            ],
        ];

        foreach ($units as $unit) {
            Unit::create($unit);
        }
    }
}
