interface StatCardProps {
  icon: React.ReactNode;
  label: string;
  value: string;
  delay: number;
}

export function StatCard({ icon, label, value, delay }: StatCardProps) {
  return (
    <div
      className="glass p-5 flex items-center gap-4 animate-fade-in"
      style={{ animationDelay: `${delay}ms`, animationFillMode: "both" } as React.CSSProperties}
    >
      <div className="w-10 h-10 rounded-[10px] bg-accent-glass flex items-center justify-center text-text-secondary shrink-0">
        {icon}
      </div>
      <div className="min-w-0">
        <p className="text-[22px] font-semibold tracking-tight text-text-primary leading-none mb-1">
          {value}
        </p>
        <p className="text-[13px] text-text-secondary">{label}</p>
      </div>
    </div>
  );
}
