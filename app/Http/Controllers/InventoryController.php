<?php

declare(strict_types=1);

namespace App\Http\Controllers;

use App\Repositories\Contracts\InventoryRepositoryInterface;
use App\Services\InventoryService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

final class InventoryController extends Controller
{
    public function __construct(
        private readonly InventoryRepositoryInterface $inventoryRepository,
        private readonly InventoryService $inventoryService
    ) {}

    public function index(Request $request): Response
    {
        $inventory = $this->inventoryRepository->getAllWithProducts(
            search: $request->input('search')
        );

        return Inertia::render('Inventory/Index', [
            'inventory' => $inventory,
        ]);
    }

    public function adjust(Request $request, int $id): RedirectResponse
    {
        $validated = $request->validate([
            'quantity' => 'required|integer',
            'type' => 'required|in:add,subtract,set',
            'notes' => 'nullable|string|max:500',
        ]);

        $this->inventoryService->adjustStock(
            productId: $id,
            quantity: (int) $validated['quantity'],
            type: $validated['type'],
            notes: $validated['notes'] ?? null
        );

        return redirect()->route('inventory.index')
            ->with('success', 'تم تعديل المخزون بنجاح');
    }
}
