import { AppShell } from '@/Components/Layout/AppShell';
import { SpatialCard } from '@/Components/UI/SpatialComponents';
import { Package, TrendingUp, Users, ShoppingCart } from 'lucide-react';

export default function Dashboard() {
  const stats = [
    { icon: Package, label: 'إجمالي العطور', value: '156', color: 'text-blue-500' },
    { icon: ShoppingCart, label: 'الطلبات اليوم', value: '24', color: 'text-green-500' },
    { icon: Users, label: 'العملاء', value: '89', color: 'text-purple-500' },
    { icon: TrendingUp, label: 'المبيعات', value: '12,450 ر.س', color: 'text-orange-500' },
  ];

  return (
    <AppShell>
      <div className="flex flex-col gap-6">
        <div>
          <h1 className="text-2xl font-black text-slate-800 dark:text-white mb-2">لوحة التحكم</h1>
          <p className="text-slate-600 dark:text-white/60 font-bold">مرحباً بك في نظام إدارة العطور</p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
          {stats.map((stat) => (
            <SpatialCard key={stat.label} title={stat.label} hideHeader>
              <div className="flex items-center justify-between">
                <div>
                  <div className="text-3xl font-black text-slate-800 dark:text-white mb-1">
                    {stat.value}
                  </div>
                  <div className="text-sm font-bold text-slate-500 dark:text-white/60">
                    {stat.label}
                  </div>
                </div>
                <div className={`w-14 h-14 rounded-2xl bg-black/5 dark:bg-white/5 flex items-center justify-center ${stat.color}`}>
                  <stat.icon className="w-7 h-7" />
                </div>
              </div>
            </SpatialCard>
          ))}
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <SpatialCard title="آخر الطلبات" icon={<ShoppingCart className="w-4 h-4" />}>
            <div className="space-y-3">
              {[1, 2, 3].map((i) => (
                <div key={i} className="flex items-center justify-between p-3 rounded-2xl bg-black/5 dark:bg-white/5">
                  <div>
                    <div className="font-bold text-slate-800 dark:text-white">طلب #{1000 + i}</div>
                    <div className="text-sm text-slate-500 dark:text-white/60">منذ {i} ساعة</div>
                  </div>
                  <div className="text-primary font-black">450 ر.س</div>
                </div>
              ))}
            </div>
          </SpatialCard>

          <SpatialCard title="العطور الأكثر مبيعاً" icon={<TrendingUp className="w-4 h-4" />}>
            <div className="space-y-3">
              {['عطر الورد', 'عطر العود', 'عطر المسك'].map((name, i) => (
                <div key={i} className="flex items-center justify-between p-3 rounded-2xl bg-black/5 dark:bg-white/5">
                  <div className="flex items-center gap-3">
                    <div className="w-10 h-10 rounded-xl bg-primary/10 flex items-center justify-center">
                      <Package className="w-5 h-5 text-primary" />
                    </div>
                    <div className="font-bold text-slate-800 dark:text-white">{name}</div>
                  </div>
                  <div className="text-sm font-bold text-slate-500 dark:text-white/60">{45 - i * 5} مبيعة</div>
                </div>
              ))}
            </div>
          </SpatialCard>
        </div>
      </div>
    </AppShell>
  );
}
