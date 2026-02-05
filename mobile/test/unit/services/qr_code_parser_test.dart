import 'package:flutter_test/flutter_test.dart';
import 'package:tutas_ai_mobile/core/utils/qr_validator.dart';

/// QR Code Parser utility class for extracting components from QR codes
class QrCodeParser {
  /// Parse QR code into components
  /// Returns map with 'prefix', 'company', 'identifier', and 'valid' keys
  static Map<String, dynamic> parseQrCode(String? qrCode) {
    if (qrCode == null || qrCode.isEmpty) {
      return {'valid': false};
    }

    if (!QrValidator.isValidQrCode(qrCode)) {
      return {'valid': false};
    }

    final trimmed = qrCode.trim();
    final parts = trimmed.split('-');

    return {
      'valid': true,
      'prefix': parts[0],
      'company': parts[1],
      'identifier': parts.sublist(2).join('-'),
      'fullCode': trimmed,
    };
  }

  /// Extract company name from QR code
  static String? extractCompany(String? qrCode) {
    final parsed = parseQrCode(qrCode);
    if (!parsed['valid'] as bool) {
      return null;
    }
    return parsed['company'] as String;
  }

  /// Extract identifier (UUID part) from QR code
  static String? extractIdentifier(String? qrCode) {
    final parsed = parseQrCode(qrCode);
    if (!parsed['valid'] as bool) {
      return null;
    }
    return parsed['identifier'] as String;
  }

  /// Check if identifier is a valid UUID format
  static bool isUuidFormat(String identifier) {
    // UUID format: 8-4-4-4-12 hex characters
    final uuidPattern = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    return uuidPattern.hasMatch(identifier);
  }
}

void main() {
  group('QrCodeParser', () {
    group('parseQrCode', () {
      test('should parse valid QR code correctly', () {
        final qrCode = 'PL-COMPANY-123e4567-e89b-12d3-a456-426614174000';
        final parsed = QrCodeParser.parseQrCode(qrCode);

        expect(parsed['valid'], isTrue);
        expect(parsed['prefix'], equals('PL'));
        expect(parsed['company'], equals('COMPANY'));
        expect(
          parsed['identifier'],
          equals('123e4567-e89b-12d3-a456-426614174000'),
        );
        expect(parsed['fullCode'], equals(qrCode));
      });

      test('should return invalid for null or empty QR code', () {
        expect(QrCodeParser.parseQrCode(null)['valid'], isFalse);
        expect(QrCodeParser.parseQrCode('')['valid'], isFalse);
      });

      test('should return invalid for invalid QR code format', () {
        expect(QrCodeParser.parseQrCode('INVALID')['valid'], isFalse);
        expect(QrCodeParser.parseQrCode('PL-COMPANY')['valid'], isFalse);
      });

      test('should handle short identifiers', () {
        final qrCode = 'PL-COMPANY-123';
        final parsed = QrCodeParser.parseQrCode(qrCode);

        expect(parsed['valid'], isTrue);
        expect(parsed['identifier'], equals('123'));
      });

      test('should handle multiple dashes in identifier', () {
        final qrCode = 'PL-COMPANY-123-456-789';
        final parsed = QrCodeParser.parseQrCode(qrCode);

        expect(parsed['valid'], isTrue);
        expect(parsed['identifier'], equals('123-456-789'));
      });
    });

    group('extractCompany', () {
      test('should extract company name from valid QR code', () {
        expect(
          QrCodeParser.extractCompany('PL-COMPANY-123'),
          equals('COMPANY'),
        );
        expect(
          QrCodeParser.extractCompany('PL-TUTAS-456'),
          equals('TUTAS'),
        );
        expect(
          QrCodeParser.extractCompany('PL-MYCOMPANY-789'),
          equals('MYCOMPANY'),
        );
      });

      test('should return null for invalid QR codes', () {
        expect(QrCodeParser.extractCompany(null), isNull);
        expect(QrCodeParser.extractCompany(''), isNull);
        expect(QrCodeParser.extractCompany('INVALID'), isNull);
        expect(QrCodeParser.extractCompany('PL-COMPANY'), isNull);
      });
    });

    group('extractIdentifier', () {
      test('should extract identifier from valid QR code', () {
        expect(
          QrCodeParser.extractIdentifier('PL-COMPANY-123'),
          equals('123'),
        );
        expect(
          QrCodeParser.extractIdentifier(
            'PL-COMPANY-123e4567-e89b-12d3-a456-426614174000',
          ),
          equals('123e4567-e89b-12d3-a456-426614174000'),
        );
      });

      test('should return null for invalid QR codes', () {
        expect(QrCodeParser.extractIdentifier(null), isNull);
        expect(QrCodeParser.extractIdentifier(''), isNull);
        expect(QrCodeParser.extractIdentifier('INVALID'), isNull);
      });
    });

    group('isUuidFormat', () {
      test('should return true for valid UUID format', () {
        final validUuids = [
          '123e4567-e89b-12d3-a456-426614174000',
          '9757a1cd-8292-4535-8e44-979d608a2588',
          '00000000-0000-0000-0000-000000000000',
          'FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF',
        ];

        for (final uuid in validUuids) {
          expect(
            QrCodeParser.isUuidFormat(uuid),
            isTrue,
            reason: 'Should be valid UUID: $uuid',
          );
        }
      });

      test('should return false for invalid UUID format', () {
        final invalidUuids = [
          '123',
          '123e4567',
          '123e4567-e89b-12d3',
          '123e4567-e89b-12d3-a456',
          '123e4567-e89b-12d3-a456-42661417400', // too short
          '123e4567-e89b-12d3-a456-4266141740000', // too long
          '123e4567-e89b-12d3-a456-42661417400g', // invalid character
          'not-a-uuid',
        ];

        for (final uuid in invalidUuids) {
          expect(
            QrCodeParser.isUuidFormat(uuid),
            isFalse,
            reason: 'Should be invalid UUID: $uuid',
          );
        }
      });

      test('should be case-insensitive', () {
        expect(
          QrCodeParser.isUuidFormat('123E4567-E89B-12D3-A456-426614174000'),
          isTrue,
        );
        expect(
          QrCodeParser.isUuidFormat('123e4567-E89B-12d3-A456-426614174000'),
          isTrue,
        );
      });
    });

    group('integration with QrValidator', () {
      test('should work correctly with QrValidator', () {
        final qrCode = 'PL-COMPANY-123e4567-e89b-12d3-a456-426614174000';

        // First validate
        expect(QrValidator.isValidQrCode(qrCode), isTrue);

        // Then parse
        final parsed = QrCodeParser.parseQrCode(qrCode);
        expect(parsed['valid'], isTrue);

        // Extract components
        final company = QrCodeParser.extractCompany(qrCode);
        final identifier = QrCodeParser.extractIdentifier(qrCode);

        expect(company, equals('COMPANY'));
        expect(identifier, isNotNull);
        expect(QrCodeParser.isUuidFormat(identifier!), isTrue);
      });
    });
  });
}
