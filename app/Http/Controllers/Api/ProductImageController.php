<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\ProductImageResource;
use App\Repositories\Contracts\ProductImageRepositoryInterface;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class ProductImageController extends Controller
{
    public function __construct(
        private ProductImageRepositoryInterface $imageRepo
    ) {}

    /**
     * Get images for a product.
     */
    public function index(int $productId): JsonResponse
    {
        $images = $this->imageRepo->getByProduct($productId);

        return response()->json([
            'success' => true,
            'data' => ProductImageResource::collection($images),
        ]);
    }

    /**
     * Upload product image.
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'product_id' => 'required|exists:products,id',
            'image' => 'required|image|mimes:jpeg,png,jpg,webp|max:2048',
            'is_primary' => 'boolean',
            'order_num' => 'nullable|integer',
        ]);

        try {
            // Upload image
            $path = $request->file('image')->store('products', 'public');

            // Create image record
            $image = $this->imageRepo->create([
                'product_id' => $validated['product_id'],
                'image_path' => $path,
                'is_primary' => $validated['is_primary'] ?? false,
                'order_num' => $validated['order_num'] ?? 0,
            ]);

            // If primary, update other images
            if ($validated['is_primary'] ?? false) {
                $this->imageRepo->setPrimary($validated['product_id'], $image->id);
            }

            return response()->json([
                'success' => true,
                'message' => 'Image uploaded successfully',
                'data' => new ProductImageResource($image),
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to upload image',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Update image details.
     */
    public function update(Request $request, int $id): JsonResponse
    {
        $validated = $request->validate([
            'is_primary' => 'boolean',
            'order_num' => 'nullable|integer',
        ]);

        $updated = $this->imageRepo->update($id, $validated);

        if (!$updated) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to update image',
            ], 400);
        }

        $image = $this->imageRepo->find($id);

        // If set as primary, update other images
        if (isset($validated['is_primary']) && $validated['is_primary']) {
            $this->imageRepo->setPrimary($image->product_id, $id);
        }

        return response()->json([
            'success' => true,
            'message' => 'Image updated successfully',
            'data' => new ProductImageResource($image),
        ]);
    }

    /**
     * Delete product image.
     */
    public function destroy(int $id): JsonResponse
    {
        $deleted = $this->imageRepo->delete($id);

        if (!$deleted) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to delete image',
            ], 400);
        }

        return response()->json([
            'success' => true,
            'message' => 'Image deleted successfully',
        ]);
    }

    /**
     * Set image as primary.
     */
    public function setPrimary(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'product_id' => 'required|exists:products,id',
            'image_id' => 'required|exists:product_images,id',
        ]);

        $updated = $this->imageRepo->setPrimary(
            $validated['product_id'],
            $validated['image_id']
        );

        if (!$updated) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to set primary image',
            ], 400);
        }

        return response()->json([
            'success' => true,
            'message' => 'Primary image set successfully',
        ]);
    }
}
