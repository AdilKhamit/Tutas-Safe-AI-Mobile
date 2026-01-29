import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer, ReferenceLine, Area, AreaChart, ComposedChart } from 'recharts';

interface DefectTrendChartProps {
  data?: Array<{ date: string; count: number; critical: number; predicted?: number; predictedCritical?: number }>;
}

export const DefectTrendChart: React.FC<DefectTrendChartProps> = ({ data }) => {
  // Get current date
  const currentDate = new Date();
  const currentMonth = `${currentDate.getFullYear()}-${String(currentDate.getMonth() + 1).padStart(2, '0')}`;
  
  // Mock historical data
  const historicalData = [
    { date: '2024-01', count: 12, critical: 2, isHistorical: true },
    { date: '2024-02', count: 15, critical: 3, isHistorical: true },
    { date: '2024-03', count: 18, critical: 4, isHistorical: true },
    { date: '2024-04', count: 14, critical: 3, isHistorical: true },
    { date: '2024-05', count: 20, critical: 5, isHistorical: true },
    { date: '2024-06', count: 22, critical: 6, isHistorical: true },
  ];

  // Generate AI predictions for next 5 years (60 months)
  const predictionData = [];
  const lastHistorical = historicalData[historicalData.length - 1];
  let trend = (lastHistorical.count - historicalData[0].count) / historicalData.length;
  
  for (let i = 1; i <= 60; i++) {
    const month = new Date(currentDate);
    month.setMonth(month.getMonth() + i);
    const dateStr = `${month.getFullYear()}-${String(month.getMonth() + 1).padStart(2, '0')}`;
    
    // AI prediction with some variance and growth trend
    const basePrediction = lastHistorical.count + (trend * i) + (Math.random() * 5 - 2.5);
    const predicted = Math.max(0, Math.round(basePrediction));
    const predictedCritical = Math.max(0, Math.round(predicted * 0.3));
    
    predictionData.push({
      date: dateStr,
      count: predicted,
      critical: predictedCritical,
      isHistorical: false,
      isPrediction: true,
    });
  }

  // Combine historical and prediction data
  const allData = [...historicalData, ...predictionData];
  
  // Find index of current date for reference line
  const currentIndex = allData.findIndex((d) => d.date === currentMonth);
  const referenceIndex = currentIndex >= 0 ? currentIndex : historicalData.length - 1;

  return (
    <ResponsiveContainer width="100%" height={300}>
      <ComposedChart data={allData}>
        <defs>
          <linearGradient id="predictionGradient" x1="0" y1="0" x2="0" y2="1">
            <stop offset="5%" stopColor="#1890ff" stopOpacity={0.1} />
            <stop offset="95%" stopColor="#1890ff" stopOpacity={0} />
          </linearGradient>
        </defs>
        <CartesianGrid strokeDasharray="3 3" stroke="rgba(255, 255, 255, 0.1)" />
        <XAxis 
          dataKey="date" 
          tick={{ fill: 'rgba(255, 255, 255, 0.65)' }}
          angle={-45}
          textAnchor="end"
          height={80}
          interval="preserveStartEnd"
        />
        <YAxis tick={{ fill: 'rgba(255, 255, 255, 0.65)' }} />
        <Tooltip 
          contentStyle={{ 
            backgroundColor: '#002140', 
            border: '1px solid rgba(255, 255, 255, 0.2)',
            borderRadius: 8,
            color: '#fff'
          }}
        />
        <Legend 
          wrapperStyle={{ color: '#fff' }}
        />
        
        {/* Historical data - solid lines */}
        <Line 
          type="monotone" 
          dataKey="count" 
          stroke="#1890ff" 
          name="Всего дефектов (факт)"
          strokeWidth={2}
          dot={false}
          data={historicalData}
        />
        <Line 
          type="monotone" 
          dataKey="critical" 
          stroke="#ff4d4f" 
          name="Критические (факт)"
          strokeWidth={2}
          dot={false}
          data={historicalData}
        />
        
        {/* AI Predictions - dashed lines */}
        <Line 
          type="monotone" 
          dataKey="count" 
          stroke="#1890ff" 
          name="AI Прогноз (5 лет)"
          strokeWidth={2}
          strokeDasharray="5 5"
          dot={false}
          data={predictionData}
        />
        <Line 
          type="monotone" 
          dataKey="critical" 
          stroke="#ff4d4f" 
          name="Критические (прогноз)"
          strokeWidth={2}
          strokeDasharray="5 5"
          dot={false}
          data={predictionData}
        />
        
        {/* Confidence interval area for predictions */}
        <Area
          type="monotone"
          dataKey="count"
          stroke="none"
          fill="url(#predictionGradient)"
          data={predictionData}
        />
        
        {/* Vertical line at current date */}
        <ReferenceLine 
          x={allData[referenceIndex]?.date} 
          stroke="#52c41a" 
          strokeDasharray="3 3"
          label={{ value: 'Сегодня', position: 'top', fill: '#52c41a' }}
        />
      </ComposedChart>
    </ResponsiveContainer>
  );
};
