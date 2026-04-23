<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('return_cost_reversals', function (Blueprint $table) {
            $table->id();
            $table->foreignId('return_id')->constrained('returns');
            $table->foreignId('invoice_cost_id')->constrained('invoice_costs');
            $table->decimal('product_cost', 10, 2)->default(0);
            $table->decimal('material_cost', 10, 2)->default(0);
            $table->decimal('total_cost', 10, 2)->default(0);
            $table->timestamp('created_at')->useCurrent();
            
            $table->unique('return_id');
            $table->index('invoice_cost_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('return_cost_reversals');
    }
};
