import React, { useState } from 'react';
import { Head, router, useForm } from '@inertiajs/react';
import { AppShell } from '@/Components/Layout/AppShell';

interface Size {
    id: number;
    name: string;
    value: number;
    unit: {
        symbol: string;
    };
}

interface TierPrice {
    size_id: number;
    price: string;
}

interface PriceTier {
    id: number;
    name: string;
    description: string | null;
    tier_prices: TierPrice[];
}

interface Props {
    priceTier?: PriceTier;
    sizes: Size[];
}

export default function Form({ priceTier, sizes }: Props) {
    const { data, setData, post, put, processing, errors } = useForm({
        name: priceTier?.name || '',
        description: priceTier?.description || '',
        prices: sizes.reduce((acc, size) => {
            const existingPrice = priceTier?.tier_prices?.find(tp => tp.size_id === size.id);
            acc[size.id] = existingPrice?.price || '';
            return acc;
        }, {} as Record<number, string>),
    });

    const handleSubmit = (e: React.FormEvent) => {
        e.preventDefault();
        
        if (priceTier) {
            put(`/price-tiers/${priceTier.id}`);
        } else {
            post('/price-tiers');
        }
    };

    const handlePriceChange = (sizeId: number, value: string) => {
        setData('prices', {
            ...data.prices,
            [sizeId]: value,
        });
    };

    return (
        <AppShell>
            <Head title={priceTier ? 'تعديل مستوى السعر' : 'إضافة مستوى سعر'} />
            
            <div className="max-w-4xl mx-auto">
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
                            rows={3}
                            placeholder="وصف مستوى السعر..."
                        />
                        {errors.description && <p className="text-red-600 text-sm mt-1">{errors.description}</p>}
                    </div>

                    <div className="mb-6">
                        <h3 className="text-lg font-semibold mb-4">الأسعار حسب الحجم</h3>
                        <div className="bg-gray-50 dark:bg-white/5 rounded-lg p-4">
                            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                                {sizes.map((size) => (
                                    <div key={size.id} className="flex items-center gap-3">
                                        <label className="w-32 text-sm font-medium">
                                            {size.name} ({size.value}{size.unit.symbol})
                                        </label>
                                        <input
                                            type="number"
                                            step="0.01"
                                            value={data.prices[size.id] || ''}
                                            onChange={(e) => handlePriceChange(size.id, e.target.value)}
                                            className="flex-1 px-3 py-2 border rounded-lg dark:bg-white/10 dark:border-white/20"
                                            placeholder="0.00"
                                        />
                                        <span className="text-sm text-gray-500">ريال</span>
                                    </div>
                                ))}
                            </div>
                        </div>
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
