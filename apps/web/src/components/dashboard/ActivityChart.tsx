import {
  AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer,
} from "recharts";
import { formatDateLabel } from "@/lib/format";

interface ActivityData {
  created_at: string;
  count: number;
}

interface ActivityChartProps {
  data: ActivityData[];
}

export function ActivityChart({ data }: ActivityChartProps) {
  if (!data.length) return null;

  return (
    <div className="glass p-5 animate-fade-in">
      <h3 className="text-[15px] font-semibold text-text-primary mb-4">Email Activity (30 days)</h3>
      <ResponsiveContainer width="100%" height={260}>
        <AreaChart data={data} margin={{ top: 5, right: 5, left: -20, bottom: 0 }}>
          <defs>
            <linearGradient id="colorCount" x1="0" y1="0" x2="0" y2="1">
              <stop offset="5%" stopColor="#333" stopOpacity={0.15} />
              <stop offset="95%" stopColor="#333" stopOpacity={0} />
            </linearGradient>
          </defs>
          <CartesianGrid strokeDasharray="3 3" stroke="rgba(0,0,0,0.04)" />
          <XAxis
            dataKey="created_at"
            tickFormatter={formatDateLabel}
            tick={{ fontSize: 12, fill: "var(--color-text-tertiary)" }}
            axisLine={false}
            tickLine={false}
          />
          <YAxis
            tick={{ fontSize: 12, fill: "var(--color-text-tertiary)" }}
            axisLine={false}
            tickLine={false}
          />
          <Tooltip
            contentStyle={{
              background: "var(--color-surface)",
              backdropFilter: "blur(20px)",
              border: "1px solid var(--color-surface-border)",
              borderRadius: 10,
              fontSize: 13,
            }}
            labelFormatter={(label) => {
              if (typeof label === "string") return new Date(label).toLocaleDateString();
              return label;
            }}
          />
          <Area
            type="monotone"
            dataKey="count"
            stroke="#333"
            strokeWidth={2}
            fill="url(#colorCount)"
            dot={false}
            activeDot={{ r: 4, fill: "#333" }}
          />
        </AreaChart>
      </ResponsiveContainer>
    </div>
  );
}
