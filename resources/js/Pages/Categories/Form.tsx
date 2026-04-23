import React from 'react';
import { Head, router, useForm } from '@inertiajs/react';
import { AppShell } from '@/Components/Layout/AppShell';

interface Category {
    id: number;
    name: string;
    description: string | null;
}

interface Props {
    category?: Category;
}

export default function Form({ category }: Props) {
    const { data, setData, post, put, processing, errors } = useForm({
        name: category?.name || '',
        description: category?.description || '',
    });

    const handleSubmit = (e: React.FormEvent) => {
        e.preventDefault();
        
        if (category) {
            put(`/categories/${category.id}`);
        } else {
            post('/categories');
        }
    };

    return (
        <AppShell>
            <Head title={category ? 'تعديل التصنيف' : 'إضافة تصنيف'} />
            
            <div className="p-6">
                <div className="max-w-2xl mx-auto">
                    <h1 className="text-2xl font-bold mb-6">
                        {category ? 'تعديل التصنيف' : 'إضافة تصنيف جديد'}
                    </h1>

                    <form onSubmit={handleSubmit} className="bg-white rounded-lg shadow p-6">
                        <div className="mb-4">
                            <label className="block text-sm font-medium mb-2">الاسم *</label>
                            <input
                                type="text"
                                value={data.name}
                                onChange={(e) => setData('name', e.target.value)}
                                className="w-full px-4 py-2 border rounded-lg"
                                required
                            />
                            {errors.name && <p className="text-red-600 text-sm mt-1">{errors.name}</p>}
                        </div>

                        <div className="mb-6">
                            <label className="block text-sm font-medium mb-2">الوصف</label>
                            <textarea
                                value={data.description}
                                onChange={(e) => setData('description', e.target.value)}
                                className="w-full px-4 py-2 border rounded-lg"
                                rows={4}
                            />
                            {errors.description && <p className="text-red-600 text-sm mt-1">{errors.description}</p>}
                        </div>

                        <div className="flex gap-4">
                            <button
                                type="submit"
                                disabled={processing}
                                className="bg-blue-600 text-white px-6 py-2 rounded-lg hover:bg-blue-700 disabled:opacity-50"
                            >
                                {processing ? 'جاري الحفظ...' : 'حفظ'}
                            </button>
                            <button
                                type="button"
                                onClick={() => router.visit('/categories')}
                                className="bg-gray-200 px-6 py-2 rounded-lg hover:bg-gray-300"
                            >
                                إلغاء
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </AppShell>
    );
}
