interface Inventory {
    id: number;
    product_id: number;
    quantity: number;
    min_stock_level: number;
    is_low_stock: boolean;
    stock_status: string;
    stock_percentage: number;
    product: {
        name: string;
        sku: string;
    };
    unit: {
        symbol: string;
    };
}

interface Props {
    inventory: Inventory[];
    onAdjust?: (productId: number) => void;
}

export default function InventoryTable({ inventory, onAdjust }: Props) {
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

    return (
        <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-gray-200">
                <thead className="bg-gray-50">
                    <tr>
                        <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                            المنتج
                        </th>
                        <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                            SKU
                        </th>
                        <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                            الكمية
                        </th>
                        <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                            الحد الأدنى
                        </th>
                        <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                            الحالة
                        </th>
                        {onAdjust && (
                            <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                                إجراءات
                            </th>
                        )}
                    </tr>
                </thead>
                <tbody className="bg-white divide-y divide-gray-200">
                    {inventory.map((item) => (
                        <tr key={item.id} className="hover:bg-gray-50">
                            <td className="px-6 py-4 whitespace-nowrap">
                                <div className="text-sm font-medium text-gray-900">
                                    {item.product.name}
                                </div>
                            </td>
                            <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                                {item.product.sku}
                            </td>
                            <td className="px-6 py-4 whitespace-nowrap">
                                <div className="text-sm font-semibold text-gray-900">
                                    {item.quantity} {item.unit.symbol}
                                </div>
                                <div className="w-full bg-gray-200 rounded-full h-2 mt-1">
                                    <div
                                        className={`h-2 rounded-full transition-all ${getProgressColor(
                                            item.stock_percentage
                                        )}`}
                                        style={{
                                            width: `${Math.min(item.stock_percentage, 100)}%`,
                                        }}
                                    />
                                </div>
                            </td>
                            <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                                {item.min_stock_level} {item.unit.symbol}
                            </td>
                            <td className="px-6 py-4 whitespace-nowrap">
                                <span className={`text-sm font-semibold ${getStockColor(item.stock_status)}`}>
                                    {item.stock_status === 'in_stock' && 'متوفر'}
                                    {item.stock_status === 'low_stock' && 'منخفض'}
                                    {item.stock_status === 'out_of_stock' && 'نفذ'}
                                </span>
                            </td>
                            {onAdjust && (
                                <td className="px-6 py-4 whitespace-nowrap text-sm">
                                    <button
                                        onClick={() => onAdjust(item.product_id)}
                                        className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded transition-colors"
                                    >
                                        تعديل
                                    </button>
                                </td>
                            )}
                        </tr>
                    ))}
                </tbody>
            </table>
        </div>
    );
}
