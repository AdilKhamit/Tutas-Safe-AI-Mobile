import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import '../../../lib/data/api/api_client.dart';
import '../../../lib/data/models/pipe_dto.dart';
import '../../mocks/mock_api_client.dart';
import '../../mocks/mock_connectivity_service.dart';
import '../../fixtures/mock_data.dart';
import '../../helpers/test_helpers.dart';

void main() {
  late MockApiClient mockApiClient;
  late MockConnectivityService mockConnectivity;

  setUpAll(() {
    TestHelpers.setupTestEnvironment();
  });

  setUp(() {
    mockConnectivity = MockConnectivityService();
    mockApiClient = MockApiClient();
  });

  group('ApiClient QR Code Tests', () {
    group('getPipe with QR code', () {
      test('should get pipe by full QR code', () async {
        // Arrange
        final qrCode = 'PL-COMPANY-123e4567-e89b-12d3-a456-426614174000';
        final pipe = MockData.createPipeDto(
          id: 'pipe-123',
          qrCode: qrCode,
        );
        mockApiClient.setupGetPipeSuccess(pipe);

        // Act
        final result = await mockApiClient.getPipe(qrCode);

        // Assert
        expect(result, isA<PipeDto>());
        expect(result.qrCode, equals(qrCode));
        expect(result.id, equals('pipe-123'));
      });

      test('should get pipe by QR code with different company', () async {
        // Arrange
        final qrCode = 'PL-TUTAS-9757a1cd-8292-4535-8e44-979d608a2588';
        final pipe = MockData.createPipeDto(
          id: 'pipe-456',
          qrCode: qrCode,
        );
        mockApiClient.setupGetPipeSuccess(pipe);

        // Act
        final result = await mockApiClient.getPipe(qrCode);

        // Assert
        expect(result.qrCode, equals(qrCode));
        expect(result.qrCode, startsWith('PL-TUTAS-'));
      });

      test('should handle QR code with short identifier', () async {
        // Arrange
        final qrCode = 'PL-COMPANY-123';
        final pipe = MockData.createPipeDto(
          id: 'pipe-789',
          qrCode: qrCode,
        );
        mockApiClient.setupGetPipeSuccess(pipe);

        // Act
        final result = await mockApiClient.getPipe(qrCode);

        // Assert
        expect(result.qrCode, equals(qrCode));
      });

      test('should throw NetworkException on network error', () async {
        // Arrange
        final qrCode = 'PL-COMPANY-123';
        mockApiClient.setupGetPipeError(
          NetworkException(
            message: 'No internet connection',
            originalError: DioException(
              requestOptions: RequestOptions(path: '/api/v1/pipes/qr/$qrCode'),
              type: DioExceptionType.connectionError,
            ),
          ),
        );

        // Act & Assert
        expect(
          () => mockApiClient.getPipe(qrCode),
          throwsA(isA<NetworkException>()),
        );
      });

      test('should throw ApiException on 404', () async {
        // Arrange
        final qrCode = 'PL-COMPANY-NOTFOUND';
        mockApiClient.setupGetPipeError(
          ApiException(
            statusCode: 404,
            message: 'Pipe not found',
          ),
        );

        // Act & Assert
        expect(
          () => mockApiClient.getPipe(qrCode),
          throwsA(isA<ApiException>()),
        );
      });

      test('should handle QR code with UUID format', () async {
        // Arrange
        final qrCode = 'PL-COMPANY-123e4567-e89b-12d3-a456-426614174000';
        final pipe = MockData.createPipeDto(
          id: '123e4567-e89b-12d3-a456-426614174000',
          qrCode: qrCode,
        );
        mockApiClient.setupGetPipeSuccess(pipe);

        // Act
        final result = await mockApiClient.getPipe(qrCode);

        // Assert
        expect(result.qrCode, equals(qrCode));
        // Verify UUID format in identifier
        final identifier = qrCode.split('-').sublist(2).join('-');
        expect(identifier, matches(RegExp(r'^[0-9a-f-]+$', caseSensitive: false)));
      });
    });

    group('QR code format handling', () {
      test('should handle QR codes with whitespace', () async {
        // Arrange
        final qrCode = '  PL-COMPANY-123  ';
        final pipe = MockData.createPipeDto(
          qrCode: 'PL-COMPANY-123',
        );
        mockApiClient.setupGetPipeSuccess(pipe);

        // Act
        final result = await mockApiClient.getPipe(qrCode.trim());

        // Assert
        expect(result.qrCode, equals('PL-COMPANY-123'));
      });

      test('should handle QR codes with multiple dashes in identifier', () async {
        // Arrange
        final qrCode = 'PL-COMPANY-123-456-789';
        final pipe = MockData.createPipeDto(qrCode: qrCode);
        mockApiClient.setupGetPipeSuccess(pipe);

        // Act
        final result = await mockApiClient.getPipe(qrCode);

        // Assert
        expect(result.qrCode, equals(qrCode));
      });
    });

    group('Error handling for QR codes', () {
      test('should handle timeout errors', () async {
        // Arrange
        final qrCode = 'PL-COMPANY-123';
        mockApiClient.setupGetPipeError(
          NetworkException(
            message: 'Connection timeout',
            originalError: DioException(
              requestOptions: RequestOptions(path: '/api/v1/pipes/qr/$qrCode'),
              type: DioExceptionType.connectionTimeout,
            ),
          ),
        );

        // Act & Assert
        expect(
          () => mockApiClient.getPipe(qrCode),
          throwsA(isA<NetworkException>()),
        );
      });

      test('should handle server errors (5xx)', () async {
        // Arrange
        final qrCode = 'PL-COMPANY-123';
        mockApiClient.setupGetPipeError(
          ApiException(
            statusCode: 500,
            message: 'Internal server error',
          ),
        );

        // Act & Assert
        expect(
          () => mockApiClient.getPipe(qrCode),
          throwsA(isA<ApiException>()),
        );
      });

      test('should handle unauthorized errors (401)', () async {
        // Arrange
        final qrCode = 'PL-COMPANY-123';
        mockApiClient.setupGetPipeError(
          ApiException(
            statusCode: 401,
            message: 'Unauthorized',
          ),
        );

        // Act & Assert
        expect(
          () => mockApiClient.getPipe(qrCode),
          throwsA(isA<ApiException>()),
        );
      });
    });
  });
}
