import React from 'react';
import { Head, router, useForm } from '@inertiajs/react';
import { AppShell } from '@/Components/Layout/AppShell';

interface Unit {
    id: number;
    name: string;
    symbol: string;
}

interface Props {
    unit?: Unit;
}

export default function Form({ unit }: Props) {
    const { data, setData, post, put, processing, errors } = useForm({
        name: unit?.name || '',
        symbol: unit?.symbol || '',
    });

    const handleSubmit = (e: React.FormEvent) => {
        e.preventDefault();
        
        if (unit) {
            put(`/units/${unit.id}`);
        } else {
            post('/units');
        }
    };

    return (
        <AppShell>
            <Head title={unit ? 'تعديل الوحدة' : 'إضافة وحدة'} />
            
            <div className="max-w-2xl mx-auto">
                <h1 className="text-2xl font-bold mb-6">
                    {unit ? 'تعديل الوحدة' : 'إضافة وحدة جديدة'}
                </h1>

                <form onSubmit={handleSubmit} className="bg-white dark:bg-white/5 rounded-lg shadow p-6">
                    <div className="mb-4">
                        <label className="block text-sm font-medium mb-2">الاسم *</label>
                        <input
                            type="text"
                            value={data.name}
                            onChange={(e) => setData('name', e.target.value)}
                            className="w-full px-4 py-2 border rounded-lg dark:bg-white/10 dark:border-white/20"
                            required
                        />
                        {errors.name && <p className="text-red-600 text-sm mt-1">{errors.name}</p>}
                    </div>

                    <div className="mb-6">
                        <label className="block text-sm font-medium mb-2">الرمز *</label>
                        <input
                            type="text"
                            value={data.symbol}
                            onChange={(e) => setData('symbol', e.target.value)}
                            className="w-full px-4 py-2 border rounded-lg dark:bg-white/10 dark:border-white/20"
                            required
                        />
                        {errors.symbol && <p className="text-red-600 text-sm mt-1">{errors.symbol}</p>}
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
                            onClick={() => router.visit('/units')}
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
