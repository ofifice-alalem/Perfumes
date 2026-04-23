<?php

namespace App\Policies;

use App\Models\User;

class InventoryPolicy
{
    /**
     * Determine whether the user can view any inventory.
     */
    public function viewAny(User $user): bool
    {
        return true;
    }

    /**
     * Determine whether the user can view the inventory.
     */
    public function view(User $user): bool
    {
        return true;
    }

    /**
     * Determine whether the user can update inventory.
     */
    public function update(User $user): bool
    {
        return in_array($user->role, ['admin', 'manager', 'warehouse']);
    }

    /**
     * Determine whether the user can adjust inventory.
     */
    public function adjust(User $user): bool
    {
        return in_array($user->role, ['admin', 'manager', 'warehouse']);
    }
}
