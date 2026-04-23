<?php

namespace App\Repositories\Contracts;

use App\Models\Unit;
use Illuminate\Support\Collection;

interface UnitRepositoryInterface
{
    public function all(): Collection;
    public function find(int $id): ?Unit;
    public function findBySymbol(string $symbol): ?Unit;
    public function create(array $data): Unit;
    public function update(int $id, array $data): bool;
    public function delete(int $id): bool;
}
