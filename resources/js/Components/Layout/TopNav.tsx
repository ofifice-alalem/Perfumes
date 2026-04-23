import { Bell, Moon, Sun } from 'lucide-react';

interface TopNavProps {
  isDark: boolean;
  onToggleTheme: () => void;
}

export function TopNav({ isDark, onToggleTheme }: TopNavProps) {
  return (
    <div className="flex items-center justify-between mb-8">
      <div className="flex items-center gap-3">
        <div className="hidden lg:block w-2 h-2 rounded-full bg-primary animate-pulse" />
        <span className="text-sm font-bold text-slate-500 dark:text-white/60">
          {new Date().toLocaleDateString('ar-SA', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' })}
        </span>
      </div>

      <div className="flex items-center gap-2">
        <button className="spatial-icon-btn">
          <Bell className="w-5 h-5" />
        </button>
        <button onClick={onToggleTheme} className="spatial-icon-btn">
          {isDark ? <Sun className="w-5 h-5" /> : <Moon className="w-5 h-5" />}
        </button>
      </div>
    </div>
  );
}
