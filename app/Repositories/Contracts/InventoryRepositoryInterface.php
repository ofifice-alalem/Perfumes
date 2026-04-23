<?php

namespace App\Repositories\Contracts;

use App\Models\Inventory;
use Illuminate\Support\Collection;

interface InventoryRepositoryInterface
{
    public function all(): Collection;
    public function find(int $id): ?Inventory;
    public function findByProduct(int $productId): ?Inventory;
    public function create(array $data): Inventory;
    public function update(int $id, array $data): bool;
    public function updateQuantity(int $productId, float $quantity): bool;
    public function getLowStock(): Collection;
    public function getOutOfStock(): Collection;
    public function getAllWithProducts(?string $search = null): Collection;
}
