import React from 'react';
import { Layout, Card, Statistic, Row, Col, Typography, Space, List, Avatar, Badge, Button } from 'antd';
import { 
  LineChartOutlined, 
  WarningOutlined, 
  CheckCircleOutlined,
  GlobalOutlined,
  FireOutlined,
  ThunderboltOutlined,
  SettingOutlined
} from '@ant-design/icons';
import { useNavigate } from 'react-router-dom';
import { useGetDashboardStatsQuery, useGetAllPipesQuery } from '../store/api/tutasApi';
import { MapWidget } from '../components/MapWidget';
import { DefectTrendChart } from '../components/DefectTrendChart';
import { TopRiskWidget } from '../components/TopRiskWidget';
import { PipeDigitalTwin } from '../components/PipeDigitalTwin';
import { TinyAreaChart } from '../components/TinyAreaChart';
import { RiskDistributionChart } from '../components/RiskDistributionChart';
import { RecentInspectionsTable } from '../components/RecentInspectionsTable';
import { AlertsWidget } from '../components/AlertsWidget';
import { MaterialStatsWidget } from '../components/MaterialStatsWidget';

const { Header, Content } = Layout;
const { Title } = Typography;

export const Dashboard: React.FC = () => {
  const navigate = useNavigate();
  const { data: stats, isLoading: statsLoading } = useGetDashboardStatsQuery();
  const { data: pipes } = useGetAllPipesQuery();

  // Use real data from API, show loading state if needed
  const dashboardStats = stats || {
    total_length: 0,
    total_inspections: 0,
    critical_defects: 0,
    active_pipes: 0,
  };

  // Mock sparkline data for statistics cards
  const mockSparklineData = Array.from({ length: 12 }, (_, i) => ({
    value: Math.floor(Math.random() * 20) + 10,
  }));

  return (
    <Layout style={{ minHeight: '100vh', background: '#001529' }}>
      <Header style={{ 
        background: '#001529', 
        padding: '0 24px',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'space-between',
        borderBottom: '1px solid rgba(255, 255, 255, 0.1)'
      }}>
        <Space>
          <ThunderboltOutlined style={{ fontSize: 24, color: '#1890ff' }} />
          <Title level={3} style={{ color: '#fff', margin: 0 }}>
            Tutas Ai
          </Title>
          <span style={{ color: 'rgba(255, 255, 255, 0.65)', fontSize: 14 }}>Pipeline Monitoring</span>
        </Space>
        <Space>
          <Button
            type="text"
            icon={<SettingOutlined />}
            onClick={() => navigate('/admin')}
            style={{ color: '#fff' }}
          >
            Админ-панель
          </Button>
          <Badge status="processing" text={<span style={{ color: '#fff' }}>Диспетчер</span>} />
        </Space>
      </Header>

      <Content style={{ padding: '24px', background: '#001529' }}>
        <Title level={2} style={{ marginBottom: '24px', color: '#fff' }}>
          Центр управления полетами
        </Title>

        {/* Statistics Cards with Sparklines */}
        <Row gutter={[16, 16]} style={{ marginBottom: '24px' }}>
          <Col xs={24} sm={12} lg={6}>
            <Card 
              loading={statsLoading}
              style={{ background: '#002140', border: '1px solid rgba(255, 255, 255, 0.1)' }}
            >
              <Statistic
                title={<span style={{ color: 'rgba(255, 255, 255, 0.65)' }}>Общая длина (км)</span>}
                value={dashboardStats.total_length}
                precision={1}
                prefix={<GlobalOutlined style={{ color: '#1890ff' }} />}
                valueStyle={{ color: '#1890ff' }}
              />
              <div style={{ marginTop: 12, height: 40 }}>
                <TinyAreaChart data={mockSparklineData} color="#1890ff" />
              </div>
            </Card>
          </Col>
          <Col xs={24} sm={12} lg={6}>
            <Card style={{ background: '#002140', border: '1px solid rgba(255, 255, 255, 0.1)' }}>
              <Statistic
                title={<span style={{ color: 'rgba(255, 255, 255, 0.65)' }}>Инспекции</span>}
                value={dashboardStats.total_inspections}
                prefix={<CheckCircleOutlined style={{ color: '#52c41a' }} />}
                valueStyle={{ color: '#52c41a' }}
              />
              <div style={{ marginTop: 12, height: 40 }}>
                <TinyAreaChart data={mockSparklineData} color="#52c41a" />
              </div>
            </Card>
          </Col>
          <Col xs={24} sm={12} lg={6}>
            <Card style={{ background: '#002140', border: '1px solid rgba(255, 255, 255, 0.1)' }}>
              <Statistic
                title={<span style={{ color: 'rgba(255, 255, 255, 0.65)' }}>Критические дефекты</span>}
                value={dashboardStats.critical_defects}
                prefix={<WarningOutlined style={{ color: '#ff4d4f' }} />}
                valueStyle={{ color: '#ff4d4f' }}
              />
              <div style={{ marginTop: 12, height: 40 }}>
                <TinyAreaChart data={mockSparklineData} color="#ff4d4f" />
              </div>
            </Card>
          </Col>
          <Col xs={24} sm={12} lg={6}>
            <Card style={{ background: '#002140', border: '1px solid rgba(255, 255, 255, 0.1)' }}>
              <Statistic
                title={<span style={{ color: 'rgba(255, 255, 255, 0.65)' }}>Активные трубы</span>}
                value={dashboardStats.active_pipes}
                prefix={<LineChartOutlined style={{ color: '#722ed1' }} />}
                valueStyle={{ color: '#722ed1' }}
              />
              <div style={{ marginTop: 12, height: 40 }}>
                <TinyAreaChart data={mockSparklineData} color="#722ed1" />
              </div>
            </Card>
          </Col>
        </Row>

        {/* Top Risk Widget and Digital Twin */}
        <Row gutter={[16, 16]} style={{ marginBottom: '24px' }}>
          <Col xs={24} lg={12}>
            <TopRiskWidget pipes={pipes || []} />
          </Col>
          <Col xs={24} lg={12}>
            <Card 
              title={<span style={{ color: '#fff' }}>Цифровой двойник</span>}
              style={{ background: '#002140', border: '1px solid rgba(255, 255, 255, 0.1)' }}
            >
              {pipes && pipes.length > 0 ? (
                <PipeDigitalTwin pipe={pipes[0]} />
              ) : (
                <div style={{ textAlign: 'center', color: 'rgba(255, 255, 255, 0.45)', padding: '40px' }}>
                  Выберите трубу для просмотра
                </div>
              )}
            </Card>
          </Col>
        </Row>

        {/* Map and Chart Row */}
        <Row gutter={[16, 16]} style={{ marginBottom: '24px' }}>
          <Col xs={24} lg={14}>
            <Card 
              title={<span style={{ color: '#fff' }}>Карта трубопроводов</span>}
              style={{ height: '500px', background: '#002140', border: '1px solid rgba(255, 255, 255, 0.1)' }}
            >
              <div style={{ height: '450px', borderRadius: '4px', overflow: 'hidden' }}>
                <MapWidget />
              </div>
            </Card>
          </Col>
          <Col xs={24} lg={10}>
            <Card 
              title={<span style={{ color: '#fff' }}>Тренд дефектов</span>}
              style={{ background: '#002140', border: '1px solid rgba(255, 255, 255, 0.1)' }}
            >
              <DefectTrendChart />
            </Card>
          </Col>
        </Row>

        {/* Risk Distribution and Material Stats */}
        <Row gutter={[16, 16]} style={{ marginBottom: '24px' }}>
          <Col xs={24} lg={12}>
            <Card 
              title={<span style={{ color: '#fff' }}>Распределение рисков</span>}
              style={{ background: '#002140', border: '1px solid rgba(255, 255, 255, 0.1)' }}
            >
              <RiskDistributionChart pipes={pipes || []} />
            </Card>
          </Col>
          <Col xs={24} lg={12}>
            <MaterialStatsWidget />
          </Col>
        </Row>

        {/* Recent Inspections and Alerts */}
        <Row gutter={[16, 16]}>
          <Col xs={24} lg={16}>
            <Card 
              title={<span style={{ color: '#fff' }}>Последние инспекции</span>}
              style={{ background: '#002140', border: '1px solid rgba(255, 255, 255, 0.1)' }}
            >
              <RecentInspectionsTable pipes={pipes || []} />
            </Card>
          </Col>
          <Col xs={24} lg={8}>
            <AlertsWidget />
          </Col>
        </Row>
      </Content>
    </Layout>
  );
};
