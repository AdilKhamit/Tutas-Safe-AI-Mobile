import React from 'react';
import { Card, Progress, Row, Col, Typography } from 'antd';
import { DatabaseOutlined } from '@ant-design/icons';

const { Text } = Typography;

export const MaterialStatsWidget: React.FC = () => {
  // Mock material statistics
  const materials = [
    { name: 'Сталь', count: 45, total: 100, color: '#1890ff' },
    { name: 'Чугун', count: 30, total: 100, color: '#52c41a' },
    { name: 'Пластик', count: 20, total: 100, color: '#faad14' },
    { name: 'Другое', count: 5, total: 100, color: '#8c8c8c' },
  ];

  return (
    <Card
      title={
        <span style={{ color: '#fff' }}>
          <DatabaseOutlined style={{ marginRight: 8 }} />
          Распределение по материалам
        </span>
      }
      style={{ background: '#002140', border: '1px solid rgba(255, 255, 255, 0.1)' }}
    >
      {materials.map((material) => (
        <div key={material.name} style={{ marginBottom: 16 }}>
          <Row justify="space-between" style={{ marginBottom: 8 }}>
            <Col>
              <Text style={{ color: 'rgba(255, 255, 255, 0.85)' }}>{material.name}</Text>
            </Col>
            <Col>
              <Text strong style={{ color: material.color }}>
                {material.count}%
              </Text>
            </Col>
          </Row>
          <Progress
            percent={material.count}
            strokeColor={material.color}
            showInfo={false}
            trailColor="rgba(255, 255, 255, 0.1)"
          />
        </div>
      ))}
    </Card>
  );
};
