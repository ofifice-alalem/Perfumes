import { ReactNode } from 'react';

interface SpatialCardProps {
  title: string;
  icon?: ReactNode;
  children: ReactNode;
  action?: ReactNode;
  headerDot?: boolean;
  hideHeader?: boolean;
  transparent?: boolean;
  className?: string;
}

export function SpatialCard({
  title,
  icon,
  children,
  action,
  headerDot = true,
  hideHeader = false,
  transparent = false,
  className = "",
}: SpatialCardProps) {
  return (
    <div className={`spatial-card ${transparent ? 'transparent' : ''} ${className}`}>
      <div className="p-4 lg:p-6 flex flex-col h-full">
        {!hideHeader && (
          <div className="flex items-center justify-between mb-6">
            <div className="flex items-center gap-3">
              {headerDot && (
                <span className="w-2 h-2 rounded-full bg-primary" />
              )}
              {icon && (
                <div className="text-slate-500 dark:text-white/70">{icon}</div>
              )}
              <h2 className="text-[17px] font-bold text-slate-800 dark:text-white tracking-wide transition-colors">
                {title}
              </h2>
            </div>
            {action && <div>{action}</div>}
          </div>
        )}
        <div className="flex-1 flex flex-col">{children}</div>
      </div>
    </div>
  );
}

interface ModernInputProps {
  label: string;
  type?: string;
  placeholder?: string;
  className?: string;
  value?: string;
  onChange?: (value: string) => void;
}

export function ModernInput({
  label,
  type = 'text',
  placeholder,
  className = '',
  value,
  onChange,
}: ModernInputProps) {
  return (
    <div className={`flex flex-col gap-2 ${className}`}>
      {label && (
        <label className="text-xs font-bold text-slate-700 dark:text-white/75 uppercase tracking-widest">
          {label}
        </label>
      )}
      <input
        type={type}
        placeholder={placeholder}
        {...(value !== undefined ? { value } : {})}
        onChange={(e) => onChange?.(e.target.value)}
        className="spatial-input h-14 rounded-[20px] px-5 text-[15px] font-bold w-full [appearance:textfield] [&::-webkit-outer-spin-button]:appearance-none [&::-webkit-inner-spin-button]:appearance-none"
      />
    </div>
  );
}
