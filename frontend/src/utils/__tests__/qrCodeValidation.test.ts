import { describe, it, expect } from 'vitest';
import {
  isValidQrCode,
  extractQrCode,
  belongsToCompany,
  parseQrCode,
  extractCompany,
  extractIdentifier,
  isUuidFormat,
} from '../qrCodeValidation';

describe('QR Code Validation', () => {
  describe('isValidQrCode', () => {
    it('should return true for valid QR codes', () => {
      const validQRCodes = [
        'PL-COMPANY-123e4567-e89b-12d3-a456-426614174000',
        'PL-TUTAS-9757a1cd-8292-4535-8e44-979d608a2588',
        'PL-TEST-abc123',
        'PL-COMPANY-123',
        'PL-MYCOMPANY-123e4567-e89b-12d3-a456-426614174000',
      ];

      validQRCodes.forEach((qrCode) => {
        expect(isValidQrCode(qrCode), `QR code should be valid: ${qrCode}`).toBe(true);
      });
    });

    it('should return false for invalid QR codes', () => {
      const invalidQRCodes = [
        null,
        undefined,
        '',
        'INVALID-FORMAT',
        'PL-',
        'PL-COMPANY',
        'COMPANY-123',
        'pl-company-123', // lowercase prefix
        'PL-COMPANY-', // empty identifier
        'PL--123', // empty company name
      ];

      invalidQRCodes.forEach((qrCode) => {
        expect(isValidQrCode(qrCode), `QR code should be invalid: ${qrCode}`).toBe(false);
      });
    });

    it('should handle whitespace correctly', () => {
      expect(isValidQrCode('  PL-COMPANY-123  ')).toBe(true);
      expect(isValidQrCode('PL-COMPANY-123 ')).toBe(true);
      expect(isValidQrCode(' PL-COMPANY-123')).toBe(true);
    });

    it('should return false for QR codes shorter than minimum length', () => {
      expect(isValidQrCode('PL-A-1')).toBe(false);
      expect(isValidQrCode('PL-AB-12')).toBe(false);
    });

    it('should return false for QR codes without PL prefix', () => {
      expect(isValidQrCode('COMPANY-123')).toBe(false);
      expect(isValidQrCode('TEST-COMPANY-123')).toBe(false);
    });
  });

  describe('extractQrCode', () => {
    it('should return trimmed QR code for valid input', () => {
      expect(extractQrCode('PL-COMPANY-123')).toBe('PL-COMPANY-123');
      expect(extractQrCode('  PL-COMPANY-123  ')).toBe('PL-COMPANY-123');
    });

    it('should return null for invalid QR codes', () => {
      expect(extractQrCode(null)).toBeNull();
      expect(extractQrCode(undefined)).toBeNull();
      expect(extractQrCode('')).toBeNull();
      expect(extractQrCode('INVALID')).toBeNull();
      expect(extractQrCode('PL-COMPANY')).toBeNull();
    });
  });

  describe('belongsToCompany', () => {
    it('should return true when QR code belongs to company', () => {
      expect(belongsToCompany('PL-COMPANY-123', 'COMPANY')).toBe(true);
      expect(belongsToCompany('PL-TUTAS-456', 'TUTAS')).toBe(true);
      expect(belongsToCompany('PL-MYCOMPANY-789', 'MYCOMPANY')).toBe(true);
    });

    it('should be case-insensitive', () => {
      expect(belongsToCompany('PL-COMPANY-123', 'company')).toBe(true);
      expect(belongsToCompany('PL-company-123', 'COMPANY')).toBe(true);
      expect(belongsToCompany('PL-Company-123', 'company')).toBe(true);
    });

    it('should return false when QR code does not belong to company', () => {
      expect(belongsToCompany('PL-COMPANY-123', 'OTHER')).toBe(false);
      expect(belongsToCompany('PL-TUTAS-456', 'COMPANY')).toBe(false);
    });

    it('should return false for invalid QR codes', () => {
      expect(belongsToCompany(null, 'COMPANY')).toBe(false);
      expect(belongsToCompany(undefined, 'COMPANY')).toBe(false);
      expect(belongsToCompany('', 'COMPANY')).toBe(false);
      expect(belongsToCompany('INVALID', 'COMPANY')).toBe(false);
    });
  });

  describe('parseQrCode', () => {
    it('should parse valid QR code correctly', () => {
      const qrCode = 'PL-COMPANY-123e4567-e89b-12d3-a456-426614174000';
      const parsed = parseQrCode(qrCode);

      expect(parsed.valid).toBe(true);
      expect(parsed.prefix).toBe('PL');
      expect(parsed.company).toBe('COMPANY');
      expect(parsed.identifier).toBe('123e4567-e89b-12d3-a456-426614174000');
      expect(parsed.fullCode).toBe(qrCode);
    });

    it('should return invalid for null or empty QR code', () => {
      expect(parseQrCode(null).valid).toBe(false);
      expect(parseQrCode(undefined).valid).toBe(false);
      expect(parseQrCode('').valid).toBe(false);
    });

    it('should return invalid for invalid QR code format', () => {
      expect(parseQrCode('INVALID').valid).toBe(false);
      expect(parseQrCode('PL-COMPANY').valid).toBe(false);
    });

    it('should handle short identifiers', () => {
      const qrCode = 'PL-COMPANY-123';
      const parsed = parseQrCode(qrCode);

      expect(parsed.valid).toBe(true);
      expect(parsed.identifier).toBe('123');
    });

    it('should handle multiple dashes in identifier', () => {
      const qrCode = 'PL-COMPANY-123-456-789';
      const parsed = parseQrCode(qrCode);

      expect(parsed.valid).toBe(true);
      expect(parsed.identifier).toBe('123-456-789');
    });
  });

  describe('extractCompany', () => {
    it('should extract company name from valid QR code', () => {
      expect(extractCompany('PL-COMPANY-123')).toBe('COMPANY');
      expect(extractCompany('PL-TUTAS-456')).toBe('TUTAS');
      expect(extractCompany('PL-MYCOMPANY-789')).toBe('MYCOMPANY');
    });

    it('should return null for invalid QR codes', () => {
      expect(extractCompany(null)).toBeNull();
      expect(extractCompany(undefined)).toBeNull();
      expect(extractCompany('')).toBeNull();
      expect(extractCompany('INVALID')).toBeNull();
      expect(extractCompany('PL-COMPANY')).toBeNull();
    });
  });

  describe('extractIdentifier', () => {
    it('should extract identifier from valid QR code', () => {
      expect(extractIdentifier('PL-COMPANY-123')).toBe('123');
      expect(extractIdentifier('PL-COMPANY-123e4567-e89b-12d3-a456-426614174000')).toBe(
        '123e4567-e89b-12d3-a456-426614174000'
      );
    });

    it('should return null for invalid QR codes', () => {
      expect(extractIdentifier(null)).toBeNull();
      expect(extractIdentifier(undefined)).toBeNull();
      expect(extractIdentifier('')).toBeNull();
      expect(extractIdentifier('INVALID')).toBeNull();
    });
  });

  describe('isUuidFormat', () => {
    it('should return true for valid UUID format', () => {
      const validUuids = [
        '123e4567-e89b-12d3-a456-426614174000',
        '9757a1cd-8292-4535-8e44-979d608a2588',
        '00000000-0000-0000-0000-000000000000',
        'FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF',
      ];

      validUuids.forEach((uuid) => {
        expect(isUuidFormat(uuid), `Should be valid UUID: ${uuid}`).toBe(true);
      });
    });

    it('should return false for invalid UUID format', () => {
      const invalidUuids = [
        '123',
        '123e4567',
        '123e4567-e89b-12d3',
        '123e4567-e89b-12d3-a456',
        '123e4567-e89b-12d3-a456-42661417400', // too short
        '123e4567-e89b-12d3-a456-4266141740000', // too long
        '123e4567-e89b-12d3-a456-42661417400g', // invalid character
        'not-a-uuid',
      ];

      invalidUuids.forEach((uuid) => {
        expect(isUuidFormat(uuid), `Should be invalid UUID: ${uuid}`).toBe(false);
      });
    });

    it('should be case-insensitive', () => {
      expect(isUuidFormat('123E4567-E89B-12D3-A456-426614174000')).toBe(true);
      expect(isUuidFormat('123e4567-E89B-12d3-A456-426614174000')).toBe(true);
    });
  });
});
