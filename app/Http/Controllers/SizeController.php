<?php

declare(strict_types=1);

namespace App\Http\Controllers;

use App\Models\Size;
use App\Repositories\Contracts\SizeRepositoryInterface;
use App\Repositories\Contracts\UnitRepositoryInterface;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

final class SizeController extends Controller
{
    public function __construct(
        private readonly SizeRepositoryInterface $sizeRepository,
        private readonly UnitRepositoryInterface $unitRepository
    ) {}

    public function index(): Response
    {
        $sizes = $this->sizeRepository->all();

        return Inertia::render('Sizes/Index', [
            'sizes' => $sizes,
        ]);
    }

    public function create(): Response
    {
        $units = $this->unitRepository->all();

        return Inertia::render('Sizes/Form', [
            'units' => $units,
        ]);
    }

    public function store(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'value' => 'required|numeric|min:0',
            'unit_id' => 'required|exists:units,id',
        ]);

        Size::create($validated);

        return redirect()->route('sizes.index')
            ->with('success', 'تم إضافة الحجم بنجاح');
    }

    public function edit(int $id): Response
    {
        $size = $this->sizeRepository->find($id);
        $units = $this->unitRepository->all();

        return Inertia::render('Sizes/Form', [
            'size' => $size,
            'units' => $units,
        ]);
    }

    public function update(Request $request, int $id): RedirectResponse
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'value' => 'required|numeric|min:0',
            'unit_id' => 'required|exists:units,id',
        ]);

        Size::where('id', $id)->update($validated);

        return redirect()->route('sizes.index')
            ->with('success', 'تم تحديث الحجم بنجاح');
    }

    public function destroy(int $id): RedirectResponse
    {
        Size::destroy($id);

        return redirect()->route('sizes.index')
            ->with('success', 'تم حذف الحجم بنجاح');
    }
}
