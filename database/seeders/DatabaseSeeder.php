<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // Create admin user
        User::create([
            'name' => 'Admin User',
            'email' => 'admin@perfumes.com',
            'password' => bcrypt('password'),
            'role' => 'admin',
            'is_active' => true,
        ]);

        // Create manager user
        User::create([
            'name' => 'Manager User',
            'email' => 'manager@perfumes.com',
            'password' => bcrypt('password'),
            'role' => 'manager',
            'is_active' => true,
        ]);

        // Seed Step 1 data
        $this->call([
            UnitSeeder::class,
            SizeSeeder::class,
            CategorySeeder::class,
            ProductSeeder::class,
            InventorySeeder::class,
        ]);
    }
}
