<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('material_usage', function (Blueprint $table) {
            $table->id();
            $table->foreignId('invoice_item_id')->constrained('invoice_items');
            $table->foreignId('material_id')->constrained('material_types');
            $table->decimal('quantity_used', 10, 2);
            $table->decimal('cost_per_unit_snapshot', 10, 2);
            $table->decimal('total_cost', 10, 2);
            $table->timestamp('created_at')->useCurrent();
            
            $table->index('invoice_item_id');
            $table->index('material_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('material_usage');
    }
};
