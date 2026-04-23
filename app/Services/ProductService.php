<?php

namespace App\Services;

use App\Models\Product;
use App\Repositories\Contracts\ProductRepositoryInterface;
use App\Repositories\Contracts\InventoryRepositoryInterface;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;
use Illuminate\Pagination\LengthAwarePaginator;

class ProductService
{
    public function __construct(
        private ProductRepositoryInterface $productRepo,
        private InventoryRepositoryInterface $inventoryRepo
    ) {}

    /**
     * Get all products with pagination
     */
    public function getAllProducts(int $perPage = 15): LengthAwarePaginator
    {
        return $this->productRepo->paginate($perPage);
    }

    /**
     * Create new product with inventory
     */
    public function createProduct(array $data): Product
    {
        return DB::transaction(function () use ($data) {
            // Create product
            $product = $this->productRepo->create([
                'name' => $data['name'],
                'sku' => $data['sku'] ?? $this->generateSku(),
                'category_id' => $data['category_id'],
                'price_tier_id' => $data['price_tier_id'],
                'selling_type' => $data['selling_type'],
                'is_returnable' => $data['is_returnable'] ?? true,
            ]);

            // Create inventory if provided
            if (isset($data['inventory'])) {
                $this->inventoryRepo->create([
                    'product_id' => $product->id,
                    'quantity' => $data['inventory']['quantity'] ?? 0,
                    'min_stock_level' => $data['inventory']['min_stock_level'] ?? 0,
                    'unit_id' => $data['inventory']['unit_id'],
                ]);
            }

            return $product->fresh(['category', 'inventory', 'images']);
        });
    }

    /**
     * Update product
     */
    public function updateProduct(int $id, array $data): Product
    {
        return DB::transaction(function () use ($id, $data) {
            // Update product
            $this->productRepo->update($id, [
                'name' => $data['name'],
                'sku' => $data['sku'],
                'category_id' => $data['category_id'],
                'price_tier_id' => $data['price_tier_id'],
                'selling_type' => $data['selling_type'],
                'is_returnable' => $data['is_returnable'] ?? true,
            ]);

            // Update inventory if provided
            if (isset($data['inventory'])) {
                $inventory = $this->inventoryRepo->findByProduct($id);
                if ($inventory) {
                    $this->inventoryRepo->update($inventory->id, [
                        'min_stock_level' => $data['inventory']['min_stock_level'],
                        'unit_id' => $data['inventory']['unit_id'],
                    ]);
                }
            }

            return $this->productRepo->find($id);
        });
    }

    /**
     * Delete product
     */
    public function deleteProduct(int $id): bool
    {
        return DB::transaction(function () use ($id) {
            // Set inventory to zero before delete
            $inventory = $this->inventoryRepo->findByProduct($id);
            if ($inventory) {
                $this->inventoryRepo->update($inventory->id, ['quantity' => 0]);
            }

            return $this->productRepo->delete($id);
        });
    }

    /**
     * Get product with all relationships
     */
    public function getProductWithInventory(int $id): ?Product
    {
        return $this->productRepo->find($id);
    }

    /**
     * Get low stock products
     */
    public function getLowStockProducts(): Collection
    {
        return $this->productRepo->getLowStock();
    }

    /**
     * Search products
     */
    public function searchProducts(string $query): Collection
    {
        return $this->productRepo->search($query);
    }

    /**
     * Get products by category
     */
    public function getProductsByCategory(int $categoryId): Collection
    {
        return $this->productRepo->getByCategory($categoryId);
    }

    /**
     * Get returnable products
     */
    public function getReturnableProducts(): Collection
    {
        return $this->productRepo->getReturnable();
    }

    /**
     * Generate unique SKU
     */
    private function generateSku(): string
    {
        $prefix = 'PRD';
        $timestamp = now()->format('ymd');
        $random = strtoupper(substr(md5(uniqid()), 0, 4));
        
        return "{$prefix}-{$timestamp}-{$random}";
    }
}
