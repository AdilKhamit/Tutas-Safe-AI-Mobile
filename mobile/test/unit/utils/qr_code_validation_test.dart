import 'package:flutter_test/flutter_test.dart';
import 'package:tutas_ai_mobile/core/utils/qr_validator.dart';

void main() {
  group('QrValidator', () {
    group('isValidQrCode', () {
      test('should return true for valid QR codes', () {
        final validQRCodes = [
          'PL-COMPANY-123e4567-e89b-12d3-a456-426614174000',
          'PL-TUTAS-9757a1cd-8292-4535-8e44-979d608a2588',
          'PL-TEST-abc123',
          'PL-COMPANY-123',
          'PL-MYCOMPANY-123e4567-e89b-12d3-a456-426614174000',
        ];

        for (final qrCode in validQRCodes) {
          expect(
            QrValidator.isValidQrCode(qrCode),
            isTrue,
            reason: 'QR code should be valid: $qrCode',
          );
        }
      });

      test('should return false for invalid QR codes', () {
        final invalidQRCodes = [
          null,
          '',
          'INVALID-FORMAT',
          'PL-',
          'PL-COMPANY',
          'COMPANY-123',
          'pl-company-123', // lowercase prefix
          'PL-COMPANY-', // empty identifier
          'PL--123', // empty company name
          'PL-COMPANY', // missing identifier
        ];

        for (final qrCode in invalidQRCodes) {
          expect(
            QrValidator.isValidQrCode(qrCode),
            isFalse,
            reason: 'QR code should be invalid: $qrCode',
          );
        }
      });

      test('should handle whitespace correctly', () {
        expect(QrValidator.isValidQrCode('  PL-COMPANY-123  '), isTrue);
        expect(QrValidator.isValidQrCode('PL-COMPANY-123 '), isTrue);
        expect(QrValidator.isValidQrCode(' PL-COMPANY-123'), isTrue);
      });

      test('should return false for QR codes shorter than minimum length', () {
        expect(QrValidator.isValidQrCode('PL-A-1'), isFalse);
        expect(QrValidator.isValidQrCode('PL-AB-12'), isFalse);
      });

      test('should return false for QR codes without PL prefix', () {
        expect(QrValidator.isValidQrCode('COMPANY-123'), isFalse);
        expect(QrValidator.isValidQrCode('TEST-COMPANY-123'), isFalse);
      });
    });

    group('extractQrCode', () {
      test('should return trimmed QR code for valid input', () {
        expect(
          QrValidator.extractQrCode('PL-COMPANY-123'),
          equals('PL-COMPANY-123'),
        );
        expect(
          QrValidator.extractQrCode('  PL-COMPANY-123  '),
          equals('PL-COMPANY-123'),
        );
      });

      test('should return null for invalid QR codes', () {
        expect(QrValidator.extractQrCode(null), isNull);
        expect(QrValidator.extractQrCode(''), isNull);
        expect(QrValidator.extractQrCode('INVALID'), isNull);
        expect(QrValidator.extractQrCode('PL-COMPANY'), isNull);
      });
    });

    group('belongsToCompany', () {
      test('should return true when QR code belongs to company', () {
        expect(
          QrValidator.belongsToCompany('PL-COMPANY-123', 'COMPANY'),
          isTrue,
        );
        expect(
          QrValidator.belongsToCompany('PL-TUTAS-456', 'TUTAS'),
          isTrue,
        );
        expect(
          QrValidator.belongsToCompany('PL-MYCOMPANY-789', 'MYCOMPANY'),
          isTrue,
        );
      });

      test('should be case-insensitive', () {
        expect(
          QrValidator.belongsToCompany('PL-COMPANY-123', 'company'),
          isTrue,
        );
        expect(
          QrValidator.belongsToCompany('PL-company-123', 'COMPANY'),
          isTrue,
        );
        expect(
          QrValidator.belongsToCompany('PL-Company-123', 'company'),
          isTrue,
        );
      });

      test('should return false when QR code does not belong to company', () {
        expect(
          QrValidator.belongsToCompany('PL-COMPANY-123', 'OTHER'),
          isFalse,
        );
        expect(
          QrValidator.belongsToCompany('PL-TUTAS-456', 'COMPANY'),
          isFalse,
        );
      });

      test('should return false for invalid QR codes', () {
        expect(
          QrValidator.belongsToCompany(null, 'COMPANY'),
          isFalse,
        );
        expect(
          QrValidator.belongsToCompany('', 'COMPANY'),
          isFalse,
        );
        expect(
          QrValidator.belongsToCompany('INVALID', 'COMPANY'),
          isFalse,
        );
      });
    });

    group('QR code format edge cases', () {
      test('should handle UUID format correctly', () {
        final uuidQR = 'PL-COMPANY-123e4567-e89b-12d3-a456-426614174000';
        expect(QrValidator.isValidQrCode(uuidQR), isTrue);
        expect(QrValidator.extractQrCode(uuidQR), equals(uuidQR));
      });

      test('should handle short identifiers', () {
        expect(QrValidator.isValidQrCode('PL-COMPANY-1'), isTrue);
        expect(QrValidator.isValidQrCode('PL-COMPANY-12'), isTrue);
        expect(QrValidator.isValidQrCode('PL-COMPANY-123'), isTrue);
      });

      test('should handle long company names', () {
        final longCompany = 'A' * 50;
        final qrCode = 'PL-$longCompany-123';
        expect(QrValidator.isValidQrCode(qrCode), isTrue);
        expect(
          QrValidator.belongsToCompany(qrCode, longCompany),
          isTrue,
        );
      });

      test('should handle special characters in identifier', () {
        // QR codes with special characters in identifier part
        expect(QrValidator.isValidQrCode('PL-COMPANY-123-456'), isTrue);
        expect(QrValidator.isValidQrCode('PL-COMPANY-abc-def'), isTrue);
      });
    });
  });
}
