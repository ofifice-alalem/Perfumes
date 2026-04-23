<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Auth\AuthController;
use App\Http\Controllers\CategoryController;
use App\Http\Controllers\DashboardController;
use App\Http\Controllers\InventoryController;
use App\Http\Controllers\PriceTierController;
use App\Http\Controllers\ProductController;
use App\Http\Controllers\UnitController;

Route::get('/login', [AuthController::class, 'showLogin'])->name('login');
Route::post('/login', [AuthController::class, 'login']);
Route::post('/logout', [AuthController::class, 'logout'])->name('logout');

Route::middleware(['auth'])->group(function () {
    Route::get('/', [DashboardController::class, 'index'])->name('dashboard');
    
    Route::resource('units', UnitController::class);
    Route::resource('categories', CategoryController::class);
    Route::resource('price-tiers', PriceTierController::class);
    Route::resource('products', ProductController::class);
    
    Route::get('/inventory', [InventoryController::class, 'index'])->name('inventory.index');
    Route::post('/inventory/{id}/adjust', [InventoryController::class, 'adjust'])->name('inventory.adjust');
});
