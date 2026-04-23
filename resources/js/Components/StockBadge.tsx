interface Props {
    status: 'in_stock' | 'low_stock' | 'out_of_stock';
    className?: string;
}

export default function StockBadge({ status, className = '' }: Props) {
    const config = {
        in_stock: {
            bg: 'bg-green-100',
            text: 'text-green-800',
            label: 'متوفر',
        },
        low_stock: {
            bg: 'bg-yellow-100',
            text: 'text-yellow-800',
            label: 'مخزون منخفض',
        },
        out_of_stock: {
            bg: 'bg-red-100',
            text: 'text-red-800',
            label: 'نفذ المخزون',
        },
    };

    const { bg, text, label } = config[status];

    return (
        <span
            className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${bg} ${text} ${className}`}
        >
            {label}
        </span>
    );
}
