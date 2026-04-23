<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('tier_prices', function (Blueprint $table) {
            $table->id();
            $table->foreignId('tier_id')->constrained('price_tiers');
            $table->foreignId('size_id')->constrained('sizes');
            $table->decimal('price', 10, 2);
            $table->timestamps();
            
            $table->unique(['tier_id', 'size_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('tier_prices');
    }
};
