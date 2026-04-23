<?php

namespace App\Repositories\Contracts;

use App\Models\Category;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Support\Collection;

interface CategoryRepositoryInterface
{
    public function all(): Collection;
    public function find(int $id): ?Category;
    public function findOrFail(int $id): Category;
    public function create(array $data): Category;
    public function update(int $id, array $data): bool;
    public function delete(int $id): bool;
    public function getWithUnit(): Collection;
    public function getByUnit(int $unitId): Collection;
    public function paginate(int $perPage = 15, ?string $search = null): LengthAwarePaginator;
}
