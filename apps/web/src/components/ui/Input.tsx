import { forwardRef } from "react";
import { clsx } from "clsx";

interface InputProps extends React.InputHTMLAttributes<HTMLInputElement> {
  label?: string;
  error?: string;
  hint?: string;
}

export const Input = forwardRef<HTMLInputElement, InputProps>(
  ({ label, error, hint, className, id, ...props }, ref) => {
    const inputId = id || label?.toLowerCase().replace(/\s+/g, "-");
    return (
      <div className="flex flex-col gap-1.5">
        {label && (
          <label htmlFor={inputId} className="text-[13px] font-medium text-text-secondary">
            {label}
          </label>
        )}
        <input
          ref={ref}
          id={inputId}
          className={clsx(
            "input-glass w-full px-3.5 py-2.5 text-[15px] text-text-primary placeholder:text-text-tertiary",
            "focus:outline-none transition-all duration-200",
            error && "border-danger/50 focus:border-danger focus:ring-danger/20",
            className,
          )}
          {...props}
        />
        {error && <span className="text-[13px] text-danger">{error}</span>}
        {hint && !error && <span className="text-[13px] text-text-tertiary">{hint}</span>}
      </div>
    );
  },
);
Input.displayName = "Input";
