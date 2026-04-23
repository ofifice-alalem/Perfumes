import React from 'react';
import { Head, router } from '@inertiajs/react';
import { AppShell } from '@/Components/Layout/AppShell';

interface Size {
    id: number;
    name: string;
    value: number;
    unit: {
        name: string;
        symbol: string;
    };
    created_at: string;
}

interface Props {
    sizes: Size[];
}

export default function Index({ sizes }: Props) {
    const handleDelete = (id: number) => {
        if (confirm('هل أنت متأكد من حذف هذا الحجم؟')) {
            router.delete(`/sizes/${id}`);
        }
    };

    return (
        <AppShell>
            <Head title="الأحجام" />
            
            <div className="flex justify-between items-center mb-6">
                <h1 className="text-2xl font-bold">الأحجام</h1>
                <button
                    onClick={() => router.visit('/sizes/create')}
                    className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700"
                >
                    إضافة حجم
                </button>
            </div>

            <div className="bg-white dark:bg-white/5 rounded-lg shadow overflow-hidden">
                <table className="min-w-full divide-y divide-gray-200 dark:divide-white/10">
                    <thead className="bg-gray-50 dark:bg-white/5">
                        <tr>
                            <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">الاسم</th>
                            <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">القيمة</th>
                            <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">الوحدة</th>
                            <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">الإجراءات</th>
                        </tr>
                    </thead>
                    <tbody className="divide-y divide-gray-200 dark:divide-white/10">
                        {sizes.map((size) => (
                            <tr key={size.id}>
                                <td className="px-6 py-4 whitespace-nowrap font-medium">{size.name}</td>
                                <td className="px-6 py-4 whitespace-nowrap">{size.value} {size.unit.symbol}</td>
                                <td className="px-6 py-4 whitespace-nowrap">{size.unit.name}</td>
                                <td className="px-6 py-4 whitespace-nowrap">
                                    <button
                                        onClick={() => router.visit(`/sizes/${size.id}/edit`)}
                                        className="text-blue-600 hover:text-blue-900 ml-4"
                                    >
                                        تعديل
                                    </button>
                                    <button
                                        onClick={() => handleDelete(size.id)}
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
