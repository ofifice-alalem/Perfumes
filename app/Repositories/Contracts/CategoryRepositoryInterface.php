<?php

namespace App\Repositories\Contracts;

use App\Models\Category;
use Illuminate\Support\Collection;

interface CategoryRepositoryInterface
{
    public function all(): Collection;
    public function find(int $id): ?Category;
    public function create(array $data): Category;
    public function update(int $id, array $data): bool;
    public function delete(int $id): bool;
    public function getWithUnit(): Collection;
    public function getByUnit(int $unitId): Collection;
}
