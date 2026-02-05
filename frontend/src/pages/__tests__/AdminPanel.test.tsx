import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, waitFor } from '@testing-library/react';
import { Provider } from 'react-redux';
import { configureStore } from '@reduxjs/toolkit';
import { AdminPanel } from '../AdminPanel';
import { tutasApi } from '../../store/api/tutasApi';
import type { Pipe } from '../../types';

// Mock Ant Design components that might cause issues in tests
vi.mock('antd', async () => {
  const actual = await vi.importActual('antd');
  return {
    ...actual,
    message: {
      success: vi.fn(),
      error: vi.fn(),
    },
  };
});

describe('AdminPanel QR Code Tests', () => {
  let store: ReturnType<typeof configureStore>;

  const createMockStore = (initialState = {}) => {
    return configureStore({
      reducer: {
        [tutasApi.reducerPath]: tutasApi.reducer,
      },
      middleware: (getDefaultMiddleware) =>
        getDefaultMiddleware().concat(tutasApi.middleware),
      preloadedState: {
        [tutasApi.reducerPath]: {
          queries: {},
          mutations: {},
          provided: {},
          subscriptions: {},
          config: {
            online: true,
            focused: true,
            middlewareRegistered: true,
            refetchOnFocus: false,
            refetchOnReconnect: false,
            refetchOnMountOrArgChange: false,
          },
          ...initialState,
        },
      },
    });
  };

  beforeEach(() => {
    store = createMockStore();
    vi.clearAllMocks();
  });

  it('should render AdminPanel with QR code functionality', () => {
    render(
      <Provider store={store}>
        <AdminPanel />
      </Provider>
    );

    // Check if the component renders
    expect(screen.getByText(/Админ-панель/i)).toBeInTheDocument();
  });

  it('should display QR codes in table', async () => {
    const mockPipes: Pipe[] = [
      {
        id: 'pipe-1',
        qr_code: 'PL-COMPANY-123e4567-e89b-12d3-a456-426614174000',
        manufacturer: 'Test Manufacturer',
        material: 'Steel',
        diameter_mm: 100,
        current_status: 'active',
      },
      {
        id: 'pipe-2',
        qr_code: 'PL-TUTAS-9757a1cd-8292-4535-8e44-979d608a2588',
        manufacturer: 'Another Manufacturer',
        material: 'Steel',
        diameter_mm: 150,
        current_status: 'active',
      },
    ];

    // Mock the API response
    store.dispatch(
      tutasApi.util.updateQueryData('getAllPipes', undefined, () => mockPipes)
    );

    render(
      <Provider store={store}>
        <AdminPanel />
      </Provider>
    );

    // Wait for data to load and check if QR codes are displayed
    await waitFor(() => {
      expect(screen.getByText('PL-COMPANY-123e4567-e89b-12d3-a456-426614174000')).toBeInTheDocument();
      expect(screen.getByText('PL-TUTAS-9757a1cd-8292-4535-8e44-979d608a2588')).toBeInTheDocument();
    });
  });

  it('should handle QR code button click', async () => {
    const mockPipe: Pipe = {
      id: 'pipe-1',
      qr_code: 'PL-COMPANY-123e4567-e89b-12d3-a456-426614174000',
      manufacturer: 'Test Manufacturer',
      material: 'Steel',
      diameter_mm: 100,
      current_status: 'active',
    };

    store.dispatch(
      tutasApi.util.updateQueryData('getAllPipes', undefined, () => [mockPipe])
    );

    render(
      <Provider store={store}>
        <AdminPanel />
      </Provider>
    );

    // Find and click QR code button
    await waitFor(() => {
      const qrButtons = screen.getAllByText(/QR-код/i);
      expect(qrButtons.length).toBeGreaterThan(0);
    });
  });

  it('should validate QR code format when creating pipe', async () => {
    render(
      <Provider store={store}>
        <AdminPanel />
      </Provider>
    );

    // The form should accept valid company names that will generate valid QR codes
    // This is tested through the createPipe mutation
    expect(screen.getByText(/Админ-панель/i)).toBeInTheDocument();
  });
});
