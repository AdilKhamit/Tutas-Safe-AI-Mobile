import React from 'react';
import { Table, Tag, Space } from 'antd';
import { ClockCircleOutlined, CheckCircleOutlined, WarningOutlined } from '@ant-design/icons';
import type { Pipe } from '../types';

interface RecentInspectionsTableProps {
  pipes?: Pipe[];
}

export const RecentInspectionsTable: React.FC<RecentInspectionsTableProps> = ({ pipes = [] }) => {
  // Mock recent inspections data
  const mockInspections = pipes.slice(0, 10).map((pipe, index) => ({
    key: pipe.id || index.toString(),
    qrCode: pipe.qr_code,
    date: new Date(Date.now() - index * 86400000).toLocaleDateString('ru-RU'),
    status: pipe.current_status,
    riskScore: pipe.risk_score,
    inspector: `Инженер ${String.fromCharCode(65 + (index % 5))}`,
  }));

  const columns = [
    {
      title: 'QR-код',
      dataIndex: 'qrCode',
      key: 'qrCode',
      render: (text: string) => <span style={{ color: '#1890ff', fontWeight: 500 }}>{text}</span>,
    },
    {
      title: 'Дата',
      dataIndex: 'date',
      key: 'date',
      render: (text: string) => (
        <Space>
          <ClockCircleOutlined style={{ color: 'rgba(255, 255, 255, 0.45)' }} />
          <span style={{ color: 'rgba(255, 255, 255, 0.85)' }}>{text}</span>
        </Space>
      ),
    },
    {
      title: 'Статус',
      dataIndex: 'status',
      key: 'status',
      render: (status: string) => {
        const color = status === 'active' ? 'green' : status === 'maintenance' ? 'orange' : 'default';
        const label = status === 'active' ? 'Активна' : status === 'maintenance' ? 'Обслуживание' : status;
        return <Tag color={color}>{label}</Tag>;
      },
    },
    {
      title: 'Risk Score',
      dataIndex: 'riskScore',
      key: 'riskScore',
      render: (score?: number) => {
        if (!score) return <Tag>N/A</Tag>;
        const color = score >= 0.7 ? 'red' : score >= 0.4 ? 'orange' : 'green';
        return <Tag color={color}>{(score * 100).toFixed(1)}%</Tag>;
      },
    },
    {
      title: 'Инспектор',
      dataIndex: 'inspector',
      key: 'inspector',
      render: (text: string) => <span style={{ color: 'rgba(255, 255, 255, 0.65)' }}>{text}</span>,
    },
  ];

  return (
    <Table
      columns={columns}
      dataSource={mockInspections}
      pagination={{ pageSize: 5, size: 'small' }}
      style={{ background: 'transparent' }}
      size="small"
    />
  );
};
