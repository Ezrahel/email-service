"use client";

import { useState, useCallback } from "react";
import { clsx } from "clsx";
import { Copy, Check } from "lucide-react";

interface CopyButtonProps {
  value: string;
  className?: string;
}

export function CopyButton({ value, className }: CopyButtonProps) {
  const [copied, setCopied] = useState(false);

  const handleCopy = useCallback(async () => {
    try {
      await navigator.clipboard.writeText(value);
      setCopied(true);
      setTimeout(() => setCopied(false), 1500);
    } catch {
      // silently fail
    }
  }, [value]);

  return (
    <button
      onClick={handleCopy}
      className={clsx(
        "p-1.5 rounded-lg transition-colors",
        copied
          ? "text-success"
          : "text-text-tertiary hover:text-text-primary hover:bg-accent-glass",
        className,
      )}
      title="Copy to clipboard"
    >
      {copied ? <Check className="h-4 w-4" /> : <Copy className="h-4 w-4" />}
    </button>
  );
}
