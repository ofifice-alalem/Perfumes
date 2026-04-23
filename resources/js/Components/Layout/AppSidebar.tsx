import { Link } from '@inertiajs/react';
import { Home, Package, ShoppingCart, Users, Settings, FolderTree, Warehouse, Ruler, DollarSign, Maximize2, Tag } from 'lucide-react';

interface AppSidebarProps {
  isOpen: boolean;
  onToggle: () => void;
}

export function AppSidebar({ isOpen, onToggle }: AppSidebarProps) {
  const menuItems = [
    { icon: Home, label: 'الرئيسية', href: '/' },
    { icon: Ruler, label: 'الوحدات', href: '/units' },
    { icon: Maximize2, label: 'الأحجام', href: '/sizes' },
    { icon: FolderTree, label: 'التصنيفات', href: '/categories' },
    { icon: DollarSign, label: 'مستويات الأسعار', href: '/price-tiers' },
    { icon: Package, label: 'المنتجات', href: '/products' },
    { icon: Tag, label: 'أسعار المنتجات', href: '/product-pricing' },
    { icon: Warehouse, label: 'المخزون', href: '/inventory' },
    { icon: ShoppingCart, label: 'الطلبات', href: '/orders' },
    { icon: Users, label: 'العملاء', href: '/customers' },
    { icon: Settings, label: 'الإعدادات', href: '/settings' },
  ];

  return (
    <aside
      className={`
        fixed lg:relative top-0 right-0 h-full
        w-[280px] lg:w-[300px]
        bg-white/40 dark:bg-black/20
        backdrop-blur-3xl
        border-l border-black/10 dark:border-white/10
        transition-transform duration-300 ease-in-out
        z-[999] lg:z-auto
        ${isOpen ? 'translate-x-0' : 'translate-x-full lg:translate-x-0'}
      `}
    >
      <div className="flex flex-col h-full p-6">
        {/* Logo */}
        <div className="flex items-center justify-between mb-10">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-2xl bg-primary flex items-center justify-center">
              <Package className="w-5 h-5 text-white" />
            </div>
            <span className="font-black text-xl text-slate-800 dark:text-white">Perfumes</span>
          </div>
          <button
            onClick={onToggle}
            className="lg:hidden w-8 h-8 rounded-lg bg-black/5 dark:bg-white/10 flex items-center justify-center"
          >
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5">
              <path d="M18 6 6 18M6 6l12 12" />
            </svg>
          </button>
        </div>

        {/* Menu */}
        <nav className="flex-1 space-y-2">
          {menuItems.map((item) => (
            <Link
              key={item.href}
              href={item.href}
              className="flex items-center gap-3 px-4 h-12 rounded-[16px] font-bold text-[15px] text-slate-600 dark:text-white/70 hover:bg-black/5 dark:hover:bg-white/10 hover:text-slate-900 dark:hover:text-white transition-all"
            >
              <item.icon className="w-5 h-5" />
              {item.label}
            </Link>
          ))}
        </nav>

        {/* User */}
        <div className="pt-4 border-t border-black/10 dark:border-white/10">
          <div className="flex items-center gap-3 px-4 py-3 rounded-[16px] bg-black/5 dark:bg-white/5">
            <div className="w-10 h-10 rounded-full bg-primary flex items-center justify-center text-white font-bold">
              A
            </div>
            <div className="flex-1 min-w-0">
              <div className="font-bold text-sm text-slate-800 dark:text-white truncate">المسؤول</div>
              <div className="text-xs text-slate-500 dark:text-white/60 truncate">admin@perfumes.com</div>
            </div>
          </div>
        </div>
      </div>
    </aside>
  );
}
