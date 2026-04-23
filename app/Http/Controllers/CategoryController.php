<?php

declare(strict_types=1);

namespace App\Http\Controllers;

use App\Http\Requests\StoreCategoryRequest;
use App\Http\Requests\UpdateCategoryRequest;
use App\Repositories\Contracts\CategoryRepositoryInterface;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

final class CategoryController extends Controller
{
    public function __construct(
        private readonly CategoryRepositoryInterface $categoryRepository
    ) {}

    public function index(Request $request): Response
    {
        $categories = $this->categoryRepository->paginate(
            perPage: 15,
            search: $request->input('search')
        );

        return Inertia::render('Categories/Index', [
            'categories' => $categories,
        ]);
    }

    public function create(): Response
    {
        return Inertia::render('Categories/Form');
    }

    public function store(StoreCategoryRequest $request): RedirectResponse
    {
        $this->categoryRepository->create($request->validated());

        return redirect()->route('categories.index')
            ->with('success', 'تم إضافة التصنيف بنجاح');
    }

    public function edit(int $id): Response
    {
        $category = $this->categoryRepository->findOrFail($id);

        return Inertia::render('Categories/Form', [
            'category' => $category,
        ]);
    }

    public function update(UpdateCategoryRequest $request, int $id): RedirectResponse
    {
        $this->categoryRepository->update($id, $request->validated());

        return redirect()->route('categories.index')
            ->with('success', 'تم تحديث التصنيف بنجاح');
    }

    public function destroy(int $id): RedirectResponse
    {
        $this->categoryRepository->delete($id);

        return redirect()->route('categories.index')
            ->with('success', 'تم حذف التصنيف بنجاح');
    }
}
