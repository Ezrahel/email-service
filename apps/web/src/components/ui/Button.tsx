import { forwardRef } from "react";
import { clsx } from "clsx";
import { Loader2 } from "lucide-react";

type Variant = "primary" | "secondary" | "ghost" | "danger";
type Size = "sm" | "md" | "lg";

interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: Variant;
  size?: Size;
  loading?: boolean;
  icon?: React.ReactNode;
}

const variantStyles: Record<Variant, string> = {
  primary: "bg-accent text-white hover:bg-accent-hover shadow-sm",
  secondary: "glass-sm text-text-primary hover:bg-accent-glass active:scale-[0.98]",
  ghost: "bg-transparent text-text-secondary hover:bg-accent-glass",
  danger: "bg-danger text-white hover:opacity-90",
};

const sizeStyles: Record<Size, string> = {
  sm: "px-3 py-1.5 text-[13px] gap-1.5",
  md: "px-4 py-2 text-[15px] gap-2",
  lg: "px-6 py-2.5 text-[17px] gap-2",
};

export const Button = forwardRef<HTMLButtonElement, ButtonProps>(
  ({ variant = "primary", size = "md", loading, icon, className, children, disabled, ...props }, ref) => (
    <button
      ref={ref}
      disabled={disabled || loading}
      className={clsx(
        "inline-flex items-center justify-center font-medium rounded-[10px] transition-all duration-200",
        "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-accent focus-visible:ring-offset-2",
        "disabled:opacity-50 disabled:cursor-not-allowed",
        variantStyles[variant],
        sizeStyles[size],
        className,
      )}
      {...props}
    >
      {loading ? <Loader2 className="h-4 w-4 animate-spin" /> : icon}
      {children}
    </button>
  ),
);
Button.displayName = "Button";
