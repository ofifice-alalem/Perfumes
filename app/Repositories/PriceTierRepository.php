<?php

namespace App\Repositories;

use App\Models\PriceTier;
use App\Repositories\Contracts\PriceTierRepositoryInterface;
use Illuminate\Support\Collection;

class PriceTierRepository implements PriceTierRepositoryInterface
{
    public function all(): Collection
    {
        return PriceTier::withCount('products')->get();
    }

    public function find(int $id): ?PriceTier
    {
        return PriceTier::find($id);
    }

    public function create(array $data): PriceTier
    {
        return PriceTier::create($data);
    }

    public function update(int $id, array $data): bool
    {
        return PriceTier::where('id', $id)->update($data);
    }

    public function delete(int $id): bool
    {
        return PriceTier::destroy($id) > 0;
    }
}
