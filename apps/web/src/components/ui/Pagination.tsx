"use client";

import { clsx } from "clsx";
import { ChevronLeft, ChevronRight } from "lucide-react";

interface PaginationProps {
  page: number;
  perPage: number;
  total: number;
  onChange: (page: number) => void;
}

export function Pagination({ page, perPage, total, onChange }: PaginationProps) {
  const totalPages = Math.max(1, Math.ceil(total / perPage));
  const from = total === 0 ? 0 : (page - 1) * perPage + 1;
  const to = Math.min(page * perPage, total);

  const getPages = (): (number | "...")[] => {
    if (totalPages <= 7) {
      return Array.from({ length: totalPages }, (_, i) => i + 1);
    }
    const pages: (number | "...")[] = [1];
    if (page > 3) pages.push("...");
    const start = Math.max(2, page - 1);
    const end = Math.min(totalPages - 1, page + 1);
    for (let i = start; i <= end; i++) pages.push(i);
    if (page < totalPages - 2) pages.push("...");
    pages.push(totalPages);
    return pages;
  };

  return (
    <div className="flex items-center justify-between gap-4">
      <span className="text-[13px] text-text-tertiary whitespace-nowrap">
        {from}–{to} of {total}
      </span>
      <div className="flex items-center gap-1">
        <button
          disabled={page <= 1}
          onClick={() => onChange(page - 1)}
          className={clsx(
            "p-2 rounded-lg transition-colors",
            page <= 1
              ? "text-text-tertiary cursor-not-allowed"
              : "text-text-secondary hover:text-text-primary hover:bg-accent-glass",
          )}
        >
          <ChevronLeft className="h-4 w-4" />
        </button>
        {getPages().map((p, i) =>
          p === "..." ? (
            <span key={`ellipsis-${i}`} className="px-2 text-[13px] text-text-tertiary">
              ...
            </span>
          ) : (
            <button
              key={p}
              onClick={() => onChange(p)}
              className={clsx(
                "min-w-[32px] h-8 rounded-lg text-[13px] font-medium transition-colors",
                p === page
                  ? "bg-accent text-white"
                  : "text-text-secondary hover:text-text-primary hover:bg-accent-glass",
              )}
            >
              {p}
            </button>
          ),
        )}
        <button
          disabled={page >= totalPages}
          onClick={() => onChange(page + 1)}
          className={clsx(
            "p-2 rounded-lg transition-colors",
            page >= totalPages
              ? "text-text-tertiary cursor-not-allowed"
              : "text-text-secondary hover:text-text-primary hover:bg-accent-glass",
          )}
        >
          <ChevronRight className="h-4 w-4" />
        </button>
      </div>
    </div>
  );
}
