<?php

namespace App\Services;

use App\Models\Inventory;
use App\Repositories\Contracts\InventoryRepositoryInterface;
use App\Exceptions\InsufficientStockException;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;

class InventoryService
{
    public function __construct(
        private InventoryRepositoryInterface $inventoryRepo
    ) {}

    /**
     * Get inventory by product
     */
    public function getInventory(int $productId): ?Inventory
    {
        return $this->inventoryRepo->findByProduct($productId);
    }

    /**
     * Update inventory quantity
     */
    public function updateQuantity(int $productId, float $quantity): Inventory
    {
        $this->inventoryRepo->updateQuantity($productId, $quantity);
        return $this->inventoryRepo->findByProduct($productId);
    }

    /**
     * Add stock to inventory
     */
    public function addStock(
        int $productId,
        float $quantity,
        ?string $referenceType = null,
        ?int $referenceId = null,
        ?string $notes = null
    ): void {
        $inventory = $this->inventoryRepo->findByProduct($productId);
        
        if (!$inventory) {
            throw new \Exception("Inventory not found for product {$productId}");
        }

        DB::transaction(function () use ($inventory, $quantity) {
            $newQuantity = $inventory->quantity + $quantity;
            $this->inventoryRepo->updateQuantity($inventory->product_id, $newQuantity);
            
            // TODO: Record inventory movement in Step 5
        });
    }

    /**
     * Deduct stock from inventory
     */
    public function deductStock(
        int $productId,
        float $quantity,
        ?string $referenceType = null,
        ?int $referenceId = null,
        ?string $notes = null
    ): void {
        $inventory = $this->inventoryRepo->findByProduct($productId);
        
        if (!$inventory) {
            throw new \Exception("Inventory not found for product {$productId}");
        }

        if ($inventory->quantity < $quantity) {
            throw new InsufficientStockException(
                "Insufficient stock for product {$productId}. Available: {$inventory->quantity}, Required: {$quantity}"
            );
        }

        DB::transaction(function () use ($inventory, $quantity) {
            $newQuantity = $inventory->quantity - $quantity;
            $this->inventoryRepo->updateQuantity($inventory->product_id, $newQuantity);
            
            // TODO: Record inventory movement in Step 5
        });
    }

    /**
     * Check low stock products
     */
    public function checkLowStock(): Collection
    {
        return $this->inventoryRepo->getLowStock();
    }

    /**
     * Get stock status
     */
    public function getStockStatus(int $productId): string
    {
        $inventory = $this->inventoryRepo->findByProduct($productId);
        
        if (!$inventory) {
            return 'unknown';
        }

        return $inventory->stock_status;
    }

    /**
     * Get out of stock products
     */
    public function getOutOfStock(): Collection
    {
        return $this->inventoryRepo->getOutOfStock();
    }

    /**
     * Check if quantity is available
     */
    public function isAvailable(int $productId, float $quantity): bool
    {
        $inventory = $this->inventoryRepo->findByProduct($productId);
        
        if (!$inventory) {
            return false;
        }

        return $inventory->quantity >= $quantity;
    }

    /**
     * Get available quantity
     */
    public function getAvailableQuantity(int $productId): float
    {
        $inventory = $this->inventoryRepo->findByProduct($productId);
        
        return $inventory?->quantity ?? 0;
    }
}
