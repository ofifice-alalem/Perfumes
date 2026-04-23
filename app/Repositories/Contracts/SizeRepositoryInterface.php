<?php

namespace App\Repositories\Contracts;

use App\Models\Size;
use Illuminate\Support\Collection;

interface SizeRepositoryInterface
{
    public function all(): Collection;
    public function find(int $id): ?Size;
}
