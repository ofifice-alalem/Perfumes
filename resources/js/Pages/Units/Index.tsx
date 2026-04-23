import React, { useState } from 'react';
import { Head, router } from '@inertiajs/react';
import { AppShell } from '@/Components/Layout/AppShell';

interface Unit {
    id: number;
    name: string;
    symbol: string;
    created_at: string;
}

interface Props {
    units: Unit[];
}

export default function Index({ units }: Props) {
    const [search, setSearch] = useState('');

    const handleDelete = (id: number) => {
        if (confirm('هل أنت متأكد من حذف هذه الوحدة؟')) {
            router.delete(`/units/${id}`);
        }
    };

    return (
        <AppShell>
            <Head title="الوحدات" />
            
            <div className="flex justify-between items-center mb-6">
                <h1 className="text-2xl font-bold">الوحدات</h1>
                <button
                    onClick={() => router.visit('/units/create')}
                    className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700"
                >
                    إضافة وحدة
                </button>
            </div>

            <div className="bg-white dark:bg-white/5 rounded-lg shadow overflow-hidden">
                <table className="min-w-full divide-y divide-gray-200 dark:divide-white/10">
                    <thead className="bg-gray-50 dark:bg-white/5">
                        <tr>
                            <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">الاسم</th>
                            <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">الرمز</th>
                            <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">الإجراءات</th>
                        </tr>
                    </thead>
                    <tbody className="divide-y divide-gray-200 dark:divide-white/10">
                        {units.map((unit) => (
                            <tr key={unit.id}>
                                <td className="px-6 py-4 whitespace-nowrap">{unit.name}</td>
                                <td className="px-6 py-4 whitespace-nowrap">{unit.symbol}</td>
                                <td className="px-6 py-4 whitespace-nowrap">
                                    <button
                                        onClick={() => router.visit(`/units/${unit.id}/edit`)}
                                        className="text-blue-600 hover:text-blue-900 ml-4"
                                    >
                                        تعديل
                                    </button>
                                    <button
                                        onClick={() => handleDelete(unit.id)}
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
