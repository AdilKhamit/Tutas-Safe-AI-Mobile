import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tutas_ai_mobile/main.dart' as app;
import 'package:tutas_ai_mobile/core/utils/qr_validator.dart';
import 'helpers/integration_test_helpers.dart';

/// E2E test for complete QR code flow
/// Tests: QR code validation → API call → Display pipe data
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('E2E QR Code Full Flow', () {
    testWidgets('should validate QR code and process complete flow', (WidgetTester tester) async {
      // Start the app
      app.main();
      await IntegrationTestHelpers.waitForAppReady(tester);

      // Step 1: Validate QR code format
      final qrCode = 'PL-COMPANY-123e4567-e89b-12d3-a456-426614174000';
      
      expect(QrValidator.isValidQrCode(qrCode), isTrue,
             reason: 'QR code should be valid');
      
      // Step 2: Extract components
      final parts = qrCode.split('-');
      expect(parts.length, greaterThanOrEqualTo(3),
             reason: 'QR code should have at least 3 parts');
      expect(parts[0], equals('PL'),
             reason: 'QR code should start with PL');
      expect(parts[1], equals('COMPANY'),
             reason: 'Company name should be extracted correctly');
      
      // Step 3: Validate identifier (UUID format)
      final identifier = parts.sublist(2).join('-');
      expect(identifier, isNotEmpty,
             reason: 'Identifier should not be empty');
      
      // Step 4: Verify QR code belongs to company
      expect(QrValidator.belongsToCompany(qrCode, 'COMPANY'), isTrue,
             reason: 'QR code should belong to COMPANY');
      expect(QrValidator.belongsToCompany(qrCode, 'OTHER'), isFalse,
             reason: 'QR code should not belong to OTHER');
    });

    testWidgets('should handle complete QR code scanning flow', (WidgetTester tester) async {
      app.main();
      await IntegrationTestHelpers.waitForAppReady(tester);

      // Test multiple QR codes
      final testQRCodes = [
        'PL-COMPANY-123e4567-e89b-12d3-a456-426614174000',
        'PL-TUTAS-9757a1cd-8292-4535-8e44-979d608a2588',
        'PL-TEST-abc123',
      ];

      for (final qrCode in testQRCodes) {
        // Validate format
        expect(QrValidator.isValidQrCode(qrCode), isTrue,
               reason: 'QR code should be valid: $qrCode');
        
        // Extract company
        final extracted = QrValidator.extractQrCode(qrCode);
        expect(extracted, isNotNull,
               reason: 'QR code should be extracted: $qrCode');
        expect(extracted, equals(qrCode),
               reason: 'Extracted QR code should match original');
        
        // Parse components
        final parts = qrCode.split('-');
        final company = parts.length > 1 ? parts[1] : '';
        expect(company, isNotEmpty,
               reason: 'Company name should not be empty');
      }
    });

    testWidgets('should handle invalid QR codes gracefully', (WidgetTester tester) async {
      app.main();
      await IntegrationTestHelpers.waitForAppReady(tester);

      final invalidQRCodes = [
        null,
        '',
        'INVALID-FORMAT',
        'PL-',
        'PL-COMPANY',
        'COMPANY-123',
      ];

      for (final qrCode in invalidQRCodes) {
        expect(QrValidator.isValidQrCode(qrCode), isFalse,
               reason: 'QR code should be invalid: $qrCode');
        
        final extracted = QrValidator.extractQrCode(qrCode);
        expect(extracted, isNull,
               reason: 'Invalid QR code should return null');
      }
    });

    testWidgets('should handle QR code with whitespace', (WidgetTester tester) async {
      app.main();
      await IntegrationTestHelpers.waitForAppReady(tester);

      final qrCodeWithSpaces = '  PL-COMPANY-123  ';
      
      // Should be valid after trimming
      expect(QrValidator.isValidQrCode(qrCodeWithSpaces), isTrue,
             reason: 'QR code with whitespace should be valid');
      
      // Should extract trimmed version
      final extracted = QrValidator.extractQrCode(qrCodeWithSpaces);
      expect(extracted, equals('PL-COMPANY-123'),
             reason: 'Extracted QR code should be trimmed');
    });

    testWidgets('should handle company name extraction case-insensitively', (WidgetTester tester) async {
      app.main();
      await IntegrationTestHelpers.waitForAppReady(tester);

      final testCases = [
        ('PL-COMPANY-123', 'COMPANY', true),
        ('PL-company-123', 'COMPANY', true),
        ('PL-Company-123', 'company', true),
        ('PL-COMPANY-123', 'OTHER', false),
      ];

      for (final testCase in testCases) {
        final qrCode = testCase.$1;
        final company = testCase.$2;
        final expected = testCase.$3;
        
        expect(QrValidator.belongsToCompany(qrCode, company), expected,
               reason: 'Company check should be case-insensitive: $qrCode, $company');
      }
    });

    // Note: Full integration with API requires:
    // 1. Backend running and accessible
    // 2. Network connectivity
    // 3. Proper API configuration in .env
    // These tests can be extended to include actual API calls when backend is available
  });
}
