<?php

namespace App\Repositories;

use App\Models\Size;
use App\Repositories\Contracts\SizeRepositoryInterface;
use Illuminate\Support\Collection;

class SizeRepository implements SizeRepositoryInterface
{
    public function all(): Collection
    {
        return Size::with('unit')->orderBy('value')->get();
    }

    public function find(int $id): ?Size
    {
        return Size::with('unit')->find($id);
    }
}
