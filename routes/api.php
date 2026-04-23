<?php

use App\Http\Controllers\Api\CategoryController;
use App\Http\Controllers\Api\InventoryController;
use App\Http\Controllers\Api\ProductController;
use App\Http\Controllers\Api\ProductImageController;
use App\Http\Controllers\Api\UnitController;
use Illuminate\Support\Facades\Route;

Route::middleware('auth:sanctum')->group(function () {
    
    // Units
    Route::apiResource('units', UnitController::class);
    
    // Categories
    Route::apiResource('categories', CategoryController::class);
    
    // Products
    Route::get('products/low-stock', [ProductController::class, 'lowStock']);
    Route::get('products/search', [ProductController::class, 'search']);
    Route::apiResource('products', ProductController::class);
    
    // Inventory
    Route::get('inventory/low-stock', [InventoryController::class, 'lowStock']);
    Route::get('inventory/out-of-stock', [InventoryController::class, 'outOfStock']);
    Route::get('inventory/{productId}', [InventoryController::class, 'show']);
    Route::put('inventory/{productId}', [InventoryController::class, 'update']);
    Route::post('inventory/{productId}/adjust', [InventoryController::class, 'adjust']);
    
    // Product Images
    Route::get('products/{productId}/images', [ProductImageController::class, 'index']);
    Route::post('product-images', [ProductImageController::class, 'store']);
    Route::put('product-images/{id}', [ProductImageController::class, 'update']);
    Route::delete('product-images/{id}', [ProductImageController::class, 'destroy']);
    Route::post('product-images/set-primary', [ProductImageController::class, 'setPrimary']);
});
