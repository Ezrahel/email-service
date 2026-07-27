"use client";

import { clsx } from "clsx";

interface SelectOption {
  value: string;
  label: string;
}

interface SelectProps {
  label?: string;
  options: SelectOption[];
  value: string;
  onChange: (value: string) => void;
  error?: string;
  placeholder?: string;
}

export function Select({ label, options, value, onChange, error, placeholder }: SelectProps) {
  const selectId = label?.toLowerCase().replace(/\s+/g, "-");

  return (
    <div className="flex flex-col gap-1.5">
      {label && (
        <label htmlFor={selectId} className="text-[13px] font-medium text-text-secondary">
          {label}
        </label>
      )}
      <select
        id={selectId}
        value={value}
        onChange={(e) => onChange(e.target.value)}
        className={clsx(
          "input-glass w-full px-3.5 py-2.5 text-[15px] text-text-primary appearance-none",
          "focus:outline-none transition-all duration-200",
          "bg-[url('data:image/svg+xml;charset=utf-8,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%2216%22%20height%3D%2216%22%20fill%3D%22none%22%20stroke%3D%22%236e6e73%22%20stroke-width%3D%222%22%3E%3Cpath%20d%3D%22m4%206%204%204%204-4%22%2F%3E%3C%2Fsvg%3E')] bg-no-repeat bg-[right_12px_center] pr-10",
          !value && placeholder && "text-text-tertiary",
          error && "border-danger/50 focus:border-danger focus:ring-danger/20",
        )}
      >
        {placeholder && (
          <option value="" disabled>
            {placeholder}
          </option>
        )}
        {options.map((opt) => (
          <option key={opt.value} value={opt.value}>
            {opt.label}
          </option>
        ))}
      </select>
      {error && <span className="text-[13px] text-danger">{error}</span>}
    </div>
  );
}
