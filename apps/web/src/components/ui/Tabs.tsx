"use client";

import { clsx } from "clsx";

interface Tab {
  id: string;
  label: string;
}

interface TabsProps {
  tabs: Tab[];
  active: string;
  onChange: (id: string) => void;
}

export function Tabs({ tabs, active, onChange }: TabsProps) {
  return (
    <div className="glass inline-flex p-1 gap-1">
      {tabs.map((tab) => (
        <button
          key={tab.id}
          onClick={() => onChange(tab.id)}
          className={clsx(
            "relative px-4 py-2 text-[14px] font-medium rounded-lg transition-colors",
            active === tab.id
              ? "text-text-primary"
              : "text-text-secondary hover:text-text-primary",
          )}
        >
          {tab.label}
          {active === tab.id && (
            <span className="absolute bottom-0 left-1/2 -translate-x-1/2 w-6 h-0.5 bg-accent rounded-full" />
          )}
        </button>
      ))}
    </div>
  );
}
