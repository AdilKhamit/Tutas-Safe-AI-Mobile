import React from 'react';
import { Typography, Space } from 'antd';
import type { Pipe } from '../types';

const { Text, Title } = Typography;

interface PipeDigitalTwinProps {
  pipe: Pipe;
}

export const PipeDigitalTwin: React.FC<PipeDigitalTwinProps> = ({ pipe }) => {
  // Calculate visual representation of wall thickness
  const wallThickness = pipe.wall_thickness_mm || 10; // Default 10mm
  const diameter = pipe.diameter_mm || 200; // Default 200mm
  const maxThickness = 20; // Assume max thickness for visualization
  const thicknessRatio = Math.min(wallThickness / maxThickness, 1);
  
  // Calculate inner and outer radius for visualization
  const outerRadius = 80;
  const innerRadius = outerRadius * (1 - thicknessRatio * 0.3); // Visual representation

  const getThicknessColor = (thickness: number) => {
    if (thickness < 5) return '#ff4d4f'; // Red - critical
    if (thickness < 10) return '#faad14'; // Orange - warning
    return '#52c41a'; // Green - good
  };

  return (
    <div style={{ padding: '20px 0' }}>
      <Space direction="vertical" size="large" style={{ width: '100%' }}>
        <div style={{ textAlign: 'center' }}>
          <Title level={4} style={{ color: '#fff', marginBottom: 24 }}>
            {pipe.qr_code}
          </Title>
          
          {/* Visual representation of pipe cross-section */}
          <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', marginBottom: 24 }}>
            <svg width="200" height="200" viewBox="0 0 200 200">
              {/* Outer circle (pipe outer wall) */}
              <circle
                cx="100"
                cy="100"
                r={outerRadius}
                fill="none"
                stroke="rgba(255, 255, 255, 0.3)"
                strokeWidth="2"
              />
              {/* Inner circle (pipe inner wall) - represents thickness */}
              <circle
                cx="100"
                cy="100"
                r={innerRadius}
                fill="none"
                stroke={getThicknessColor(wallThickness)}
                strokeWidth="4"
              />
              {/* Center point */}
              <circle
                cx="100"
                cy="100"
                r="2"
                fill={getThicknessColor(wallThickness)}
              />
              {/* Thickness indicator line */}
              <line
                x1="100"
                y1={100 - outerRadius}
                x2="100"
                y2={100 - innerRadius}
                stroke={getThicknessColor(wallThickness)}
                strokeWidth="3"
                strokeLinecap="round"
              />
              {/* Label for thickness */}
              <text
                x="100"
                y={100 - (outerRadius + innerRadius) / 2}
                textAnchor="middle"
                fill={getThicknessColor(wallThickness)}
                fontSize="12"
                fontWeight="bold"
              >
                {wallThickness}mm
              </text>
            </svg>
          </div>

          {/* Specifications */}
          <Space direction="vertical" size="small" style={{ width: '100%' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', padding: '8px 0' }}>
              <Text style={{ color: 'rgba(255, 255, 255, 0.65)' }}>Толщина стенки:</Text>
              <Text strong style={{ color: getThicknessColor(wallThickness) }}>
                {wallThickness} мм
              </Text>
            </div>
            {pipe.diameter_mm && (
              <div style={{ display: 'flex', justifyContent: 'space-between', padding: '8px 0' }}>
                <Text style={{ color: 'rgba(255, 255, 255, 0.65)' }}>Диаметр:</Text>
                <Text strong style={{ color: '#fff' }}>
                  {pipe.diameter_mm} мм
                </Text>
              </div>
            )}
            {pipe.material && (
              <div style={{ display: 'flex', justifyContent: 'space-between', padding: '8px 0' }}>
                <Text style={{ color: 'rgba(255, 255, 255, 0.65)' }}>Материал:</Text>
                <Text strong style={{ color: '#fff' }}>
                  {pipe.material}
                </Text>
              </div>
            )}
            {pipe.risk_score !== undefined && (
              <div style={{ display: 'flex', justifyContent: 'space-between', padding: '8px 0' }}>
                <Text style={{ color: 'rgba(255, 255, 255, 0.65)' }}>Risk Score:</Text>
                <Text strong style={{ 
                  color: pipe.risk_score >= 0.7 ? '#ff4d4f' : 
                         pipe.risk_score >= 0.4 ? '#faad14' : '#52c41a' 
                }}>
                  {(pipe.risk_score * 100).toFixed(1)}%
                </Text>
              </div>
            )}
          </Space>
        </div>
      </Space>
    </div>
  );
};
