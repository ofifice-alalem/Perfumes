<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('invoice_costs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('invoice_id')->constrained('invoices');
            $table->decimal('product_cost', 10, 2);
            $table->decimal('material_cost', 10, 2);
            $table->decimal('total_cost', 10, 2);
            $table->timestamp('created_at')->useCurrent();
            
            $table->unique('invoice_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('invoice_costs');
    }
};
