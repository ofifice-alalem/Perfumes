<?php

declare(strict_types=1);

namespace App\Http\Controllers;

use App\Models\TierPrice;
use App\Repositories\Contracts\PriceTierRepositoryInterface;
use App\Repositories\Contracts\SizeRepositoryInterface;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Inertia\Inertia;
use Inertia\Response;

final class PriceTierController extends Controller
{
    public function __construct(
        private readonly PriceTierRepositoryInterface $priceTierRepository,
        private readonly SizeRepositoryInterface $sizeRepository
    ) {}

    public function index(): Response
    {
        $priceTiers = $this->priceTierRepository->all();

        return Inertia::render('PriceTiers/Index', [
            'priceTiers' => $priceTiers,
        ]);
    }

    public function create(): Response
    {
        // جلب الأحجام الخاصة بالعطور فقط (ml)
        $sizes = Size::whereHas('unit', function ($query) {
            $query->where('symbol', 'ml');
        })->with('unit')->orderBy('value')->get();

        return Inertia::render('PriceTiers/Form', [
            'sizes' => $sizes,
        ]);
    }

    public function store(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'prices' => 'required|array',
        ]);

        DB::transaction(function () use ($validated) {
            $tier = $this->priceTierRepository->create([
                'name' => $validated['name'],
                'description' => $validated['description'] ?? null,
            ]);

            foreach ($validated['prices'] as $sizeId => $price) {
                if (!empty($price)) {
                    TierPrice::create([
                        'tier_id' => $tier->id,
                        'size_id' => (int) $sizeId,
                        'price' => (float) $price,
                    ]);
                }
            }
        });

        return redirect()->route('price-tiers.index')
            ->with('success', 'تم إضافة مستوى السعر بنجاح');
    }

    public function edit(int $id): Response
    {
        $priceTier = $this->priceTierRepository->find($id);
        $priceTier->load('tierPrices');
        $sizes = $this->sizeRepository->all();

        return Inertia::render('PriceTiers/Form', [
            'priceTier' => $priceTier,
            'sizes' => $sizes,
        ]);
    }

    public function update(Request $request, int $id): RedirectResponse
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'prices' => 'required|array',
        ]);

        DB::transaction(function () use ($id, $validated) {
            $this->priceTierRepository->update($id, [
                'name' => $validated['name'],
                'description' => $validated['description'] ?? null,
            ]);

            TierPrice::where('tier_id', $id)->delete();

            foreach ($validated['prices'] as $sizeId => $price) {
                if (!empty($price)) {
                    TierPrice::create([
                        'tier_id' => $id,
                        'size_id' => (int) $sizeId,
                        'price' => (float) $price,
                    ]);
                }
            }
        });

        return redirect()->route('price-tiers.index')
            ->with('success', 'تم تحديث مستوى السعر بنجاح');
    }

    public function destroy(int $id): RedirectResponse
    {
        $this->priceTierRepository->delete($id);

        return redirect()->route('price-tiers.index')
            ->with('success', 'تم حذف مستوى السعر بنجاح');
    }
}
