import React, { useState } from 'react';
import { Head, router } from '@inertiajs/react';
import { AppShell } from '@/Components/Layout/AppShell';

interface Category {
    id: number;
    name: string;
    description: string | null;
    products_count: number;
    created_at: string;
}

interface Props {
    categories: {
        data: Category[];
        current_page: number;
        last_page: number;
        per_page: number;
        total: number;
    };
}

export default function Index({ categories }: Props) {
    const [search, setSearch] = useState('');

    const handleSearch = (e: React.FormEvent) => {
        e.preventDefault();
        router.get('/categories', { search }, { preserveState: true });
    };

    const handleDelete = (id: number) => {
        if (confirm('هل أنت متأكد من حذف هذا التصنيف؟')) {
            router.delete(`/categories/${id}`);
        }
    };

    return (
        <AppShell>
            <Head title="التصنيفات" />
            
            <div className="p-6">
                <div className="flex justify-between items-center mb-6">
                    <h1 className="text-2xl font-bold">التصنيفات</h1>
                    <button
                        onClick={() => router.visit('/categories/create')}
                        className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700"
                    >
                        إضافة تصنيف
                    </button>
                </div>

                <form onSubmit={handleSearch} className="mb-6">
                    <input
                        type="text"
                        value={search}
                        onChange={(e) => setSearch(e.target.value)}
                        placeholder="البحث عن تصنيف..."
                        className="w-full px-4 py-2 border rounded-lg"
                    />
                </form>

                <div className="bg-white rounded-lg shadow overflow-hidden">
                    <table className="min-w-full divide-y divide-gray-200">
                        <thead className="bg-gray-50">
                            <tr>
                                <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">الاسم</th>
                                <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">الوصف</th>
                                <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">عدد المنتجات</th>
                                <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">الإجراءات</th>
                            </tr>
                        </thead>
                        <tbody className="bg-white divide-y divide-gray-200">
                            {categories.data.map((category) => (
                                <tr key={category.id}>
                                    <td className="px-6 py-4 whitespace-nowrap">{category.name}</td>
                                    <td className="px-6 py-4">{category.description || '-'}</td>
                                    <td className="px-6 py-4 whitespace-nowrap">{category.products_count}</td>
                                    <td className="px-6 py-4 whitespace-nowrap">
                                        <button
                                            onClick={() => router.visit(`/categories/${category.id}/edit`)}
                                            className="text-blue-600 hover:text-blue-900 ml-4"
                                        >
                                            تعديل
                                        </button>
                                        <button
                                            onClick={() => handleDelete(category.id)}
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

                {categories.last_page > 1 && (
                    <div className="mt-4 flex justify-center gap-2">
                        {Array.from({ length: categories.last_page }, (_, i) => i + 1).map((page) => (
                            <button
                                key={page}
                                onClick={() => router.get('/categories', { page })}
                                className={`px-3 py-1 rounded ${
                                    page === categories.current_page
                                        ? 'bg-blue-600 text-white'
                                        : 'bg-gray-200 hover:bg-gray-300'
                                }`}
                            >
                                {page}
                            </button>
                        ))}
                    </div>
                )}
            </div>
        </AppShell>
    );
}
