import { Link } from '@inertiajs/react';
import StockBadge from './StockBadge';

interface Product {
    id: number;
    name: string;
    sku: string;
    category: {
        name: string;
    };
    inventory: {
        quantity: number;
        stock_status: 'in_stock' | 'low_stock' | 'out_of_stock';
    };
    primary_image: string | null;
}

interface Props {
    product: Product;
}

export default function ProductCard({ product }: Props) {
    return (
        <div className="bg-white rounded-lg shadow hover:shadow-lg transition-shadow overflow-hidden">
            {/* Image */}
            <div className="h-48 bg-gray-200 overflow-hidden">
                {product.primary_image ? (
                    <img
                        src={product.primary_image}
                        alt={product.name}
                        className="w-full h-full object-cover"
                    />
                ) : (
                    <div className="w-full h-full flex items-center justify-center text-gray-400">
                        <svg className="w-16 h-16" fill="currentColor" viewBox="0 0 20 20">
                            <path d="M4 3a2 2 0 00-2 2v10a2 2 0 002 2h12a2 2 0 002-2V5a2 2 0 00-2-2H4zm12 12H4l4-8 3 6 2-4 3 6z" />
                        </svg>
                    </div>
                )}
            </div>

            {/* Content */}
            <div className="p-4">
                <div className="flex justify-between items-start mb-2">
                    <h3 className="text-lg font-semibold text-gray-900 line-clamp-1">
                        {product.name}
                    </h3>
                    <StockBadge status={product.inventory.stock_status} />
                </div>

                <p className="text-sm text-gray-600 mb-1">SKU: {product.sku}</p>
                <p className="text-sm text-gray-600 mb-1">
                    التصنيف: {product.category.name}
                </p>
                <p className="text-sm text-gray-600 mb-4">
                    الكمية: {product.inventory.quantity}
                </p>

                {/* Actions */}
                <div className="flex gap-2">
                    <Link
                        href={`/products/${product.id}`}
                        className="flex-1 bg-blue-600 hover:bg-blue-700 text-white text-center px-4 py-2 rounded-lg text-sm transition-colors"
                    >
                        عرض
                    </Link>
                    <Link
                        href={`/products/${product.id}/edit`}
                        className="flex-1 bg-gray-600 hover:bg-gray-700 text-white text-center px-4 py-2 rounded-lg text-sm transition-colors"
                    >
                        تعديل
                    </Link>
                </div>
            </div>
        </div>
    );
}
