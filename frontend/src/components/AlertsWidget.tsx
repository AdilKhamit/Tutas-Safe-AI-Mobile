import React from 'react';
import { Card, List, Badge, Space, Typography } from 'antd';
import { 
  WarningOutlined, 
  FireOutlined, 
  ExclamationCircleOutlined,
  BellOutlined 
} from '@ant-design/icons';

const { Text } = Typography;

export const AlertsWidget: React.FC = () => {
  // Mock alerts data
  const alerts = [
    {
      id: 1,
      type: 'critical',
      title: 'Критический риск обнаружен',
      message: 'Труба PL-COMPANY1-550e8400 требует немедленного внимания',
      time: '2 минуты назад',
      icon: <FireOutlined style={{ color: '#ff4d4f' }} />,
    },
    {
      id: 2,
      type: 'warning',
      title: 'Плановое обслуживание',
      message: 'Труба PL-COMPANY2-123e4567 запланирована на обслуживание',
      time: '15 минут назад',
      icon: <ExclamationCircleOutlined style={{ color: '#faad14' }} />,
    },
    {
      id: 3,
      type: 'info',
      title: 'Новая инспекция',
      message: 'Инженер А завершил инспекцию трубы PL-COMPANY3-789e0123',
      time: '1 час назад',
      icon: <BellOutlined style={{ color: '#1890ff' }} />,
    },
  ];

  return (
    <Card
      title={
        <Space>
          <WarningOutlined style={{ color: '#ff4d4f' }} />
          <span style={{ color: '#fff' }}>Уведомления</span>
          <Badge count={alerts.length} style={{ backgroundColor: '#ff4d4f' }} />
        </Space>
      }
      style={{ background: '#002140', border: '1px solid rgba(255, 255, 255, 0.1)' }}
    >
      <List
        dataSource={alerts}
        renderItem={(alert) => (
          <List.Item
            style={{
              padding: '12px 0',
              borderBottom: '1px solid rgba(255, 255, 255, 0.1)',
            }}
          >
            <List.Item.Meta
              avatar={alert.icon}
              title={
                <Space>
                  <Text strong style={{ color: '#fff' }}>
                    {alert.title}
                  </Text>
                  {alert.type === 'critical' && (
                    <Badge status="error" text="" />
                  )}
                </Space>
              }
              description={
                <div>
                  <Text style={{ color: 'rgba(255, 255, 255, 0.65)', fontSize: 12 }}>
                    {alert.message}
                  </Text>
                  <div style={{ marginTop: 4 }}>
                    <Text style={{ color: 'rgba(255, 255, 255, 0.45)', fontSize: 11 }}>
                      {alert.time}
                    </Text>
                  </div>
                </div>
              }
            />
          </List.Item>
        )}
      />
    </Card>
  );
};
