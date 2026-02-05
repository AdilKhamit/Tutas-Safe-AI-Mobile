import { describe, it, expect, beforeEach, vi } from 'vitest';
import { configureStore } from '@reduxjs/toolkit';
import { tutasApi } from '../tutasApi';
import type { Pipe } from '../../../types';

// Mock fetch for testing
global.fetch = vi.fn();

describe('QR Code API', () => {
  let store: ReturnType<typeof configureStore>;

  beforeEach(() => {
    store = configureStore({
      reducer: {
        [tutasApi.reducerPath]: tutasApi.reducer,
      },
      middleware: (getDefaultMiddleware) =>
        getDefaultMiddleware().concat(tutasApi.middleware),
    });
    vi.clearAllMocks();
  });

  describe('getPipeByQr', () => {
    it('should fetch pipe by QR code', async () => {
      const qrCode = 'PL-COMPANY-123e4567-e89b-12d3-a456-426614174000';
      const mockPipe: Pipe = {
        id: 'pipe-123',
        qr_code: qrCode,
        manufacturer: 'Test Manufacturer',
        material: 'Steel',
        diameter_mm: 100,
        current_status: 'active',
        risk_score: 0.5,
        predicted_lifetime_years: 20,
      };

      (global.fetch as any).mockResolvedValueOnce({
        ok: true,
        json: async () => mockPipe,
      });

      const result = await store.dispatch(
        tutasApi.endpoints.getPipeByQr.initiate(qrCode)
      );

      expect(result.data).toEqual(mockPipe);
      expect(result.data?.qr_code).toBe(qrCode);
    });

    it('should handle different QR code formats', async () => {
      const qrCodes = [
        'PL-COMPANY-123',
        'PL-TUTAS-9757a1cd-8292-4535-8e44-979d608a2588',
        'PL-MYCOMPANY-abc123',
      ];

      for (const qrCode of qrCodes) {
        const mockPipe: Pipe = {
          id: `pipe-${qrCode}`,
          qr_code: qrCode,
          manufacturer: 'Test',
          material: 'Steel',
          current_status: 'active',
        };

        (global.fetch as any).mockResolvedValueOnce({
          ok: true,
          json: async () => mockPipe,
        });

        const result = await store.dispatch(
          tutasApi.endpoints.getPipeByQr.initiate(qrCode)
        );

        expect(result.data?.qr_code).toBe(qrCode);
      }
    });

    it('should handle 404 errors', async () => {
      const qrCode = 'PL-COMPANY-NOTFOUND';

      (global.fetch as any).mockResolvedValueOnce({
        ok: false,
        status: 404,
        json: async () => ({ detail: 'Pipe not found' }),
      });

      const result = await store.dispatch(
        tutasApi.endpoints.getPipeByQr.initiate(qrCode)
      );

      expect(result.error).toBeDefined();
      expect(result.isError).toBe(true);
    });
  });

  describe('getQrCodeImage', () => {
    it('should fetch QR code image', async () => {
      const qrCode = 'PL-COMPANY-123';
      const mockBlob = new Blob(['fake image data'], { type: 'image/png' });

      (global.fetch as any).mockResolvedValueOnce({
        ok: true,
        blob: async () => mockBlob,
      });

      const result = await store.dispatch(
        tutasApi.endpoints.getQrCodeImage.initiate({ qrCode, size: 300 })
      );

      expect(result.data).toBeDefined();
      expect(typeof result.data).toBe('string'); // URL string
    });

    it('should handle custom size parameter', async () => {
      const qrCode = 'PL-COMPANY-123';
      const mockBlob = new Blob(['fake image data'], { type: 'image/png' });

      (global.fetch as any).mockResolvedValueOnce({
        ok: true,
        blob: async () => mockBlob,
      });

      const result = await store.dispatch(
        tutasApi.endpoints.getQrCodeImage.initiate({ qrCode, size: 500 })
      );

      expect(result.data).toBeDefined();
      // Verify that size parameter was used in URL
      expect((global.fetch as any).mock.calls[0][0]).toContain('size=500');
    });
  });

  describe('getPipeQrCodeImage', () => {
    it('should fetch QR code image by pipe ID', async () => {
      const pipeId = 'pipe-123';
      const mockBlob = new Blob(['fake image data'], { type: 'image/png' });

      (global.fetch as any).mockResolvedValueOnce({
        ok: true,
        blob: async () => mockBlob,
      });

      const result = await store.dispatch(
        tutasApi.endpoints.getPipeQrCodeImage.initiate({ pipeId, size: 400 })
      );

      expect(result.data).toBeDefined();
      expect(typeof result.data).toBe('string'); // URL string
    });

    it('should handle 404 when pipe not found', async () => {
      const pipeId = 'non-existent-pipe';

      (global.fetch as any).mockResolvedValueOnce({
        ok: false,
        status: 404,
        json: async () => ({ detail: 'Pipe not found' }),
      });

      const result = await store.dispatch(
        tutasApi.endpoints.getPipeQrCodeImage.initiate({ pipeId })
      );

      expect(result.error).toBeDefined();
      expect(result.isError).toBe(true);
    });
  });

  describe('createPipe with QR code', () => {
    it('should create pipe with auto-generated QR code', async () => {
      const pipeData = {
        company: 'TEST',
        manufacturer: 'Test Manufacturer',
        material: 'Steel',
        diameter_mm: 100,
      };

      const mockPipe: Pipe = {
        id: 'pipe-123',
        qr_code: 'PL-TEST-123e4567-e89b-12d3-a456-426614174000',
        ...pipeData,
        current_status: 'active',
      };

      (global.fetch as any).mockResolvedValueOnce({
        ok: true,
        status: 201,
        json: async () => mockPipe,
      });

      const result = await store.dispatch(
        tutasApi.endpoints.createPipe.initiate(pipeData)
      );

      expect(result.data).toBeDefined();
      expect(result.data?.qr_code).toMatch(/^PL-TEST-/);
    });

    it('should create pipe with custom QR code', async () => {
      const customQrCode = 'PL-CUSTOM-123e4567-e89b-12d3-a456-426614174000';
      const pipeData = {
        company: 'CUSTOM',
        qr_code: customQrCode,
        manufacturer: 'Test Manufacturer',
        material: 'Steel',
        diameter_mm: 100,
      };

      const mockPipe: Pipe = {
        id: 'pipe-123',
        ...pipeData,
        current_status: 'active',
      };

      (global.fetch as any).mockResolvedValueOnce({
        ok: true,
        status: 201,
        json: async () => mockPipe,
      });

      const result = await store.dispatch(
        tutasApi.endpoints.createPipe.initiate(pipeData)
      );

      expect(result.data?.qr_code).toBe(customQrCode);
    });
  });
});
