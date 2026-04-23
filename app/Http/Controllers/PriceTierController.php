<?php

declare(strict_types=1);

namespace App\Http\Controllers;

use App\Repositories\Contracts\PriceTierRepositoryInterface;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

final class PriceTierController extends Controller
{
    public function __construct(
        private readonly PriceTierRepositoryInterface $priceTierRepository
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
        return Inertia::render('PriceTiers/Form');
    }

    public function store(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
        ]);

        $this->priceTierRepository->create($validated);

        return redirect()->route('price-tiers.index')
            ->with('success', 'تم إضافة مستوى السعر بنجاح');
    }

    public function edit(int $id): Response
    {
        $priceTier = $this->priceTierRepository->find($id);

        return Inertia::render('PriceTiers/Form', [
            'priceTier' => $priceTier,
        ]);
    }

    public function update(Request $request, int $id): RedirectResponse
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
        ]);

        $this->priceTierRepository->update($id, $validated);

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
