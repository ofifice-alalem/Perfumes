import React from 'react';
import { Head, router } from '@inertiajs/react';
import { AppShell } from '@/Components/Layout/AppShell';

interface PriceTier {
    id: number;
    name: string;
    description: string | null;
    products_count: number;
    created_at: string;
}

interface Props {
    priceTiers: PriceTier[];
}

export default function Index({ priceTiers }: Props) {
    const handleDelete = (id: number) => {
        if (confirm('هل أنت متأكد من حذف مستوى السعر هذا؟')) {
            router.delete(`/price-tiers/${id}`);
        }
    };

    return (
        <AppShell>
            <Head title="مستويات الأسعار" />
            
            <div className="flex justify-between items-center mb-6">
                <h1 className="text-2xl font-bold">مستويات الأسعار</h1>
                <button
                    onClick={() => router.visit('/price-tiers/create')}
                    className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700"
                >
                    إضافة مستوى سعر
                </button>
            </div>

            <div className="bg-white dark:bg-white/5 rounded-lg shadow overflow-hidden">
                <table className="min-w-full divide-y divide-gray-200 dark:divide-white/10">
                    <thead className="bg-gray-50 dark:bg-white/5">
                        <tr>
                            <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">الاسم</th>
                            <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">الوصف</th>
                            <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">عدد المنتجات</th>
                            <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">الإجراءات</th>
                        </tr>
                    </thead>
                    <tbody className="divide-y divide-gray-200 dark:divide-white/10">
                        {priceTiers.map((tier) => (
                            <tr key={tier.id}>
                                <td className="px-6 py-4 whitespace-nowrap font-medium">{tier.name}</td>
                                <td className="px-6 py-4">{tier.description || '-'}</td>
                                <td className="px-6 py-4 whitespace-nowrap">{tier.products_count}</td>
                                <td className="px-6 py-4 whitespace-nowrap">
                                    <button
                                        onClick={() => router.visit(`/price-tiers/${tier.id}/edit`)}
                                        className="text-blue-600 hover:text-blue-900 ml-4"
                                    >
                                        تعديل
                                    </button>
                                    <button
                                        onClick={() => handleDelete(tier.id)}
                                        className="text-red-600 hover:text-red-900"
                                    >
                                        حذف
                                    </button>
                                </td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            </div>
        </AppShell>
    );
}
