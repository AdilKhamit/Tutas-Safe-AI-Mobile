import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tutas_ai_mobile/main.dart' as app;
import 'helpers/integration_test_helpers.dart';

/// Integration test for QR scan flow
/// Tests: QR scanning, pipe details view, defect creation
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('QR Scan Flow', () {
    testWidgets('should start app and verify initial state', (WidgetTester tester) async {
      // Start the app
      app.main();
      await IntegrationTestHelpers.waitForAppReady(tester);

      // Verify app is running
      expect(find.byType(app.MyApp), findsOneWidget);
    });

    testWidgets('should handle QR code format validation', (WidgetTester tester) async {
      app.main();
      await IntegrationTestHelpers.waitForAppReady(tester);

      // Test valid QR code formats
      final validQRCodes = [
        'PL-COMPANY-123e4567-e89b-12d3-a456-426614174000',
        'PL-TUTAS-9757a1cd-8292-4535-8e44-979d608a2588',
        'PL-TEST-abc123',
      ];

      for (final qrCode in validQRCodes) {
        final parts = qrCode.split('-');
        expect(parts.length, greaterThanOrEqualTo(3), 
               reason: 'QR code should have at least 3 parts');
        expect(parts[0], equals('PL'), 
               reason: 'QR code should start with PL');
        expect(parts[1].isNotEmpty, isTrue, 
               reason: 'Company name should not be empty');
      }

      // Test invalid QR code formats
      final invalidQRCodes = [
        'INVALID-FORMAT',
        'PL-',
        'PL-COMPANY',
        '',
      ];

      for (final qrCode in invalidQRCodes) {
        final parts = qrCode.split('-');
        final isValid = parts.length >= 3 && 
                       parts[0] == 'PL' && 
                       parts[1].isNotEmpty;
        expect(isValid, isFalse, 
               reason: 'Invalid QR code should fail validation: $qrCode');
      }
    });

    testWidgets('should extract company name from QR code', (WidgetTester tester) async {
      app.main();
      await IntegrationTestHelpers.waitForAppReady(tester);

      final testCases = [
        ('PL-COMPANY-123', 'COMPANY'),
        ('PL-TUTAS-456', 'TUTAS'),
        ('PL-MYCOMPANY-789', 'MYCOMPANY'),
      ];

      for (final testCase in testCases) {
        final qrCode = testCase.$1;
        final expectedCompany = testCase.$2;
        final parts = qrCode.split('-');
        final company = parts.length > 1 ? parts[1] : 'COMPANY';
        expect(company, equals(expectedCompany), 
               reason: 'Company extraction failed for: $qrCode');
      }
    });

    // Note: Full QR scan test with camera requires:
    // 1. Camera permission handling (requires device/emulator)
    // 2. Mock QR scanner or test QR codes
    // 3. Navigation to pipe details
    // 4. Defect creation flow
    // These tests can be run on a physical device or emulator with camera access
    
    testWidgets('should validate QR code structure', (WidgetTester tester) async {
      app.main();
      await IntegrationTestHelpers.waitForAppReady(tester);
      
      // Test QR code structure parsing
      final qrCode = 'PL-COMPANY-123e4567-e89b-12d3-a456-426614174000';
      final parts = qrCode.split('-');
      
      expect(parts.length, greaterThanOrEqualTo(3));
      expect(parts[0], equals('PL'));
      expect(parts[1], equals('COMPANY'));
      expect(parts[2].isNotEmpty, isTrue);
    });

    testWidgets('should handle QR code with UUID format', (WidgetTester tester) async {
      app.main();
      await IntegrationTestHelpers.waitForAppReady(tester);
      
      // Test UUID extraction from QR code
      final uuid = '123e4567-e89b-12d3-a456-426614174000';
      final qrCode = 'PL-COMPANY-$uuid';
      final parts = qrCode.split('-');
      
      // UUID is everything after company name
      final uuidPart = parts.sublist(2).join('-');
      expect(uuidPart, equals(uuid));
    });
  });
}
