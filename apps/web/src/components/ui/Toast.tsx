"use client";

import {
  createContext,
  useContext,
  useState,
  useCallback,
  useEffect,
  useRef,
} from "react";
import { clsx } from "clsx";
import { CheckCircle, XCircle, AlertTriangle, Info, X } from "lucide-react";

type ToastType = "success" | "error" | "info" | "warning";

interface ToastItem {
  id: string;
  type: ToastType;
  title: string;
  message?: string;
  duration: number;
}

interface ToastInput {
  type: ToastType;
  title: string;
  message?: string;
  duration?: number;
}

interface ToastContextValue {
  toast: (props: ToastInput) => void;
}

const ToastContext = createContext<ToastContextValue | null>(null);

const iconMap: Record<ToastType, React.ReactNode> = {
  success: <CheckCircle className="h-5 w-5 text-success" />,
  error: <XCircle className="h-5 w-5 text-danger" />,
  info: <Info className="h-5 w-5 text-accent" />,
  warning: <AlertTriangle className="h-5 w-5 text-warning" />,
};

const typeStyles: Record<ToastType, string> = {
  success: "border-l-success/40",
  error: "border-l-danger/40",
  info: "border-l-accent/20",
  warning: "border-l-warning/40",
};

let toastId = 0;

function ToastCard({ item, onRemove }: { item: ToastItem; onRemove: (id: string) => void }) {
  const [progress, setProgress] = useState(100);
  const startRef = useRef(Date.now());
  const remainingRef = useRef(item.duration);
  const timerRef = useRef<ReturnType<typeof setInterval> | null>(null);

  const startTimer = useCallback(() => {
    startRef.current = Date.now();
    timerRef.current = setInterval(() => {
      const elapsed = Date.now() - startRef.current;
      const remaining = Math.max(0, remainingRef.current - elapsed);
      setProgress((remaining / item.duration) * 100);
      if (remaining <= 0) {
        onRemove(item.id);
      }
    }, 16);
  }, [item.duration, item.id, onRemove]);

  useEffect(() => {
    startTimer();
    return () => {
      if (timerRef.current) clearInterval(timerRef.current);
    };
  }, [startTimer]);

  return (
    <div
      className={clsx(
        "glass-sm flex items-start gap-3 p-4 min-w-[320px] max-w-[400px] relative overflow-hidden border-l-4",
        "animate-slide-up",
        typeStyles[item.type],
      )}
    >
      <div className="mt-0.5 shrink-0">{iconMap[item.type]}</div>
      <div className="flex-1 min-w-0">
        <p className="text-[14px] font-medium text-text-primary">{item.title}</p>
        {item.message && (
          <p className="text-[13px] text-text-secondary mt-0.5">{item.message}</p>
        )}
      </div>
      <button
        onClick={() => onRemove(item.id)}
        className="shrink-0 p-0.5 rounded text-text-tertiary hover:text-text-primary transition-colors"
      >
        <X className="h-4 w-4" />
      </button>
      <span
        className="absolute bottom-0 left-0 h-0.5 bg-accent/20 transition-all duration-100 ease-linear"
        style={{ width: `${progress}%` }}
      />
    </div>
  );
}

export function ToastContainer({ items, onRemove }: { items: ToastItem[]; onRemove: (id: string) => void }) {
  if (items.length === 0) return null;
  return (
    <div className="fixed bottom-6 right-6 z-[60] flex flex-col gap-3">
      {items.map((item) => (
        <ToastCard key={item.id} item={item} onRemove={onRemove} />
      ))}
    </div>
  );
}

export function ToastProvider({ children }: { children: React.ReactNode }) {
  const [items, setItems] = useState<ToastItem[]>([]);

  const toast = useCallback(({ type, title, message, duration = 4000 }: ToastInput) => {
    const id = String(++toastId);
    setItems((prev) => [...prev, { id, type, title, message, duration }]);
  }, []);

  const remove = useCallback((id: string) => {
    setItems((prev) => prev.filter((t) => t.id !== id));
  }, []);

  return (
    <ToastContext.Provider value={{ toast }}>
      {children}
      <ToastContainer items={items} onRemove={remove} />
    </ToastContext.Provider>
  );
}

export function useToast(): ToastContextValue {
  const ctx = useContext(ToastContext);
  if (!ctx) throw new Error("useToast must be used within a ToastProvider");
  return ctx;
}
