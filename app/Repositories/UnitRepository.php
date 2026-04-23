<?php

namespace App\Repositories;

use App\Models\Unit;
use App\Repositories\Contracts\UnitRepositoryInterface;
use Illuminate\Support\Collection;

class UnitRepository implements UnitRepositoryInterface
{
    public function all(): Collection
    {
        return Unit::all();
    }

    public function find(int $id): ?Unit
    {
        return Unit::find($id);
    }

    public function findBySymbol(string $symbol): ?Unit
    {
        return Unit::where('symbol', $symbol)->first();
    }

    public function create(array $data): Unit
    {
        return Unit::create($data);
    }

    public function update(int $id, array $data): bool
    {
        return Unit::where('id', $id)->update($data);
    }

    public function delete(int $id): bool
    {
        return Unit::destroy($id) > 0;
    }
}
