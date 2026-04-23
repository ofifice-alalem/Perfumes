import { Head, useForm, router } from '@inertiajs/react';

interface Category {
    id: number;
    name: string;
}

interface Unit {
    id: number;
    name: string;
    symbol: string;
}

interface Props {
    categories: Category[];
    units: Unit[];
}

export default function Create({ categories, units }: Props) {
    const { data, setData, post, processing, errors } = useForm({
        name: '',
        sku: '',
        category_id: '',
        price_tier_id: '1',
        selling_type: 'BOTH',
        is_returnable: true,
        inventory: {
            quantity: 0,
            min_stock_level: 0,
            unit_id: '',
        },
    });

    const handleSubmit = (e: React.FormEvent) => {
        e.preventDefault();
        post('/api/products');
    };

    return (
        <>
            <Head title="إضافة منتج جديد" />

            <div className="py-12">
                <div className="max-w-3xl mx-auto sm:px-6 lg:px-8">
                    <div className="bg-white rounded-lg shadow p-6">
                        <h1 className="text-2xl font-bold text-gray-900 mb-6">
                            إضافة منتج جديد
                        </h1>

                        <form onSubmit={handleSubmit} className="space-y-6">
                            {/* Name */}
                            <div>
                                <label className="block text-sm font-medium text-gray-700 mb-2">
                                    اسم المنتج *
                                </label>
                                <input
                                    type="text"
                                    value={data.name}
                                    onChange={(e) => setData('name', e.target.value)}
                                    className="w-full rounded-lg border-gray-300 focus:border-blue-500 focus:ring-blue-500"
                                    required
                                />
                                {errors.name && (
                                    <p className="mt-1 text-sm text-red-600">{errors.name}</p>
                                )}
                            </div>

                            {/* SKU */}
                            <div>
                                <label className="block text-sm font-medium text-gray-700 mb-2">
                                    رمز المنتج (SKU)
                                </label>
                                <input
                                    type="text"
                                    value={data.sku}
                                    onChange={(e) => setData('sku', e.target.value)}
                                    className="w-full rounded-lg border-gray-300 focus:border-blue-500 focus:ring-blue-500"
                                    placeholder="سيتم توليده تلقائياً إذا ترك فارغاً"
                                />
                                {errors.sku && (
                                    <p className="mt-1 text-sm text-red-600">{errors.sku}</p>
                                )}
                            </div>

                            {/* Category */}
                            <div>
                                <label className="block text-sm font-medium text-gray-700 mb-2">
                                    التصنيف *
                                </label>
                                <select
                                    value={data.category_id}
                                    onChange={(e) => setData('category_id', e.target.value)}
                                    className="w-full rounded-lg border-gray-300 focus:border-blue-500 focus:ring-blue-500"
                                    required
                                >
                                    <option value="">اختر التصنيف</option>
                                    {categories.map((category) => (
                                        <option key={category.id} value={category.id}>
                                            {category.name}
                                        </option>
                                    ))}
                                </select>
                                {errors.category_id && (
                                    <p className="mt-1 text-sm text-red-600">{errors.category_id}</p>
                                )}
                            </div>

                            {/* Selling Type */}
                            <div>
                                <label className="block text-sm font-medium text-gray-700 mb-2">
                                    نوع البيع *
                                </label>
                                <select
                                    value={data.selling_type}
                                    onChange={(e) => setData('selling_type', e.target.value)}
                                    className="w-full rounded-lg border-gray-300 focus:border-blue-500 focus:ring-blue-500"
                                    required
                                >
                                    <option value="DECANT_ONLY">تعبئة فقط</option>
                                    <option value="FULL_ONLY">زجاجة كاملة فقط</option>
                                    <option value="BOTH">كلاهما</option>
                                    <option value="UNIT_BASED">بالوحدة</option>
                                </select>
                                {errors.selling_type && (
                                    <p className="mt-1 text-sm text-red-600">{errors.selling_type}</p>
                                )}
                            </div>

                            {/* Is Returnable */}
                            <div className="flex items-center">
                                <input
                                    type="checkbox"
                                    checked={data.is_returnable}
                                    onChange={(e) => setData('is_returnable', e.target.checked)}
                                    className="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
                                />
                                <label className="mr-2 text-sm text-gray-700">
                                    قابل للإرجاع
                                </label>
                            </div>

                            {/* Inventory Section */}
                            <div className="border-t pt-6">
                                <h2 className="text-lg font-semibold text-gray-900 mb-4">
                                    معلومات المخزون
                                </h2>

                                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                                    {/* Quantity */}
                                    <div>
                                        <label className="block text-sm font-medium text-gray-700 mb-2">
                                            الكمية الأولية
                                        </label>
                                        <input
                                            type="number"
                                            step="0.01"
                                            value={data.inventory.quantity}
                                            onChange={(e) =>
                                                setData('inventory', {
                                                    ...data.inventory,
                                                    quantity: parseFloat(e.target.value) || 0,
                                                })
                                            }
                                            className="w-full rounded-lg border-gray-300 focus:border-blue-500 focus:ring-blue-500"
                                        />
                                    </div>

                                    {/* Min Stock Level */}
                                    <div>
                                        <label className="block text-sm font-medium text-gray-700 mb-2">
                                            الحد الأدنى للمخزون
                                        </label>
                                        <input
                                            type="number"
                                            step="0.01"
                                            value={data.inventory.min_stock_level}
                                            onChange={(e) =>
                                                setData('inventory', {
                                                    ...data.inventory,
                                                    min_stock_level: parseFloat(e.target.value) || 0,
                                                })
                                            }
                                            className="w-full rounded-lg border-gray-300 focus:border-blue-500 focus:ring-blue-500"
                                        />
                                    </div>

                                    {/* Unit */}
                                    <div>
                                        <label className="block text-sm font-medium text-gray-700 mb-2">
                                            وحدة القياس *
                                        </label>
                                        <select
                                            value={data.inventory.unit_id}
                                            onChange={(e) =>
                                                setData('inventory', {
                                                    ...data.inventory,
                                                    unit_id: e.target.value,
                                                })
                                            }
                                            className="w-full rounded-lg border-gray-300 focus:border-blue-500 focus:ring-blue-500"
                                            required
                                        >
                                            <option value="">اختر الوحدة</option>
                                            {units.map((unit) => (
                                                <option key={unit.id} value={unit.id}>
                                                    {unit.name} ({unit.symbol})
                                                </option>
                                            ))}
                                        </select>
                                    </div>
                                </div>
                            </div>

                            {/* Actions */}
                            <div className="flex gap-4 pt-6">
                                <button
                                    type="submit"
                                    disabled={processing}
                                    className="flex-1 bg-blue-600 hover:bg-blue-700 text-white px-6 py-3 rounded-lg disabled:opacity-50"
                                >
                                    {processing ? 'جاري الحفظ...' : 'حفظ المنتج'}
                                </button>
                                <button
                                    type="button"
                                    onClick={() => router.visit('/products')}
                                    className="px-6 py-3 border border-gray-300 rounded-lg hover:bg-gray-50"
                                >
                                    إلغاء
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </>
    );
}
