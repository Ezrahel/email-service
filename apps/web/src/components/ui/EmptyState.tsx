"use client";

import { clsx } from "clsx";
import { Inbox } from "lucide-react";
import { Button } from "./Button";

interface EmptyStateProps {
  icon?: React.ReactNode;
  title: string;
  description?: string;
  action?: {
    label: string;
    onClick: () => void;
  };
}

export function EmptyState({ icon, title, description, action }: EmptyStateProps) {
  return (
    <div className="flex flex-col items-center justify-center py-16 px-4">
      <div className="glass p-8 flex flex-col items-center text-center max-w-sm">
        <div className="mb-4 text-text-tertiary">
          {icon ?? <Inbox className="h-10 w-10" />}
        </div>
        <h3 className="text-[17px] font-semibold text-text-primary mb-1">
          {title}
        </h3>
        {description && (
          <p className="text-[14px] text-text-secondary leading-relaxed mb-5">
            {description}
          </p>
        )}
        {action && (
          <Button variant="secondary" onClick={action.onClick}>
            {action.label}
          </Button>
        )}
      </div>
    </div>
  );
}
