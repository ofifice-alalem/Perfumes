<?php

namespace App\Repositories\Contracts;

use App\Models\ProductImage;
use Illuminate\Support\Collection;

interface ProductImageRepositoryInterface
{
    public function find(int $id): ?ProductImage;
    public function getByProduct(int $productId): Collection;
    public function create(array $data): ProductImage;
    public function update(int $id, array $data): bool;
    public function delete(int $id): bool;
    public function setPrimary(int $productId, int $imageId): bool;
}
