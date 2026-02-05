/**
 * QR Code validation utilities
 */

export interface ParsedQrCode {
  valid: boolean;
  prefix?: string;
  company?: string;
  identifier?: string;
  fullCode?: string;
}

const QR_PREFIX = 'PL-';
const MIN_LENGTH = 10;

/**
 * Validates QR code format
 * Format: PL-{COMPANY}-{UUID}
 * Example: PL-COMPANY-123e4567-e89b-12d3-a456-426614174000
 */
export function isValidQrCode(qrCode: string | null | undefined): boolean {
  if (!qrCode || qrCode.trim().length === 0) {
    return false;
  }

  const trimmed = qrCode.trim();

  // Check minimum length
  if (trimmed.length < MIN_LENGTH) {
    return false;
  }

  // Check prefix
  if (!trimmed.startsWith(QR_PREFIX)) {
    return false;
  }

  // Check format: PL-COMPANY-UUID
  // Should have at least 2 dashes (after PL and after COMPANY)
  const parts = trimmed.split('-');
  if (parts.length < 3) {
    return false;
  }

  // First part should be "PL"
  if (parts[0] !== 'PL') {
    return false;
  }

  // Second part - company name (not empty)
  if (parts[1].length === 0) {
    return false;
  }

  // Third and subsequent parts - UUID or identifier (not empty)
  const identifier = parts.slice(2).join('-');
  if (identifier.length === 0) {
    return false;
  }

  return true;
}

/**
 * Extracts QR code from input (trims whitespace)
 */
export function extractQrCode(qrCode: string | null | undefined): string | null {
  if (!isValidQrCode(qrCode)) {
    return null;
  }
  return qrCode!.trim();
}

/**
 * Checks if QR code belongs to a specific company
 */
export function belongsToCompany(
  qrCode: string | null | undefined,
  company: string
): boolean {
  if (!isValidQrCode(qrCode)) {
    return false;
  }

  const parts = qrCode!.trim().split('-');
  if (parts.length < 2) {
    return false;
  }

  return parts[1].toUpperCase() === company.toUpperCase();
}

/**
 * Parses QR code into components
 */
export function parseQrCode(qrCode: string | null | undefined): ParsedQrCode {
  if (!qrCode || qrCode.trim().length === 0) {
    return { valid: false };
  }

  if (!isValidQrCode(qrCode)) {
    return { valid: false };
  }

  const trimmed = qrCode.trim();
  const parts = trimmed.split('-');

  return {
    valid: true,
    prefix: parts[0],
    company: parts[1],
    identifier: parts.slice(2).join('-'),
    fullCode: trimmed,
  };
}

/**
 * Extracts company name from QR code
 */
export function extractCompany(qrCode: string | null | undefined): string | null {
  const parsed = parseQrCode(qrCode);
  if (!parsed.valid) {
    return null;
  }
  return parsed.company || null;
}

/**
 * Extracts identifier (UUID part) from QR code
 */
export function extractIdentifier(qrCode: string | null | undefined): string | null {
  const parsed = parseQrCode(qrCode);
  if (!parsed.valid) {
    return null;
  }
  return parsed.identifier || null;
}

/**
 * Checks if identifier is in UUID format
 */
export function isUuidFormat(identifier: string): boolean {
  // UUID format: 8-4-4-4-12 hex characters
  const uuidPattern = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
  return uuidPattern.test(identifier);
}
