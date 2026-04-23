<?php

namespace App\Repositories\Contracts;

use App\Models\PriceTier;
use Illuminate\Support\Collection;

interface PriceTierRepositoryInterface
{
    public function all(): Collection;
    public function find(int $id): ?PriceTier;
    public function create(array $data): PriceTier;
    public function update(int $id, array $data): bool;
    public function delete(int $id): bool;
}
