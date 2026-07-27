import { Skeleton } from "@/components/ui/Skeleton";

export function DashboardSkeleton() {
  return (
    <div className="flex flex-col gap-5">
      <div className="grid grid-cols-4 gap-4">
        {Array.from({ length: 4 }).map((_, i) => (
          <div key={i} className="glass p-5">
            <Skeleton className="h-7 w-20 mb-2" />
            <Skeleton className="h-4 w-28" />
          </div>
        ))}
      </div>
      <div className="grid grid-cols-3 gap-4">
        <div className="col-span-2 glass p-5">
          <Skeleton className="h-5 w-44 mb-4" />
          <Skeleton className="h-[220px] w-full" />
        </div>
        <div className="glass p-5">
          <Skeleton className="h-5 w-36 mb-4" />
          <Skeleton className="h-[220px] w-full" />
        </div>
      </div>
      <div className="glass p-5">
        <Skeleton className="h-5 w-32 mb-4" />
        <Skeleton className="h-5 w-full mb-2" count={5} />
      </div>
      <div className="glass p-5">
        <Skeleton className="h-5 w-20 mb-4" />
        <Skeleton className="h-5 w-48" />
      </div>
    </div>
  );
}
