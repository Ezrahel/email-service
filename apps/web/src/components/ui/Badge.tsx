import { clsx } from "clsx";

type BadgeVariant = "success" | "warning" | "danger" | "info" | "neutral";

interface BadgeProps {
  variant?: BadgeVariant;
  children: React.ReactNode;
  className?: string;
  dot?: boolean;
}

const variantStyles: Record<BadgeVariant, string> = {
  success: "bg-success/15 text-success",
  warning: "bg-warning/15 text-warning",
  danger: "bg-danger/15 text-danger",
  info: "bg-accent-glass text-accent",
  neutral: "bg-[rgba(0,0,0,0.04)] text-text-tertiary",
};

const dotColors: Record<BadgeVariant, string> = {
  success: "bg-success",
  warning: "bg-warning",
  danger: "bg-danger",
  info: "bg-accent",
  neutral: "bg-text-tertiary",
};

export function Badge({ variant = "neutral", children, className, dot }: BadgeProps) {
  return (
    <span
      className={clsx(
        "inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-[13px] font-medium",
        variantStyles[variant],
        className,
      )}
    >
      {dot && <span className={clsx("w-1.5 h-1.5 rounded-full", dotColors[variant])} />}
      {children}
    </span>
  );
}
