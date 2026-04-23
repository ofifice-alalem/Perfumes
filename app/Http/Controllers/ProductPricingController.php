<?php

declare(strict_types=1);

namespace App\Http\Controllers;

use App\Models\Product;
use App\Models\TierPrice;
use App\Models\UnitBasedPrice;
use App\Repositories\Contracts\PriceTierRepositoryInterface;
use App\Repositories\Contracts\ProductRepositoryInterface;
use App\Repositories\Contracts\SizeRepositoryInterface;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Inertia\Inertia;
use Inertia\Response;

final class ProductPricingController extends Controller
{
    public function __construct(
        private readonly ProductRepositoryInterface $productRepository,
        private readonly PriceTierRepositoryInterface $priceTierRepository,
        private readonly SizeRepositoryInterface $sizeRepository
    ) {}

    public function index(): Response
    {
        $products = Product::with(['category'])
            ->get()
            ->map(function ($product) {
                $hasPrices = $product->selling_type === 'UNIT_BASED'
                    ? UnitBasedPrice::where('product_id', $product->id)->exists()
                    : TierPrice::whereHas('tier.products', function ($q) use ($product) {
                        $q->where('products.id', $product->id);
                    })->exists();

                return [
                    'id' => $product->id,
                    'name' => $product->name,
                    'sku' => $product->sku,
                    'selling_type' => $product->selling_type,
                    'category' => [
                        'name' => $product->category->name,
                    ],
                    'has_prices' => $hasPrices,
                ];
            });

        return Inertia::render('ProductPricing/Index', [
            'products' => $products,
        ]);
    }

    public function edit(int $id): Response
    {
        $product = Product::with([
            'category.unit',
            'unitBasedPrices'
        ])->findOrFail($id);

        $priceTiers = $this->priceTierRepository->all();
        
        // للعطور: نجلب الأحجام والأسعار من tier_prices
        if ($product->selling_type !== 'UNIT_BASED') {
            $sizes = $this->sizeRepository->all();
            
            // جلب جميع الأسعار من tier_prices
            $tierPrices = TierPrice::all()->map(function ($tp) {
                return [
                    'tier_id' => $tp->tier_id,
                    'size_id' => $tp->size_id,
                    'price' => $tp->price,
                ];
            });
            
            $product->tier_prices = $tierPrices;
        } else {
            $sizes = null;
        }

        return Inertia::render('ProductPricing/Edit', [
            'product' => $product,
            'priceTiers' => $priceTiers,
            'sizes' => $sizes,
        ]);
    }

    public function update(Request $request, int $id): RedirectResponse
    {
        $product = Product::findOrFail($id);
        
        $validated = $request->validate([
            'prices' => 'required|array',
        ]);

        DB::transaction(function () use ($product, $validated) {
            if ($product->selling_type === 'UNIT_BASED') {
                // حذف الأسعار القديمة
                UnitBasedPrice::where('product_id', $product->id)->delete();

                // إضافة الأسعار الجديدة
                foreach ($validated['prices'] as $tierId => $price) {
                    if (!empty($price)) {
                        UnitBasedPrice::create([
                            'product_id' => $product->id,
                            'tier_id' => (int) $tierId,
                            'price_per_unit' => (float) $price,
                        ]);
                    }
                }
            } else {
                // حذف الأسعار القديمة للمنتج
                DB::table('tier_prices')
                    ->whereIn('tier_id', function ($query) use ($product) {
                        $query->select('id')
                            ->from('price_tiers')
                            ->whereExists(function ($q) use ($product) {
                                $q->select(DB::raw(1))
                                    ->from('products')
                                    ->whereColumn('products.price_tier_id', 'price_tiers.id')
                                    ->where('products.id', $product->id);
                            });
                    })
                    ->delete();

                // إضافة الأسعار الجديدة
                foreach ($validated['prices'] as $tierId => $sizes) {
                    foreach ($sizes as $sizeId => $price) {
                        if (!empty($price)) {
                            TierPrice::create([
                                'tier_id' => (int) $tierId,
                                'size_id' => (int) $sizeId,
                                'price' => (float) $price,
                            ]);
                        }
                    }
                }
            }
        });

        return redirect()->route('product-pricing.index')
            ->with('success', 'تم حفظ الأسعار بنجاح');
    }
}
