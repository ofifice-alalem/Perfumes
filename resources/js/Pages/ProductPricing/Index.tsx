import React from 'react';
import { Head, router } from '@inertiajs/react';
import { AppShell } from '@/Components/Layout/AppShell';

interface Product {
    id: number;
    name: string;
    sku: string;
    selling_type: string;
    category: {
        name: string;
    };
    has_prices: boolean;
}

interface Props {
    products: Product[];
}

export default function Index({ products }: Props) {
    const getSellingTypeLabel = (type: string) => {
        const labels: Record<string, string> = {
            'DECANT_ONLY': 'تقسيم فقط',
            'FULL_ONLY': 'قارورة كاملة',
            'BOTH': 'تقسيم وقارورة',
            'UNIT_BASED': 'بالوحدة (غرام/قطعة)',
        };
        return labels[type] || type;
    };

    const getSellingTypeBadge = (type: string) => {
        const badges: Record<string, string> = {
            'DECANT_ONLY': 'bg-blue-100 text-blue-800',
            'FULL_ONLY': 'bg-green-100 text-green-800',
            'BOTH': 'bg-purple-100 text-purple-800',
            'UNIT_BASED': 'bg-orange-100 text-orange-800',
        };
        return badges[type] || 'bg-gray-100 text-gray-800';
    };

    return (
        <AppShell>
            <Head title="إدارة أسعار المنتجات" />
            
            <div className="mb-6">
                <h1 className="text-2xl font-bold">إدارة أسعار المنتجات</h1>
                <p className="text-gray-600 dark:text-gray-400 mt-2">
                    قم بتحديد أسعار المنتجات حسب نوع البيع (تقسيم أو بالوحدة)
                </p>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                {products.map((product) => (
                    <div
                        key={product.id}
                        className="bg-white dark:bg-white/5 rounded-lg shadow p-4 hover:shadow-lg transition-shadow"
                    >
                        <div className="flex justify-between items-start mb-3">
                            <div>
                                <h3 className="font-semibold text-lg">{product.name}</h3>
                                <p className="text-sm text-gray-600 dark:text-gray-400">
                                    {product.sku}
                                </p>
                                <p className="text-xs text-gray-500 dark:text-gray-500 mt-1">
                                    {product.category.name}
                                </p>
                            </div>
                            {product.has_prices && (
                                <span className="text-green-600 text-xs">✓ محدد</span>
                            )}
                        </div>

                        <div className="mb-4">
                            <span className={`inline-block px-3 py-1 rounded-full text-xs font-medium ${getSellingTypeBadge(product.selling_type)}`}>
                                {getSellingTypeLabel(product.selling_type)}
                            </span>
                        </div>

                        <button
                            onClick={() => router.visit(`/product-pricing/${product.id}`)}
                            className="w-full bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 text-sm"
                        >
                            {product.has_prices ? 'تعديل الأسعار' : 'تحديد الأسعار'}
                        </button>
                    </div>
                ))}
            </div>

            {products.length === 0 && (
                <div className="text-center py-12 bg-white dark:bg-white/5 rounded-lg">
                    <p className="text-gray-500">لا توجد منتجات متاحة</p>
                </div>
            )}
        </AppShell>
    );
}
