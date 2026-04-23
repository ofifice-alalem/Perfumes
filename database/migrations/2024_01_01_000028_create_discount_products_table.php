<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('discount_products', function (Blueprint $table) {
            $table->id();
            $table->foreignId('discount_id')->constrained('discounts');
            $table->foreignId('product_id')->constrained('products');
            $table->timestamp('created_at')->useCurrent();
            
            $table->unique(['discount_id', 'product_id']);
            $table->index('discount_id');
            $table->index('product_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('discount_products');
    }
};
