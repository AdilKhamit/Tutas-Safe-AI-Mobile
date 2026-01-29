import React from 'react';
import { Card, List, Avatar, Badge, Typography, Empty } from 'antd';
import { FireOutlined, WarningOutlined } from '@ant-design/icons';
import type { Pipe } from '../types';

const { Text } = Typography;

interface TopRiskWidgetProps {
  pipes: Pipe[];
}

export const TopRiskWidget: React.FC<TopRiskWidgetProps> = ({ pipes }) => {
  // Sort pipes by risk_score (highest first) and take top 5
  const topRiskPipes = [...pipes]
    .filter((pipe) => pipe.risk_score !== undefined && pipe.risk_score !== null)
    .sort((a, b) => (b.risk_score || 0) - (a.risk_score || 0))
    .slice(0, 5);

  const getRiskColor = (riskScore: number) => {
    if (riskScore >= 0.7) return '#ff4d4f';
    if (riskScore >= 0.4) return '#faad14';
    return '#52c41a';
  };

  const getRiskLabel = (riskScore: number) => {
    if (riskScore >= 0.7) return 'Критический';
    if (riskScore >= 0.4) return 'Средний';
    return 'Низкий';
  };

  return (
    <Card
      title={
        <span style={{ color: '#fff' }}>
          <FireOutlined style={{ color: '#ff4d4f', marginRight: 8 }} />
          Топ-5 риска
        </span>
      }
      style={{ background: '#002140', border: '1px solid rgba(255, 255, 255, 0.1)' }}
    >
      {topRiskPipes.length === 0 ? (
        <Empty
          description={<span style={{ color: 'rgba(255, 255, 255, 0.45)' }}>Нет данных о рисках</span>}
          style={{ padding: '20px 0' }}
        />
      ) : (
        <List
          dataSource={topRiskPipes}
          renderItem={(pipe, index) => {
            const riskScore = pipe.risk_score || 0;
            const riskColor = getRiskColor(riskScore);
            const riskLabel = getRiskLabel(riskScore);

            return (
              <List.Item
                style={{
                  padding: '12px 0',
                  borderBottom: '1px solid rgba(255, 255, 255, 0.1)',
                }}
              >
                <List.Item.Meta
                  avatar={
                    <Badge
                      count={index + 1}
                      style={{
                        backgroundColor: riskColor,
                      }}
                    >
                      <Avatar
                        style={{
                          backgroundColor: riskColor,
                          opacity: 0.2,
                        }}
                        icon={<WarningOutlined style={{ color: riskColor }} />}
                      />
                    </Badge>
                  }
                  title={
                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                      <Text strong style={{ color: '#fff' }}>
                        {pipe.qr_code}
                      </Text>
                      <Badge
                        count={riskLabel}
                        style={{
                          backgroundColor: riskColor,
                          fontSize: 12,
                        }}
                      />
                    </div>
                  }
                  description={
                    <div>
                      <Text style={{ color: 'rgba(255, 255, 255, 0.65)', fontSize: 12 }}>
                        Risk Score: <Text strong style={{ color: riskColor }}>
                          {(riskScore * 100).toFixed(1)}%
                        </Text>
                      </Text>
                      {pipe.location && (
                        <div style={{ marginTop: 4 }}>
                          <Text style={{ color: 'rgba(255, 255, 255, 0.45)', fontSize: 11 }}>
                            📍 {pipe.location.lat.toFixed(4)}, {pipe.location.lon.toFixed(4)}
                          </Text>
                        </div>
                      )}
                    </div>
                  }
                />
              </List.Item>
            );
          }}
        />
      )}
    </Card>
  );
};
