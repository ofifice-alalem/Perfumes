<?php

namespace App\Repositories;

use App\Models\ProductImage;
use App\Repositories\Contracts\ProductImageRepositoryInterface;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;

class ProductImageRepository implements ProductImageRepositoryInterface
{
    public function find(int $id): ?ProductImage
    {
        return ProductImage::find($id);
    }

    public function getByProduct(int $productId): Collection
    {
        return ProductImage::where('product_id', $productId)
            ->ordered()
            ->get();
    }

    public function create(array $data): ProductImage
    {
        return ProductImage::create($data);
    }

    public function update(int $id, array $data): bool
    {
        return ProductImage::where('id', $id)->update($data);
    }

    public function delete(int $id): bool
    {
        $image = ProductImage::find($id);
        
        if ($image) {
            // Delete file from storage
            if (Storage::disk('public')->exists($image->image_path)) {
                Storage::disk('public')->delete($image->image_path);
            }
            
            return $image->delete();
        }
        
        return false;
    }

    public function setPrimary(int $productId, int $imageId): bool
    {
        return DB::transaction(function () use ($productId, $imageId) {
            // Remove primary from all images
            ProductImage::where('product_id', $productId)
                ->update(['is_primary' => false]);
            
            // Set new primary
            return ProductImage::where('id', $imageId)
                ->where('product_id', $productId)
                ->update(['is_primary' => true]) > 0;
        });
    }
}
