import React from 'react';
import { PieChart, Pie, Cell, ResponsiveContainer, Legend, Tooltip } from 'recharts';

interface RiskDistributionChartProps {
  pipes?: Array<{ risk_score?: number }>;
}

export const RiskDistributionChart: React.FC<RiskDistributionChartProps> = ({ pipes = [] }) => {
  // Calculate distribution
  const distribution = {
    critical: 0,
    warning: 0,
    low: 0,
    unknown: 0,
  };

  pipes.forEach((pipe) => {
    if (!pipe.risk_score) {
      distribution.unknown++;
    } else if (pipe.risk_score >= 0.7) {
      distribution.critical++;
    } else if (pipe.risk_score >= 0.4) {
      distribution.warning++;
    } else {
      distribution.low++;
    }
  });

  const data = [
    { name: 'Критический', value: distribution.critical, color: '#ff4d4f' },
    { name: 'Средний', value: distribution.warning, color: '#faad14' },
    { name: 'Низкий', value: distribution.low, color: '#52c41a' },
    { name: 'Не оценен', value: distribution.unknown, color: '#8c8c8c' },
  ];

  return (
    <ResponsiveContainer width="100%" height={250}>
      <PieChart>
        <Pie
          data={data}
          cx="50%"
          cy="50%"
          labelLine={false}
          label={({ name, percent }) => `${name}: ${(percent * 100).toFixed(0)}%`}
          outerRadius={80}
          fill="#8884d8"
          dataKey="value"
        >
          {data.map((entry, index) => (
            <Cell key={`cell-${index}`} fill={entry.color} />
          ))}
        </Pie>
        <Tooltip 
          contentStyle={{ 
            backgroundColor: '#002140', 
            border: '1px solid rgba(255, 255, 255, 0.2)',
            borderRadius: 8,
            color: '#fff'
          }}
        />
        <Legend />
      </PieChart>
    </ResponsiveContainer>
  );
};
