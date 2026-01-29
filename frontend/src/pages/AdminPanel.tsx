import React, { useState } from 'react';
import {
  Layout,
  Card,
  Form,
  Input,
  InputNumber,
  Button,
  Table,
  Space,
  Typography,
  Modal,
  Image,
  message,
  Row,
  Col,
  Tag,
} from 'antd';
import {
  PlusOutlined,
  QrcodeOutlined,
  DownloadOutlined,
} from '@ant-design/icons';
import { useGetAllPipesQuery, useCreatePipeMutation, useGetPipeQrCodeImageQuery } from '../store/api/tutasApi';
import type { Pipe } from '../types';

const { Header, Content } = Layout;
const { Title } = Typography;

export const AdminPanel: React.FC = () => {
  const [form] = Form.useForm();
  const [isModalVisible, setIsModalVisible] = useState(false);
  const [selectedPipe, setSelectedPipe] = useState<Pipe | null>(null);
  const [qrModalVisible, setQrModalVisible] = useState(false);

  const { data: pipes = [], isLoading, refetch, error } = useGetAllPipesQuery();
  const [createPipe, { isLoading: isCreating }] = useCreatePipeMutation();

  // Debug: проверка загрузки
  React.useEffect(() => {
    console.log('AdminPanel mounted');
    console.log('Pipes data:', pipes);
    console.log('Loading:', isLoading);
    console.log('Error:', error);
  }, [pipes, isLoading, error]);

  const { data: qrCodeImageUrl, isLoading: qrLoading } = useGetPipeQrCodeImageQuery(
    { pipeId: selectedPipe?.id || '', size: 400 },
    { skip: !selectedPipe?.id || !qrModalVisible }
  );

  const handleCreatePipe = async (values: any) => {
    try {
      await createPipe({
        company: values.company || 'COMPANY',
        manufacturer: values.manufacturer,
        material: values.material,
        diameter_mm: values.diameter_mm,
        wall_thickness_mm: values.wall_thickness_mm,
        length_meters: values.length_meters,
      }).unwrap();
      
      message.success('Труба успешно создана!');
      form.resetFields();
      setIsModalVisible(false);
      refetch();
    } catch (error: any) {
      message.error(`Ошибка создания трубы: ${error?.data?.detail || error?.message || 'Неизвестная ошибка'}`);
    }
  };

  const handleShowQrCode = (pipe: Pipe) => {
    setSelectedPipe(pipe);
    setQrModalVisible(true);
  };

  const handleDownloadQrCode = () => {
    if (qrCodeImageUrl && selectedPipe) {
      const link = document.createElement('a');
      link.href = qrCodeImageUrl;
      link.download = `qr_${selectedPipe.qr_code}.png`;
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
    }
  };

  const columns = [
    {
      title: 'QR-код',
      dataIndex: 'qr_code',
      key: 'qr_code',
      render: (text: string) => <Tag color="blue">{text}</Tag>,
    },
    {
      title: 'Производитель',
      dataIndex: 'manufacturer',
      key: 'manufacturer',
    },
    {
      title: 'Материал',
      dataIndex: 'material',
      key: 'material',
    },
    {
      title: 'Диаметр (мм)',
      dataIndex: 'diameter_mm',
      key: 'diameter_mm',
    },
    {
      title: 'Длина (м)',
      dataIndex: 'length_meters',
      key: 'length_meters',
    },
    {
      title: 'Статус',
      dataIndex: 'current_status',
      key: 'current_status',
      render: (status: string) => (
        <Tag color={status === 'active' ? 'green' : 'red'}>{status}</Tag>
      ),
    },
    {
      title: 'Действия',
      key: 'actions',
      render: (_: any, record: Pipe) => (
        <Space>
          <Button
            type="primary"
            icon={<QrcodeOutlined />}
            onClick={() => handleShowQrCode(record)}
          >
            QR-код
          </Button>
        </Space>
      ),
    },
  ];

  return (
    <Layout style={{ minHeight: '100vh', background: '#001529' }}>
      <Header
        style={{
          background: '#001529',
          padding: '0 24px',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          borderBottom: '1px solid rgba(255, 255, 255, 0.1)',
        }}
      >
        <Space>
          <QrcodeOutlined style={{ fontSize: 24, color: '#1890ff' }} />
          <Title level={3} style={{ color: '#fff', margin: 0 }}>
            Админ-панель
          </Title>
          <span style={{ color: 'rgba(255, 255, 255, 0.65)', fontSize: 14 }}>
            Управление трубами
          </span>
        </Space>
      </Header>

      <Content style={{ padding: '24px', background: '#001529' }}>
        <Card
          style={{ background: '#002140', border: '1px solid rgba(255, 255, 255, 0.1)' }}
        >
          <Space style={{ marginBottom: 16, width: '100%', justifyContent: 'space-between' }}>
            <Title level={4} style={{ color: '#fff', margin: 0 }}>
              Список труб
            </Title>
            <Button
              type="primary"
              icon={<PlusOutlined />}
              onClick={() => setIsModalVisible(true)}
            >
              Создать новую трубу
            </Button>
          </Space>

          {error && (
            <div style={{ marginBottom: 16, padding: 12, background: '#ff4d4f', borderRadius: 4, color: '#fff' }}>
              Ошибка загрузки данных. Проверьте консоль браузера для деталей.
            </div>
          )}

          <Table
            columns={columns}
            dataSource={pipes}
            loading={isLoading}
            rowKey="id"
            pagination={{ pageSize: 10 }}
            style={{ background: '#002140' }}
          />
        </Card>

        {/* Modal для создания трубы */}
        <Modal
          title="Создать новую трубу"
          open={isModalVisible}
          onCancel={() => {
            setIsModalVisible(false);
            form.resetFields();
          }}
          footer={null}
          width={600}
        >
          <Form
            form={form}
            layout="vertical"
            onFinish={handleCreatePipe}
          >
            <Form.Item
              name="company"
              label="Название компании"
              initialValue="COMPANY"
              rules={[{ required: true, message: 'Введите название компании' }]}
            >
              <Input placeholder="COMPANY" />
            </Form.Item>

            <Row gutter={16}>
              <Col span={12}>
                <Form.Item
                  name="manufacturer"
                  label="Производитель"
                >
                  <Input placeholder="Название производителя" />
                </Form.Item>
              </Col>
              <Col span={12}>
                <Form.Item
                  name="material"
                  label="Материал"
                >
                  <Input placeholder="Сталь, ПВХ и т.д." />
                </Form.Item>
              </Col>
            </Row>

            <Row gutter={16}>
              <Col span={8}>
                <Form.Item
                  name="diameter_mm"
                  label="Диаметр (мм)"
                >
                  <InputNumber
                    style={{ width: '100%' }}
                    placeholder="100"
                    min={1}
                  />
                </Form.Item>
              </Col>
              <Col span={8}>
                <Form.Item
                  name="wall_thickness_mm"
                  label="Толщина стенки (мм)"
                >
                  <InputNumber
                    style={{ width: '100%' }}
                    placeholder="5.0"
                    min={0.1}
                    step={0.1}
                  />
                </Form.Item>
              </Col>
              <Col span={8}>
                <Form.Item
                  name="length_meters"
                  label="Длина (м)"
                >
                  <InputNumber
                    style={{ width: '100%' }}
                    placeholder="100.0"
                    min={0.1}
                    step={0.1}
                  />
                </Form.Item>
              </Col>
            </Row>

            <Form.Item>
              <Space>
                <Button type="primary" htmlType="submit" loading={isCreating}>
                  Создать
                </Button>
                <Button onClick={() => {
                  setIsModalVisible(false);
                  form.resetFields();
                }}>
                  Отмена
                </Button>
              </Space>
            </Form.Item>
          </Form>
        </Modal>

        {/* Modal для отображения QR-кода */}
        <Modal
          title={
            <Space>
              <QrcodeOutlined />
              <span>QR-код трубы: {selectedPipe?.qr_code}</span>
            </Space>
          }
          open={qrModalVisible}
          onCancel={() => {
            setQrModalVisible(false);
            setSelectedPipe(null);
          }}
          footer={[
            <Button key="download" icon={<DownloadOutlined />} onClick={handleDownloadQrCode}>
              Скачать
            </Button>,
            <Button key="close" onClick={() => {
              setQrModalVisible(false);
              setSelectedPipe(null);
            }}>
              Закрыть
            </Button>,
          ]}
          width={500}
        >
          {qrLoading ? (
            <div style={{ textAlign: 'center', padding: '40px' }}>
              Загрузка QR-кода...
            </div>
          ) : qrCodeImageUrl ? (
            <div style={{ textAlign: 'center', padding: '20px' }}>
              <Image
                src={qrCodeImageUrl}
                alt={`QR код ${selectedPipe?.qr_code}`}
                preview={false}
                style={{ maxWidth: '100%' }}
              />
              <div style={{ marginTop: 16 }}>
                <Tag color="blue" style={{ fontSize: 16, padding: '4px 12px' }}>
                  {selectedPipe?.qr_code}
                </Tag>
              </div>
            </div>
          ) : (
            <div style={{ textAlign: 'center', padding: '40px', color: '#ff4d4f' }}>
              Ошибка загрузки QR-кода
            </div>
          )}
        </Modal>
      </Content>
    </Layout>
  );
};
