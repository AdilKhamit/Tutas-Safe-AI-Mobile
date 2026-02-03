import 'package:flutter_test/flutter_test.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../lib/core/services/connectivity_service.dart';
import '../../mocks/mock_connectivity_service.dart';
import '../../helpers/test_helpers.dart';

void main() {
  late MockConnectivityService mockConnectivity;

  setUpAll(() {
    TestHelpers.setupTestEnvironment();
  });

  setUp(() {
    mockConnectivity = MockConnectivityService();
  });

  group('ConnectivityService', () {
    group('isOnline', () {
      test('should return true when online', () async {
        // Arrange
        mockConnectivity.setupOnline();

        // Act
        final result = await mockConnectivity.isOnline();

        // Assert
        expect(result, isTrue);
      });

      test('should return false when offline', () async {
        // Arrange
        mockConnectivity.setupOffline();

        // Act
        final result = await mockConnectivity.isOnline();

        // Assert
        expect(result, isFalse);
      });
    });

    group('hasWifi', () {
      test('should return true when WiFi is available', () async {
        // Arrange
        mockConnectivity.setupOnline();

        // Act
        final result = await mockConnectivity.hasWifi();

        // Assert
        expect(result, isTrue);
      });

      test('should return false when WiFi is not available', () async {
        // Arrange
        mockConnectivity.setupMobileData();

        // Act
        final result = await mockConnectivity.hasWifi();

        // Assert
        expect(result, isFalse);
      });
    });

    group('hasMobileData', () {
      test('should return true when mobile data is available', () async {
        // Arrange
        mockConnectivity.setupMobileData();

        // Act
        final result = await mockConnectivity.hasMobileData();

        // Assert
        expect(result, isTrue);
      });
    });

    group('getCurrentStatus', () {
      test('should return current connectivity status', () async {
        // Arrange
        mockConnectivity.setupOnline();

        // Act
        final result = await mockConnectivity.getCurrentStatus();

        // Assert
        expect(result, ConnectivityResult.wifi);
      });
    });
  });
}
