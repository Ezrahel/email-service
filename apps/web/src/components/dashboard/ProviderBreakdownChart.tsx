import {
  PieChart, Pie, Cell, Tooltip, Legend, ResponsiveContainer,
} from "recharts";

const CHART_COLORS = ["#333", "#86868b", "#30d158", "#ff453a"];

interface ProviderData {
  provider_type: string;
  count: number;
  delivered: number;
  bounced: number;
}

interface ProviderBreakdownChartProps {
  data: ProviderData[];
}

export function ProviderBreakdownChart({ data }: ProviderBreakdownChartProps) {
  if (!data.length) return null;

  return (
    <div className="glass p-5 animate-fade-in">
      <h3 className="text-[15px] font-semibold text-text-primary mb-4">Provider Breakdown</h3>
      <ResponsiveContainer width="100%" height={260}>
        <PieChart>
          <Pie
            data={data}
            dataKey="count"
            nameKey="provider_type"
            cx="50%"
            cy="50%"
            innerRadius={60}
            outerRadius={90}
            paddingAngle={3}
          >
            {data.map((_, i) => (
              <Cell key={i} fill={CHART_COLORS[i % CHART_COLORS.length]} />
            ))}
          </Pie>
          <Tooltip
            contentStyle={{
              background: "var(--color-surface)",
              backdropFilter: "blur(20px)",
              border: "1px solid var(--color-surface-border)",
              borderRadius: 10,
              fontSize: 13,
            }}
          />
          <Legend
            verticalAlign="bottom"
            iconType="circle"
            iconSize={8}
            formatter={(value: string) => (
              <span className="text-[13px] text-text-secondary">{value}</span>
            )}
          />
        </PieChart>
      </ResponsiveContainer>
    </div>
  );
}
