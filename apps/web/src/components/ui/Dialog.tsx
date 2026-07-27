"use client";

import { clsx } from "clsx";
import { Modal } from "./Modal";
import { Button } from "./Button";

interface DialogProps {
  open: boolean;
  onClose: () => void;
  title: string;
  message: string;
  confirmLabel?: string;
  cancelLabel?: string;
  variant?: "danger" | "default";
  onConfirm: () => void;
  loading?: boolean;
}

export function Dialog({
  open,
  onClose,
  title,
  message,
  confirmLabel = "Confirm",
  cancelLabel = "Cancel",
  variant = "default",
  onConfirm,
  loading,
}: DialogProps) {
  return (
    <Modal open={open} onClose={onClose} title={title}>
      <p className="text-[15px] text-text-secondary leading-relaxed mb-6">
        {message}
      </p>
      <div className="flex items-center justify-end gap-3">
        <Button variant="secondary" onClick={onClose} disabled={loading}>
          {cancelLabel}
        </Button>
        <Button
          variant={variant === "danger" ? "danger" : "primary"}
          onClick={onConfirm}
          loading={loading}
        >
          {confirmLabel}
        </Button>
      </div>
    </Modal>
  );
}
