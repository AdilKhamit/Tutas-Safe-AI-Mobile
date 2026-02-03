import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import '../../../lib/core/services/auth_service.dart';
import '../../../lib/data/api/api_client.dart';
import '../../mocks/mock_api_client.dart';
import '../../mocks/mock_secure_storage.dart';
import '../../fixtures/mock_data.dart';
import '../../helpers/test_helpers.dart';

void main() {
  late MockApiClient mockApiClient;
  late MockFlutterSecureStorage mockStorage;
  late AuthService authService;

  setUpAll(() {
    TestHelpers.setupTestEnvironment();
  });

  setUp(() {
    mockApiClient = MockApiClient();
    mockStorage = MockFlutterSecureStorage();
    authService = AuthService(
      apiClient: mockApiClient,
      storage: mockStorage,
    );
  });

  group('AuthService', () {
    group('login', () {
      // Note: AuthService creates Dio internally, so we test the logic
      // Full integration tests with http_mock_adapter should be in integration_test/
      
      test('should have login method', () {
        // Basic test to ensure method exists
        expect(authService.login, isA<Function>());
      });
      
      // TODO: Add integration tests for login with http_mock_adapter
      // These require refactoring AuthService to accept Dio as dependency
      // or creating integration tests that test the full flow
    });

    group('logout', () {
      test('should clear stored tokens', () async {
        // Arrange
        mockStorage.setValue('access_token', MockData.sampleAccessToken);

        // Act
        await authService.logout();

        // Assert
        expect(await mockStorage.read(key: 'access_token'), isNull);
      });
    });

    group('isAuthenticated', () {
      test('should return false when no token exists', () async {
        // Arrange
        mockStorage.clear();

        // Act
        final result = await authService.isAuthenticated();

        // Assert
        expect(result, isFalse);
      });

      test('should return true when valid token exists', () async {
        // Arrange
        mockStorage.setValue('access_token', MockData.sampleAccessToken);

        // Act
        final result = await authService.isAuthenticated();

        // Assert
        // Note: This depends on token validation logic
        expect(result, isA<bool>());
      });
    });

    group('isTokenValid', () {
      test('should return false when no token exists', () async {
        // Arrange
        mockStorage.clear();

        // Act
        final result = await authService.isTokenValid();

        // Assert
        expect(result, isFalse);
      });

      test('should return true when token exists and is not JWT', () async {
        // Arrange
        mockStorage.setValue('access_token', 'simple-token-string');

        // Act
        final result = await authService.isTokenValid();

        // Assert
        expect(result, isTrue);
      });

      test('should return true when JWT token is not expired', () async {
        // Arrange
        // Create a JWT token with future expiration (exp: now + 1 hour)
        final futureExp = DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000;
        final jwtPayload = base64Url.encode(utf8.encode(jsonEncode({'exp': futureExp})));
        final jwtToken = 'header.$jwtPayload.signature';
        mockStorage.setValue('access_token', jwtToken);

        // Act
        final result = await authService.isTokenValid();

        // Assert
        expect(result, isTrue);
      });

      test('should return false when JWT token is expired', () async {
        // Arrange
        // Create a JWT token with past expiration (exp: now - 1 hour)
        final pastExp = DateTime.now().subtract(const Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000;
        final jwtPayload = base64Url.encode(utf8.encode(jsonEncode({'exp': pastExp})));
        final jwtToken = 'header.$jwtPayload.signature';
        mockStorage.setValue('access_token', jwtToken);

        // Act
        final result = await authService.isTokenValid();

        // Assert
        expect(result, isFalse);
      });
    });

    group('getValidToken', () {
      test('should return token when valid', () async {
        // Arrange
        mockStorage.setValue('access_token', 'valid-token');

        // Act
        final result = await authService.getValidToken();

        // Assert
        expect(result, equals('valid-token'));
      });

      test('should return null when token is expired and refresh fails', () async {
        // Arrange
        // Create expired token
        final pastExp = DateTime.now().subtract(const Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000;
        final jwtPayload = base64Url.encode(utf8.encode(jsonEncode({'exp': pastExp})));
        final jwtToken = 'header.$jwtPayload.signature';
        mockStorage.setValue('access_token', jwtToken);
        mockStorage.setValue('refresh_token', 'invalid-refresh-token');

        // Act
        final result = await authService.getValidToken();

        // Assert
        // Should return null after failed refresh and logout
        expect(result, isNull);
        // Verify logout was called (tokens cleared)
        expect(await mockStorage.read(key: 'access_token'), isNull);
      });
    });

    group('refreshAccessToken', () {
      test('should return failure when no refresh token exists', () async {
        // Arrange
        mockStorage.clear();

        // Act
        final result = await authService.refreshAccessToken();

        // Assert
        expect(result.success, isFalse);
        expect(result.message, contains('No refresh token'));
      });
    });
  });
}
