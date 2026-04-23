import { Head, Link, router } from '@inertiajs/react';
import { useState } from 'react';

interface Product {
    id: number;
    name: string;
    sku: string;
    selling_type: string;
    is_returnable: boolean;
    category: {
        id: number;
        name: string;
    };
    inventory: {
        quantity: number;
        is_low_stock: boolean;
        stock_status: string;
    };
    primary_image: string | null;
}

interface Props {
    products: {
        data: Product[];
        meta: {
            current_page: number;
            last_page: number;
            per_page: number;
            total: number;
        };
    };
}

export default function Index({ products }: Props) {
    const [search, setSearch] = useState('');

    const handleSearch = (e: React.FormEvent) => {
        e.preventDefault();
        router.get('/products', { search }, { preserveState: true });
    };

    const getStockBadge = (status: string) => {
        const badges = {
            in_stock: 'bg-green-100 text-green-800',
            low_stock: 'bg-yellow-100 text-yellow-800',
            out_of_stock: 'bg-red-100 text-red-800',
        };
        return badges[status as keyof typeof badges] || badges.in_stock;
    };

    const getStockText = (status: string) => {
        const texts = {
            in_stock: 'متوفر',
            low_stock: 'مخزون منخفض',
            out_of_stock: 'نفذ المخزون',
        };
        return texts[status as keyof typeof texts] || 'غير معروف';
    };

    return (
        <>
            <Head title="المنتجات" />

            <div className="py-12">
                <div className="max-w-7xl mx-auto sm:px-6 lg:px-8">
                    {/* Header */}
                    <div className="mb-6 flex justify-between items-center">
                        <h1 className="text-3xl font-bold text-gray-900">المنتجات</h1>
                        <Link
                            href="/products/create"
                            className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg"
                        >
                            إضافة منتج جديد
                        </Link>
                    </div>

                    {/* Search */}
                    <div className="mb-6 bg-white rounded-lg shadow p-4">
                        <form onSubmit={handleSearch} className="flex gap-4">
                            <input
                                type="text"
                                value={search}
                                onChange={(e) => setSearch(e.target.value)}
                                placeholder="البحث عن منتج..."
                                className="flex-1 rounded-lg border-gray-300 focus:border-blue-500 focus:ring-blue-500"
                            />
                            <button
                                type="submit"
                                className="bg-gray-600 hover:bg-gray-700 text-white px-6 py-2 rounded-lg"
                            >
                                بحث
                            </button>
                        </form>
                    </div>

                    {/* Products Grid */}
                    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                        {products.data.map((product) => (
                            <div
                                key={product.id}
                                className="bg-white rounded-lg shadow hover:shadow-lg transition-shadow"
                            >
                                {/* Image */}
                                <div className="h-48 bg-gray-200 rounded-t-lg overflow-hidden">
                                    {product.primary_image ? (
                                        <img
                                            src={product.primary_image}
                                            alt={product.name}
                                            className="w-full h-full object-cover"
                                        />
                                    ) : (
                                        <div className="w-full h-full flex items-center justify-center text-gray-400">
                                            <svg className="w-16 h-16" fill="currentColor" viewBox="0 0 20 20">
                                                <path d="M4 3a2 2 0 00-2 2v10a2 2 0 002 2h12a2 2 0 002-2V5a2 2 0 00-2-2H4zm12 12H4l4-8 3 6 2-4 3 6z" />
                                            </svg>
                                        </div>
                                    )}
                                </div>

                                {/* Content */}
                                <div className="p-4">
                                    <div className="flex justify-between items-start mb-2">
                                        <h3 className="text-lg font-semibold text-gray-900">
                                            {product.name}
                                        </h3>
                                        <span
                                            className={`px-2 py-1 text-xs rounded-full ${getStockBadge(
                                                product.inventory.stock_status
                                            )}`}
                                        >
                                            {getStockText(product.inventory.stock_status)}
                                        </span>
                                    </div>

                                    <p className="text-sm text-gray-600 mb-2">
                                        SKU: {product.sku}
                                    </p>

                                    <p className="text-sm text-gray-600 mb-2">
                                        التصنيف: {product.category.name}
                                    </p>

                                    <p className="text-sm text-gray-600 mb-4">
                                        الكمية: {product.inventory.quantity}
                                    </p>

                                    {/* Actions */}
                                    <div className="flex gap-2">
                                        <Link
                                            href={`/products/${product.id}`}
                                            className="flex-1 bg-blue-600 hover:bg-blue-700 text-white text-center px-4 py-2 rounded-lg text-sm"
                                        >
                                            عرض
                                        </Link>
                                        <Link
                                            href={`/products/${product.id}/edit`}
                                            className="flex-1 bg-gray-600 hover:bg-gray-700 text-white text-center px-4 py-2 rounded-lg text-sm"
                                        >
                                            تعديل
                                        </Link>
                                    </div>
                                </div>
                            </div>
                        ))}
                    </div>

                    {/* Pagination */}
                    {products.meta.last_page > 1 && (
                        <div className="mt-6 flex justify-center gap-2">
                            {Array.from({ length: products.meta.last_page }, (_, i) => i + 1).map(
                                (page) => (
                                    <Link
                                        key={page}
                                        href={`/products?page=${page}`}
                                        className={`px-4 py-2 rounded-lg ${
                                            page === products.meta.current_page
                                                ? 'bg-blue-600 text-white'
                                                : 'bg-white text-gray-700 hover:bg-gray-100'
                                        }`}
                                    >
                                        {page}
                                    </Link>
                                )
                            )}
                        </div>
                    )}
                </div>
            </div>
        </>
    );
}
