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

interface PriceTier {
    id: number;
    name: string;
    description: string | null;
}

interface TierPrice {
    tier_id: number;
    size_id: number;
    price: string;
}

interface UnitBasedPrice {
    tier_id: number;
    price_per_unit: string;
}

interface Product {
    id: number;
    name: string;
    sku: string;
    selling_type: string;
    category: {
        name: string;
        unit: {
            name: string;
            symbol: string;
        };
    };
    tier_prices?: TierPrice[];
    unit_based_prices?: UnitBasedPrice[];
}

interface Props {
    product: Product;
    priceTiers: PriceTier[];
    sizes?: Size[];
}

export default function Edit({ product, priceTiers, sizes }: Props) {
    const isUnitBased = product.selling_type === 'UNIT_BASED';
    
    const { data, setData, post, processing, errors } = useForm({
        prices: isUnitBased
            ? priceTiers.reduce((acc, tier) => {
                const existing = product.unit_based_prices?.find(p => p.tier_id === tier.id);
                acc[tier.id] = existing?.price_per_unit || '';
                return acc;
            }, {} as Record<number, string>)
            : priceTiers.reduce((acc, tier) => {
                acc[tier.id] = sizes?.reduce((sizeAcc, size) => {
                    const existing = product.tier_prices?.find(
                        p => p.tier_id === tier.id && p.size_id === size.id
                    );
                    sizeAcc[size.id] = existing?.price || '';
                    return sizeAcc;
                }, {} as Record<number, string>) || {};
                return acc;
            }, {} as Record<number, Record<number, string>>),
    });

    const handleSubmit = (e: React.FormEvent) => {
        e.preventDefault();
        post(`/product-pricing/${product.id}`);
    };

    const handleUnitPriceChange = (tierId: number, value: string) => {
        setData('prices', {
            ...data.prices,
            [tierId]: value,
        });
    };

    const handleSizePriceChange = (tierId: number, sizeId: number, value: string) => {
        setData('prices', {
            ...data.prices,
            [tierId]: {
                ...(data.prices[tierId] as Record<number, string>),
                [sizeId]: value,
            },
        });
    };

    return (
        <AppShell>
            <Head title={`تحديد أسعار - ${product.name}`} />
            
            <div className="max-w-5xl mx-auto">
                <div className="mb-6">
                    <h1 className="text-2xl font-bold">{product.name}</h1>
                    <p className="text-gray-600 dark:text-gray-400">
                        {product.sku} • {product.category.name}
                    </p>
                </div>

                <form onSubmit={handleSubmit} className="bg-white dark:bg-white/5 rounded-lg shadow p-6">
                    {isUnitBased ? (
                        // Unit Based Pricing (للبخور/الوشق)
                        <div>
                            <h3 className="text-lg font-semibold mb-4">
                                الأسعار بالوحدة ({product.category.unit.name})
                            </h3>
                            <div className="space-y-4">
                                {priceTiers.map((tier) => (
                                    <div key={tier.id} className="flex items-center gap-4 p-4 bg-gray-50 dark:bg-white/5 rounded-lg">
                                        <div className="flex-1">
                                            <label className="font-medium">{tier.name}</label>
                                            {tier.description && (
                                                <p className="text-sm text-gray-500">{tier.description}</p>
                                            )}
                                        </div>
                                        <div className="flex items-center gap-2">
                                            <input
                                                type="number"
                                                step="0.01"
                                                value={data.prices[tier.id] || ''}
                                                onChange={(e) => handleUnitPriceChange(tier.id, e.target.value)}
                                                className="w-32 px-3 py-2 border rounded-lg dark:bg-white/10 dark:border-white/20"
                                                placeholder="0.00"
                                            />
                                            <span className="text-sm text-gray-600">
                                                ريال/{product.category.unit.symbol}
                                            </span>
                                        </div>
                                    </div>
                                ))}
                            </div>
                        </div>
                    ) : (
                        // Size Based Pricing (للعطور)
                        <div>
                            <h3 className="text-lg font-semibold mb-4">الأسعار حسب الحجم</h3>
                            {priceTiers.map((tier) => (
                                <div key={tier.id} className="mb-6">
                                    <h4 className="font-medium mb-3 text-blue-600">{tier.name}</h4>
                                    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3">
                                        {sizes?.map((size) => (
                                            <div key={size.id} className="flex items-center gap-2 p-3 bg-gray-50 dark:bg-white/5 rounded-lg">
                                                <label className="w-24 text-sm font-medium">
                                                    {size.name}
                                                </label>
                                                <input
                                                    type="number"
                                                    step="0.01"
                                                    value={(data.prices[tier.id] as Record<number, string>)?.[size.id] || ''}
                                                    onChange={(e) => handleSizePriceChange(tier.id, size.id, e.target.value)}
                                                    className="flex-1 px-3 py-2 border rounded-lg dark:bg-white/10 dark:border-white/20 text-sm"
                                                    placeholder="0.00"
                                                />
                                                <span className="text-xs text-gray-500">ريال</span>
                                            </div>
                                        ))}
                                    </div>
                                </div>
                            ))}
                        </div>
                    )}

                    <div className="flex gap-4 mt-6 pt-6 border-t dark:border-white/10">
                        <button
                            type="submit"
                            disabled={processing}
                            className="bg-blue-600 text-white px-6 py-2 rounded-lg hover:bg-blue-700 disabled:opacity-50"
                        >
                            {processing ? 'جاري الحفظ...' : 'حفظ الأسعار'}
                        </button>
                        <button
                            type="button"
                            onClick={() => router.visit('/product-pricing')}
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
