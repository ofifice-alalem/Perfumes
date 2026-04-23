<?php

namespace App\Repositories;

use App\Models\Inventory;
use App\Repositories\Contracts\InventoryRepositoryInterface;
use Illuminate\Support\Collection;

class InventoryRepository implements InventoryRepositoryInterface
{
    public function all(): Collection
    {
        return Inventory::with(['product', 'unit'])->get();
    }

    public function find(int $id): ?Inventory
    {
        return Inventory::with(['product', 'unit'])->find($id);
    }

    public function findByProduct(int $productId): ?Inventory
    {
        return Inventory::where('product_id', $productId)
            ->with(['product', 'unit'])
            ->first();
    }

    public function create(array $data): Inventory
    {
        return Inventory::create($data);
    }

    public function update(int $id, array $data): bool
    {
        return Inventory::where('id', $id)->update($data);
    }

    public function updateQuantity(int $productId, float $quantity): bool
    {
        return Inventory::where('product_id', $productId)
            ->update(['quantity' => $quantity]);
    }

    public function getLowStock(): Collection
    {
        return Inventory::whereRaw('quantity <= min_stock_level')
            ->with(['product', 'unit'])
            ->get();
    }

    public function getOutOfStock(): Collection
    {
        return Inventory::where('quantity', '<=', 0)
            ->with(['product', 'unit'])
            ->get();
    }
}
