<?php

namespace App\Repositories;

use App\Models\Product;
use App\Repositories\Contracts\ProductRepositoryInterface;
use Illuminate\Support\Collection;
use Illuminate\Pagination\LengthAwarePaginator;

class ProductRepository implements ProductRepositoryInterface
{
    public function all(): Collection
    {
        return Product::with(['category', 'inventory', 'images'])->get();
    }

    public function paginate(int $perPage = 15, ?string $search = null, ?int $categoryId = null): LengthAwarePaginator
    {
        $query = Product::with(['category', 'inventory', 'images']);

        if ($search) {
            $query->where(function($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                  ->orWhere('sku', 'like', "%{$search}%");
            });
        }

        if ($categoryId) {
            $query->where('category_id', $categoryId);
        }

        return $query->latest()->paginate($perPage);
    }

    public function find(int $id): ?Product
    {
        return Product::with(['category', 'inventory', 'images'])->find($id);
    }

    public function findOrFail(int $id): Product
    {
        return Product::with(['category', 'inventory', 'images'])->findOrFail($id);
    }

    public function findBySku(string $sku): ?Product
    {
        return Product::where('sku', $sku)->first();
    }

    public function create(array $data): Product
    {
        return Product::create($data);
    }

    public function update(int $id, array $data): bool
    {
        return Product::where('id', $id)->update($data);
    }

    public function delete(int $id): bool
    {
        return Product::destroy($id) > 0;
    }

    public function getByCategory(int $categoryId): Collection
    {
        return Product::where('category_id', $categoryId)
            ->with(['inventory', 'images'])
            ->get();
    }

    public function getLowStock(): Collection
    {
        return Product::lowStock()
            ->with(['category', 'inventory'])
            ->get();
    }

    public function search(string $query): Collection
    {
        return Product::where('name', 'like', "%{$query}%")
            ->orWhere('sku', 'like', "%{$query}%")
            ->with(['category', 'inventory', 'images'])
            ->get();
    }

    public function getReturnable(): Collection
    {
        return Product::returnable()->get();
    }

    public function getBySellingType(string $type): Collection
    {
        return Product::bySellingType($type)->get();
    }
}
