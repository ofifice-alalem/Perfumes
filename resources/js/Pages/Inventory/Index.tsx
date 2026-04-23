import { Head, router } from '@inertiajs/react';
import { useState } from 'react';
import { AppShell } from '@/Components/Layout/AppShell';

interface Inventory {
    id: number;
    product_id: number;
    quantity: number;
    min_stock_level: number;
    is_low_stock: boolean;
    stock_status: string;
    stock_percentage: number;
    product: {
        id: number;
        name: string;
        sku: string;
        category: {
            name: string;
        };
    };
    unit: {
        symbol: string;
    };
}

interface Props {
    inventory: Inventory[];
}

export default function Index({ inventory }: Props) {
    const [adjusting, setAdjusting] = useState<number | null>(null);
    const [adjustType, setAdjustType] = useState<'add' | 'deduct'>('add');
    const [adjustQuantity, setAdjustQuantity] = useState('');

    const getStockColor = (status: string) => {
        const colors = {
            in_stock: 'text-green-600',
            low_stock: 'text-yellow-600',
            out_of_stock: 'text-red-600',
        };
        return colors[status as keyof typeof colors] || colors.in_stock;
    };

    const getProgressColor = (percentage: number) => {
        if (percentage >= 100) return 'bg-green-500';
        if (percentage >= 50) return 'bg-yellow-500';
        return 'bg-red-500';
    };

    const handleAdjust = async (productId: number) => {
        if (!adjustQuantity || parseFloat(adjustQuantity) <= 0) {
            alert('الرجاء إدخال كمية صحيحة');
            return;
        }

        try {
            await router.post(`/api/inventory/${productId}/adjust`, {
                type: adjustType,
                quantity: parseFloat(adjustQuantity),
            });
            setAdjusting(null);
            setAdjustQuantity('');
        } catch (error) {
            console.error('Error adjusting inventory:', error);
        }
    };

    return (
        <AppShell>
            <Head title="إدارة المخزون" />

            <div className="mb-6">
                <h1 className="text-3xl font-bold">إدارة المخزون</h1>
            </div>

                    {/* Stats */}
                    <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-6">
                        <div className="bg-white rounded-lg shadow p-6">
                            <div className="text-sm text-gray-600 mb-1">إجمالي المنتجات</div>
                            <div className="text-3xl font-bold text-gray-900">
                                {inventory.length}
                            </div>
                        </div>
                        <div className="bg-white rounded-lg shadow p-6">
                            <div className="text-sm text-gray-600 mb-1">مخزون منخفض</div>
                            <div className="text-3xl font-bold text-yellow-600">
                                {inventory.filter((i) => i.is_low_stock).length}
                            </div>
                        </div>
                        <div className="bg-white rounded-lg shadow p-6">
                            <div className="text-sm text-gray-600 mb-1">نفذ المخزون</div>
                            <div className="text-3xl font-bold text-red-600">
                                {inventory.filter((i) => i.stock_status === 'out_of_stock').length}
                            </div>
                        </div>
                    </div>

                    {/* Inventory Table */}
                    <div className="bg-white rounded-lg shadow overflow-hidden">
                        <table className="min-w-full divide-y divide-gray-200">
                            <thead className="bg-gray-50">
                                <tr>
                                    <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">
                                        المنتج
                                    </th>
                                    <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">
                                        SKU
                                    </th>
                                    <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">
                                        الكمية
                                    </th>
                                    <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">
                                        الحد الأدنى
                                    </th>
                                    <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">
                                        الحالة
                                    </th>
                                    <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">
                                        إجراءات
                                    </th>
                                </tr>
                            </thead>
                            <tbody className="bg-white divide-y divide-gray-200">
                                {inventory.map((item) => (
                                    <tr key={item.id}>
                                        <td className="px-6 py-4">
                                            <div className="text-sm font-medium text-gray-900">
                                                {item.product.name}
                                            </div>
                                            <div className="text-sm text-gray-500">
                                                {item.product.category.name}
                                            </div>
                                        </td>
                                        <td className="px-6 py-4 text-sm text-gray-900">
                                            {item.product.sku}
                                        </td>
                                        <td className="px-6 py-4">
                                            <div className="text-sm font-semibold text-gray-900">
                                                {item.quantity} {item.unit.symbol}
                                            </div>
                                            <div className="w-full bg-gray-200 rounded-full h-2 mt-1">
                                                <div
                                                    className={`h-2 rounded-full ${getProgressColor(
                                                        item.stock_percentage
                                                    )}`}
                                                    style={{
                                                        width: `${Math.min(item.stock_percentage, 100)}%`,
                                                    }}
                                                />
                                            </div>
                                        </td>
                                        <td className="px-6 py-4 text-sm text-gray-900">
                                            {item.min_stock_level} {item.unit.symbol}
                                        </td>
                                        <td className="px-6 py-4">
                                            <span
                                                className={`text-sm font-semibold ${getStockColor(
                                                    item.stock_status
                                                )}`}
                                            >
                                                {item.stock_status === 'in_stock' && 'متوفر'}
                                                {item.stock_status === 'low_stock' && 'منخفض'}
                                                {item.stock_status === 'out_of_stock' && 'نفذ'}
                                            </span>
                                        </td>
                                        <td className="px-6 py-4">
                                            {adjusting === item.product_id ? (
                                                <div className="flex gap-2">
                                                    <select
                                                        value={adjustType}
                                                        onChange={(e) =>
                                                            setAdjustType(e.target.value as 'add' | 'deduct')
                                                        }
                                                        className="text-sm rounded border-gray-300"
                                                    >
                                                        <option value="add">إضافة</option>
                                                        <option value="deduct">خصم</option>
                                                    </select>
                                                    <input
                                                        type="number"
                                                        step="0.01"
                                                        value={adjustQuantity}
                                                        onChange={(e) => setAdjustQuantity(e.target.value)}
                                                        className="w-20 text-sm rounded border-gray-300"
                                                        placeholder="الكمية"
                                                    />
                                                    <button
                                                        onClick={() => handleAdjust(item.product_id)}
                                                        className="bg-green-600 hover:bg-green-700 text-white px-3 py-1 rounded text-sm"
                                                    >
                                                        حفظ
                                                    </button>
                                                    <button
                                                        onClick={() => {
                                                            setAdjusting(null);
                                                            setAdjustQuantity('');
                                                        }}
                                                        className="bg-gray-300 hover:bg-gray-400 text-gray-700 px-3 py-1 rounded text-sm"
                                                    >
                                                        إلغاء
                                                    </button>
                                                </div>
                                            ) : (
                                                <button
                                                    onClick={() => setAdjusting(item.product_id)}
                                                    className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded text-sm"
                                                >
                                                    تعديل
                                                </button>
                                            )}
                                        </td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    </div>
        </AppShell>
    );
}
