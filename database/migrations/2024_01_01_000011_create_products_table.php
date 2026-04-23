<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('products', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('sku', 50)->nullable()->unique();
            $table->foreignId('category_id')->constrained('categories');
            $table->foreignId('price_tier_id')->nullable()->constrained('price_tiers');
            $table->enum('selling_type', ['DECANT_ONLY', 'FULL_ONLY', 'BOTH', 'UNIT_BASED']);
            $table->boolean('is_returnable')->default(true);
            $table->timestamps();
            
            $table->index('selling_type');
            $table->index('is_returnable');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('products');
    }
};
