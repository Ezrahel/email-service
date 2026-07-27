import { clsx } from "clsx";

interface SkeletonProps {
  className?: string;
  count?: number;
}

export function Skeleton({ className, count = 1 }: SkeletonProps) {
  if (count > 1) {
    return (
      <>
        {Array.from({ length: count }).map((_, i) => (
          <div
            key={i}
            className={clsx(
              "glass-sm animate-pulse-soft",
              "bg-[rgba(0,0,0,0.03)]",
              className || "h-4 w-full",
            )}
          />
        ))}
      </>
    );
  }

  return (
    <div
      className={clsx(
        "glass-sm animate-pulse-soft",
        "bg-[rgba(0,0,0,0.03)]",
        className || "h-4 w-full",
      )}
    />
  );
}
