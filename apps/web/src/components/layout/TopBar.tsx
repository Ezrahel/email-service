"use client";

import { usePathname } from "next/navigation";
import { clsx } from "clsx";
import { useState, useRef, useEffect } from "react";
import { LogOut } from "lucide-react";

function capitalize(s: string) {
  return s.charAt(0).toUpperCase() + s.slice(1);
}

export function TopBar() {
  const pathname = usePathname();
  const segments = pathname.split("/").filter(Boolean);

  const [menuOpen, setMenuOpen] = useState(false);
  const menuRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    function handleClickOutside(e: MouseEvent) {
      if (menuRef.current && !menuRef.current.contains(e.target as Node)) {
        setMenuOpen(false);
      }
    }
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  return (
    <header className="glass-sm sticky top-0 z-30 flex items-center justify-between h-14 px-6 border-b border-[rgba(0,0,0,0.06)]">
      <nav className="flex items-center gap-1.5 text-[15px]">
        {segments.map((seg, i) => (
          <span key={i} className="flex items-center gap-1.5">
            {i > 0 && (
              <span className="text-text-tertiary select-none">/</span>
            )}
            <span
              className={clsx(
                i === segments.length - 1
                  ? "text-text-primary font-medium"
                  : "text-text-secondary",
              )}
            >
              {capitalize(seg.replace(/-/g, " "))}
            </span>
          </span>
        ))}
      </nav>

      <div className="relative" ref={menuRef}>
        <button
          onClick={() => setMenuOpen((o) => !o)}
          className="flex items-center justify-center w-9 h-9 rounded-full bg-accent text-white text-[15px] font-semibold hover:opacity-90 transition-opacity"
        >
          JD
        </button>

        {menuOpen && (
          <div className="absolute right-0 top-full mt-2 w-44 glass-sm py-1 z-50">
            <button className="flex items-center gap-2 w-full px-3 py-2 text-[14px] text-text-secondary hover:bg-accent-glass transition-colors">
              <LogOut className="w-4 h-4" />
              Sign Out
            </button>
          </div>
        )}
      </div>
    </header>
  );
}
