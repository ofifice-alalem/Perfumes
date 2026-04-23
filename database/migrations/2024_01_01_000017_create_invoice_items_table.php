<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('invoice_items', function (Blueprint $table) {
            $table->id();
            $table->foreignId('invoice_id')->constrained('invoices')->onDelete('cascade');
            $table->foreignId('product_id')->constrained('products');
            $table->enum('sale_type', ['decant', 'full', 'unit_based']);
            $table->foreignId('size_id')->nullable()->constrained('sizes');
            $table->decimal('quantity', 10, 2);
            $table->decimal('unit_price', 10, 2);
            $table->decimal('product_unit_cost', 10, 2)->nullable();
            $table->decimal('discount', 10, 2)->default(0);
            $table->foreignId('discount_id')->nullable()->constrained('discounts');
            $table->decimal('total_price', 10, 2);
            $table->timestamp('created_at')->useCurrent();
            
            $table->index('invoice_id');
            $table->index('product_id');
            $table->index('discount_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('invoice_items');
    }
};
