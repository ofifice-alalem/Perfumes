<?php

namespace App\Repositories;

use App\Models\Category;
use App\Repositories\Contracts\CategoryRepositoryInterface;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Support\Collection;

class CategoryRepository implements CategoryRepositoryInterface
{
    public function all(): Collection
    {
        return Category::all();
    }

    public function find(int $id): ?Category
    {
        return Category::with('unit')->find($id);
    }

    public function findOrFail(int $id): Category
    {
        return Category::with('unit')->findOrFail($id);
    }

    public function create(array $data): Category
    {
        return Category::create($data);
    }

    public function update(int $id, array $data): bool
    {
        return Category::where('id', $id)->update($data);
    }

    public function delete(int $id): bool
    {
        return Category::destroy($id) > 0;
    }

    public function getWithUnit(): Collection
    {
        return Category::with('unit')->get();
    }

    public function getByUnit(int $unitId): Collection
    {
        return Category::where('unit_id', $unitId)->get();
    }

    public function paginate(int $perPage = 15, ?string $search = null): LengthAwarePaginator
    {
        $query = Category::withCount('products');

        if ($search) {
            $query->where('name', 'like', "%{$search}%")
                  ->orWhere('description', 'like', "%{$search}%");
        }

        return $query->latest()->paginate($perPage);
    }
}
