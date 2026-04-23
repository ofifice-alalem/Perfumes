<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\UnitResource;
use App\Repositories\Contracts\UnitRepositoryInterface;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class UnitController extends Controller
{
    public function __construct(
        private UnitRepositoryInterface $unitRepo
    ) {}

    /**
     * Display a listing of units.
     */
    public function index(): AnonymousResourceCollection
    {
        $units = $this->unitRepo->all();
        return UnitResource::collection($units);
    }

    /**
     * Store a newly created unit.
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'required|string|max:50',
            'symbol' => 'required|string|max:10|unique:units,symbol',
        ]);

        $unit = $this->unitRepo->create($validated);

        return response()->json([
            'success' => true,
            'message' => 'Unit created successfully',
            'data' => new UnitResource($unit),
        ], 201);
    }

    /**
     * Display the specified unit.
     */
    public function show(int $id): JsonResponse
    {
        $unit = $this->unitRepo->find($id);

        if (!$unit) {
            return response()->json([
                'success' => false,
                'message' => 'Unit not found',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => new UnitResource($unit),
        ]);
    }

    /**
     * Update the specified unit.
     */
    public function update(Request $request, int $id): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'required|string|max:50',
            'symbol' => 'required|string|max:10|unique:units,symbol,' . $id,
        ]);

        $updated = $this->unitRepo->update($id, $validated);

        if (!$updated) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to update unit',
            ], 400);
        }

        $unit = $this->unitRepo->find($id);

        return response()->json([
            'success' => true,
            'message' => 'Unit updated successfully',
            'data' => new UnitResource($unit),
        ]);
    }

    /**
     * Remove the specified unit.
     */
    public function destroy(int $id): JsonResponse
    {
        $deleted = $this->unitRepo->delete($id);

        if (!$deleted) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to delete unit',
            ], 400);
        }

        return response()->json([
            'success' => true,
            'message' => 'Unit deleted successfully',
        ]);
    }
}
