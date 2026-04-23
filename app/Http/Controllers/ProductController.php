<?php

declare(strict_types=1);

namespace App\Http\Controllers;

use App\Http\Requests\StoreProductRequest;
use App\Http\Requests\UpdateProductRequest;
use App\Repositories\Contracts\CategoryRepositoryInterface;
use App\Repositories\Contracts\ProductRepositoryInterface;
use App\Repositories\Contracts\UnitRepositoryInterface;
use App\Services\ProductService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

final class ProductController extends Controller
{
    public function __construct(
        private readonly ProductRepositoryInterface $productRepository,
        private readonly ProductService $productService,
        private readonly CategoryRepositoryInterface $categoryRepository,
        private readonly UnitRepositoryInterface $unitRepository
    ) {}

    public function index(Request $request): Response
    {
        $products = $this->productRepository->paginate(
            perPage: 12,
            search: $request->input('search'),
            categoryId: $request->input('category_id') ? (int) $request->input('category_id') : null
        );

        $categories = $this->categoryRepository->all();

        return Inertia::render('Products/Index', [
            'products' => $products,
            'categories' => $categories,
        ]);
    }

    public function create(): Response
    {
        $categories = $this->categoryRepository->all();
        $units = $this->unitRepository->all();

        return Inertia::render('Products/Create', [
            'categories' => $categories,
            'units' => $units,
        ]);
    }

    public function store(StoreProductRequest $request): RedirectResponse
    {
        $this->productService->createProduct($request->validated());

        return redirect()->route('products.index')
            ->with('success', 'تم إضافة المنتج بنجاح');
    }

    public function edit(int $id): Response
    {
        $product = $this->productRepository->findOrFail($id);
        $categories = $this->categoryRepository->all();
        $units = $this->unitRepository->all();

        return Inertia::render('Products/Create', [
            'product' => $product,
            'categories' => $categories,
            'units' => $units,
        ]);
    }

    public function update(UpdateProductRequest $request, int $id): RedirectResponse
    {
        $this->productService->updateProduct($id, $request->validated());

        return redirect()->route('products.index')
            ->with('success', 'تم تحديث المنتج بنجاح');
    }

    public function destroy(int $id): RedirectResponse
    {
        $this->productRepository->delete($id);

        return redirect()->route('products.index')
            ->with('success', 'تم حذف المنتج بنجاح');
    }
}
