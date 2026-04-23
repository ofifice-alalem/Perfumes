<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreInventoryRequest;
use App\Http\Requests\UpdateInventoryRequest;
use App\Http\Resources\InventoryResource;
use App\Services\InventoryService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class InventoryController extends Controller
{
    public function __construct(
        private InventoryService $inventoryService
    ) {}

    /**
     * Display inventory for a product.
     */
    public function show(int $productId): JsonResponse
    {
        $inventory = $this->inventoryService->getInventory($productId);

        if (!$inventory) {
            return response()->json([
                'success' => false,
                'message' => 'Inventory not found',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => new InventoryResource($inventory),
        ]);
    }

    /**
     * Update inventory quantity.
     */
    public function update(UpdateInventoryRequest $request, int $productId): JsonResponse
    {
        try {
            if ($request->has('quantity')) {
                $inventory = $this->inventoryService->updateQuantity(
                    $productId,
                    $request->input('quantity')
                );
            }

            return response()->json([
                'success' => true,
                'message' => 'Inventory updated successfully',
                'data' => new InventoryResource($inventory),
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to update inventory',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get low stock products.
     */
    public function lowStock(): JsonResponse
    {
        $inventory = $this->inventoryService->checkLowStock();

        return response()->json([
            'success' => true,
            'data' => InventoryResource::collection($inventory),
            'count' => $inventory->count(),
        ]);
    }

    /**
     * Get out of stock products.
     */
    public function outOfStock(): JsonResponse
    {
        $inventory = $this->inventoryService->getOutOfStock();

        return response()->json([
            'success' => true,
            'data' => InventoryResource::collection($inventory),
            'count' => $inventory->count(),
        ]);
    }

    /**
     * Adjust inventory (add or deduct).
     */
    public function adjust(Request $request, int $productId): JsonResponse
    {
        $validated = $request->validate([
            'type' => 'required|in:add,deduct',
            'quantity' => 'required|numeric|min:0.01',
            'notes' => 'nullable|string',
        ]);

        try {
            if ($validated['type'] === 'add') {
                $this->inventoryService->addStock(
                    $productId,
                    $validated['quantity'],
                    'adjustment',
                    null,
                    $validated['notes'] ?? null
                );
            } else {
                $this->inventoryService->deductStock(
                    $productId,
                    $validated['quantity'],
                    'adjustment',
                    null,
                    $validated['notes'] ?? null
                );
            }

            $inventory = $this->inventoryService->getInventory($productId);

            return response()->json([
                'success' => true,
                'message' => 'Inventory adjusted successfully',
                'data' => new InventoryResource($inventory),
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 422);
        }
    }
}
