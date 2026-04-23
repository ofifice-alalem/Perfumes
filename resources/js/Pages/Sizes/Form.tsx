import React from 'react';
import { Head, router, useForm } from '@inertiajs/react';
import { AppShell } from '@/Components/Layout/AppShell';

interface Unit {
    id: number;
    name: string;
    symbol: string;
}

interface Size {
    id: number;
    name: string;
    value: number;
    unit_id: number;
}

interface Props {
    size?: Size;
    units: Unit[];
}

export default function Form({ size, units }: Props) {
    const { data, setData, post, put, processing, errors } = useForm({
        name: size?.name || '',
        value: size?.value || '',
        unit_id: size?.unit_id || '',
    });

    const handleSubmit = (e: React.FormEvent) => {
        e.preventDefault();
        
        if (size) {
            put(`/sizes/${size.id}`);
        } else {
            post('/sizes');
        }
    };

    return (
        <AppShell>
            <Head title={size ? 'تعديل الحجم' : 'إضافة حجم'} />
            
            <div className="max-w-2xl mx-auto">
                <h1 className="text-2xl font-bold mb-6">
                    {size ? 'تعديل الحجم' : 'إضافة حجم جديد'}
                </h1>

                <form onSubmit={handleSubmit} className="bg-white dark:bg-white/5 rounded-lg shadow p-6">
                    <div className="mb-4">
                        <label className="block text-sm font-medium mb-2">الاسم *</label>
                        <input
                            type="text"
                            value={data.name}
                            onChange={(e) => setData('name', e.target.value)}
                            className="w-full px-4 py-2 border rounded-lg dark:bg-white/10 dark:border-white/20"
                            placeholder="مثال: 3 مل"
                            required
                        />
                        {errors.name && <p className="text-red-600 text-sm mt-1">{errors.name}</p>}
                    </div>

                    <div className="mb-4">
                        <label className="block text-sm font-medium mb-2">القيمة *</label>
                        <input
                            type="number"
                            step="0.01"
                            value={data.value}
                            onChange={(e) => setData('value', e.target.value)}
                            className="w-full px-4 py-2 border rounded-lg dark:bg-white/10 dark:border-white/20"
                            placeholder="3"
                            required
                        />
                        {errors.value && <p className="text-red-600 text-sm mt-1">{errors.value}</p>}
                    </div>

                    <div className="mb-6">
                        <label className="block text-sm font-medium mb-2">الوحدة *</label>
                        <select
                            value={data.unit_id}
                            onChange={(e) => setData('unit_id', e.target.value)}
                            className="w-full px-4 py-2 border rounded-lg dark:bg-white/10 dark:border-white/20"
                            required
                        >
                            <option value="">اختر الوحدة</option>
                            {units.map((unit) => (
                                <option key={unit.id} value={unit.id}>
                                    {unit.name} ({unit.symbol})
                                </option>
                            ))}
                        </select>
                        {errors.unit_id && <p className="text-red-600 text-sm mt-1">{errors.unit_id}</p>}
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
                            onClick={() => router.visit('/sizes')}
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
