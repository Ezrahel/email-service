"use client";

import { useEffect, useCallback, useRef } from "react";
import { createPortal } from "react-dom";
import { clsx } from "clsx";
import { X } from "lucide-react";

interface ModalProps {
  open: boolean;
  onClose: () => void;
  title?: string;
  children: React.ReactNode;
  className?: string;
}

export function Modal({ open, onClose, title, children, className }: ModalProps) {
  const overlayRef = useRef<HTMLDivElement>(null);

  const handleEscape = useCallback(
    (e: KeyboardEvent) => {
      if (e.key === "Escape") onClose();
    },
    [onClose],
  );

  useEffect(() => {
    if (open) {
      document.addEventListener("keydown", handleEscape);
      document.body.style.overflow = "hidden";
    }
    return () => {
      document.removeEventListener("keydown", handleEscape);
      document.body.style.overflow = "";
    };
  }, [open, handleEscape]);

  const handleOverlayClick = (e: React.MouseEvent) => {
    if (e.target === overlayRef.current) onClose();
  };

  if (!open) return null;

  return createPortal(
    <div
      ref={overlayRef}
      onClick={handleOverlayClick}
      className="fixed inset-0 z-50 flex items-center justify-center bg-black/30 backdrop-blur-sm animate-fade-in"
    >
      <div
        className={clsx(
          "glass-lg w-full max-w-lg mx-4 p-6 relative animate-slide-up",
          className,
        )}
      >
        <button
          onClick={onClose}
          className="absolute top-4 right-4 p-1 rounded-lg text-text-tertiary hover:text-text-primary hover:bg-accent-glass transition-colors"
        >
          <X className="h-5 w-5" />
        </button>
        {title && (
          <h2 className="text-lg font-semibold text-text-primary mb-4 pr-8">
            {title}
          </h2>
        )}
        {children}
      </div>
    </div>,
    document.body,
  );
}
