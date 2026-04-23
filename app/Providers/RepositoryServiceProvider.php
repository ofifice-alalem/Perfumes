<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;

class RepositoryServiceProvider extends ServiceProvider
{
    /**
     * Register services.
     */
    public function register(): void
    {
        $this->app->bind(
            \App\Repositories\Contracts\UnitRepositoryInterface::class,
            \App\Repositories\UnitRepository::class
        );

        $this->app->bind(
            \App\Repositories\Contracts\SizeRepositoryInterface::class,
            \App\Repositories\SizeRepository::class
        );

        $this->app->bind(
            \App\Repositories\Contracts\CategoryRepositoryInterface::class,
            \App\Repositories\CategoryRepository::class
        );

        $this->app->bind(
            \App\Repositories\Contracts\PriceTierRepositoryInterface::class,
            \App\Repositories\PriceTierRepository::class
        );

        $this->app->bind(
            \App\Repositories\Contracts\ProductRepositoryInterface::class,
            \App\Repositories\ProductRepository::class
        );

        $this->app->bind(
            \App\Repositories\Contracts\InventoryRepositoryInterface::class,
            \App\Repositories\InventoryRepository::class
        );

        $this->app->bind(
            \App\Repositories\Contracts\ProductImageRepositoryInterface::class,
            \App\Repositories\ProductImageRepository::class
        );
    }

    /**
     * Bootstrap services.
     */
    public function boot(): void
    {
        //
    }
}
