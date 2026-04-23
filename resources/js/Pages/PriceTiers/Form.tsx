import React from 'react';
import { Head, router, useForm } from '@inertiajs/react';
import { AppShell } from '@/Components/Layout/AppShell';

interface PriceTier {
    id: number;
    name: string;
    description: string | null;
}

interface Props {
    priceTier?: PriceTier;
}

export default function Form({ priceTier }: Props) {
    const { data, setData, post, put, processing, errors } = useForm({
        name: priceTier?.name || '',
        description: priceTier?.description || '',
    });

    const handleSubmit = (e: React.FormEvent) => {
        e.preventDefault();
        
        if (priceTier) {
            put(`/price-tiers/${priceTier.id}`);
        } else {
            post('/price-tiers');
        }
    };

    return (
        <AppShell>
            <Head title={priceTier ? 'تعديل مستوى السعر' : 'إضافة مستوى سعر'} />
            
            <div className="max-w-2xl mx-auto">
                <h1 className="text-2xl font-bold mb-6">
                    {priceTier ? 'تعديل مستوى السعر' : 'إضافة مستوى سعر جديد'}
                </h1>

                <form onSubmit={handleSubmit} className="bg-white dark:bg-white/5 rounded-lg shadow p-6">
                    <div className="mb-4">
                        <label className="block text-sm font-medium mb-2">الاسم *</label>
                        <input
                            type="text"
                            value={data.name}
                            onChange={(e) => setData('name', e.target.value)}
                            className="w-full px-4 py-2 border rounded-lg dark:bg-white/10 dark:border-white/20"
                            placeholder="مثال: سعر الجملة"
                            required
                        />
                        {errors.name && <p className="text-red-600 text-sm mt-1">{errors.name}</p>}
                    </div>

                    <div className="mb-6">
                        <label className="block text-sm font-medium mb-2">الوصف</label>
                        <textarea
                            value={data.description}
                            onChange={(e) => setData('description', e.target.value)}
                            className="w-full px-4 py-2 border rounded-lg dark:bg-white/10 dark:border-white/20"
                            rows={4}
                            placeholder="وصف مستوى السعر..."
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
                            onClick={() => router.visit('/price-tiers')}
                            className="bg-gray-200 dark:bg-white/10 px-6 py-2 rounded-lg hover:bg-gray-300 dark:hover:bg-white/20"
                        >
                            إلغاء
                        </button>
                    </div>
                </form>
            </div>
        </AppShell>
    );
}
