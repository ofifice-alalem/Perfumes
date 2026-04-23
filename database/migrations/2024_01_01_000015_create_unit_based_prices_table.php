<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('unit_based_prices', function (Blueprint $table) {
            $table->id();
            $table->foreignId('product_id')->constrained('products');
            $table->foreignId('tier_id')->constrained('price_tiers');
            $table->decimal('price_per_unit', 10, 2);
            $table->timestamps();
            
            $table->unique(['product_id', 'tier_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('unit_based_prices');
    }
};
