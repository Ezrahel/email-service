"use client";

import { useState } from "react";
import { clsx } from "clsx";
import { ChevronUp, ChevronDown } from "lucide-react";

interface Column {
  key: string;
  label: string;
  sortable?: boolean;
}

interface TableProps {
  columns: Column[];
  data: any[];
  onRowClick?: (row: any) => void;
  className?: string;
}

export function Table({ columns, data, onRowClick, className }: TableProps) {
  const [sortKey, setSortKey] = useState<string | null>(null);
  const [sortDir, setSortDir] = useState<"asc" | "desc">("asc");

  const handleSort = (key: string) => {
    if (sortKey === key) {
      setSortDir((d) => (d === "asc" ? "desc" : "asc"));
    } else {
      setSortKey(key);
      setSortDir("asc");
    }
  };

  const sorted = [...data].sort((a, b) => {
    if (!sortKey) return 0;
    const aVal = a[sortKey];
    const bVal = b[sortKey];
    if (aVal == null) return 1;
    if (bVal == null) return -1;
    const cmp = String(aVal).localeCompare(String(bVal), undefined, { numeric: true });
    return sortDir === "asc" ? cmp : -cmp;
  });

  return (
    <div className={clsx("overflow-x-auto", className)}>
      <table className="w-full border-collapse">
        <thead>
          <tr className="glass-sm">
            {columns.map((col) => (
              <th
                key={col.key}
                className={clsx(
                  "px-4 py-3 text-left text-[13px] font-medium text-text-secondary tracking-wide",
                  col.sortable && "cursor-pointer select-none hover:text-text-primary transition-colors",
                )}
                onClick={() => col.sortable && handleSort(col.key)}
              >
                <span className="inline-flex items-center gap-1">
                  {col.label}
                  {col.sortable && sortKey === col.key && (
                    sortDir === "asc" ? <ChevronUp className="h-3.5 w-3.5" /> : <ChevronDown className="h-3.5 w-3.5" />
                  )}
                </span>
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {sorted.map((row, i) => (
            <tr
              key={row.id ?? i}
              onClick={() => onRowClick?.(row)}
              className={clsx(
                "border-t border-[rgba(0,0,0,0.04)] transition-colors",
                onRowClick && "cursor-pointer",
                "hover:glass-sm",
              )}
            >
              {columns.map((col) => (
                <td key={col.key} className="px-4 py-3 text-[15px] text-text-primary">
                  {row[col.key]}
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
