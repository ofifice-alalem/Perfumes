<?php

namespace App\Repositories\Contracts;

use App\Models\Product;
use Illuminate\Support\Collection;
use Illuminate\Pagination\LengthAwarePaginator;

interface ProductRepositoryInterface
{
    public function all(): Collection;
    public function paginate(int $perPage = 15): LengthAwarePaginator;
    public function find(int $id): ?Product;
    public function findBySku(string $sku): ?Product;
    public function create(array $data): Product;
    public function update(int $id, array $data): bool;
    public function delete(int $id): bool;
    public function getByCategory(int $categoryId): Collection;
    public function getLowStock(): Collection;
    public function search(string $query): Collection;
    public function getReturnable(): Collection;
    public function getBySellingType(string $type): Collection;
}
