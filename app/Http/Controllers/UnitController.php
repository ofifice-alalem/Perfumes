<?php

declare(strict_types=1);

namespace App\Http\Controllers;

use App\Repositories\Contracts\UnitRepositoryInterface;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

final class UnitController extends Controller
{
    public function __construct(
        private readonly UnitRepositoryInterface $unitRepository
    ) {}

    public function index(): Response
    {
        $units = $this->unitRepository->all();

        return Inertia::render('Units/Index', [
            'units' => $units,
        ]);
    }

    public function create(): Response
    {
        return Inertia::render('Units/Form');
    }

    public function store(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'symbol' => 'required|string|max:10',
        ]);

        $this->unitRepository->create($validated);

        return redirect()->route('units.index')
            ->with('success', 'تم إضافة الوحدة بنجاح');
    }

    public function edit(int $id): Response
    {
        $unit = $this->unitRepository->find($id);

        return Inertia::render('Units/Form', [
            'unit' => $unit,
        ]);
    }

    public function update(Request $request, int $id): RedirectResponse
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'symbol' => 'required|string|max:10',
        ]);

        $this->unitRepository->update($id, $validated);

        return redirect()->route('units.index')
            ->with('success', 'تم تحديث الوحدة بنجاح');
    }

    public function destroy(int $id): RedirectResponse
    {
        $this->unitRepository->delete($id);

        return redirect()->route('units.index')
            ->with('success', 'تم حذف الوحدة بنجاح');
    }
}
