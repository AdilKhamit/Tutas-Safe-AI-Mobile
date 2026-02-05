import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import '../../../lib/repositories/pipe_repository.dart';
import '../../../lib/data/local/database.dart';
import '../../../lib/data/models/pipe_dto.dart';
import '../../../lib/data/api/api_client.dart';
import '../../mocks/mock_database.dart';
import '../../mocks/mock_api_client.dart';
import '../../fixtures/mock_data.dart';
import '../../helpers/test_helpers.dart';

void main() {
  late MockAppDatabase mockDatabase;
  late MockApiClient mockApiClient;
  late PipeRepository repository;

  setUpAll(() {
    TestHelpers.setupTestEnvironment();
  });

  setUp(() {
    mockDatabase = MockAppDatabase();
    mockApiClient = MockApiClient();
    repository = PipeRepository(
      database: mockDatabase,
      apiClient: mockApiClient,
    );
  });

  group('PipeRepository QR Code Tests', () {
    group('getPipeByQrCode', () {
      test('should get pipe by QR code from local database', () async {
        // Arrange
        final qrCode = 'PL-COMPANY-123e4567-e89b-12d3-a456-426614174000';
        final localPipe = LocalPipe(
          id: 'pipe-123',
          qrCode: qrCode,
          manufacturer: 'Test Manufacturer',
          material: 'Steel',
          diameterMm: 100,
          riskScore: 0.5,
          predictedLifetimeYears: 20,
          currentStatus: 'active',
          wallThicknessMm: 5.0,
          lengthMeters: 10.0,
          location: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(() => mockDatabase.getPipeByQrCode(qrCode))
            .thenAnswer((_) async => localPipe);

        // Act
        final result = await repository.getPipeByQrCode(qrCode);

        // Assert
        expect(result, isNotNull);
        expect(result?.qrCode, equals(qrCode));
        expect(result?.id, equals('pipe-123'));
        verify(() => mockDatabase.getPipeByQrCode(qrCode)).called(1);
      });

      test('should return null when pipe not found by QR code', () async {
        // Arrange
        final qrCode = 'PL-COMPANY-NOTFOUND';
        when(() => mockDatabase.getPipeByQrCode(qrCode))
            .thenAnswer((_) async => null);

        // Act
        final result = await repository.getPipeByQrCode(qrCode);

        // Assert
        expect(result, isNull);
        verify(() => mockDatabase.getPipeByQrCode(qrCode)).called(1);
      });

      test('should handle QR codes with different formats', () async {
        // Arrange
        final qrCodes = [
          'PL-COMPANY-123',
          'PL-TUTAS-9757a1cd-8292-4535-8e44-979d608a2588',
          'PL-MYCOMPANY-abc123',
        ];

        for (final qrCode in qrCodes) {
          final localPipe = LocalPipe(
            id: 'pipe-${qrCode.hashCode}',
            qrCode: qrCode,
            manufacturer: 'Test',
            material: 'Steel',
            diameterMm: 100,
            riskScore: 0.5,
            predictedLifetimeYears: 20,
            currentStatus: 'active',
            wallThicknessMm: 5.0,
            lengthMeters: 10.0,
            location: null,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          when(() => mockDatabase.getPipeByQrCode(qrCode))
              .thenAnswer((_) async => localPipe);

          // Act
          final result = await repository.getPipeByQrCode(qrCode);

          // Assert
          expect(result, isNotNull);
          expect(result?.qrCode, equals(qrCode));
        }
      });
    });

    group('loadPipeFromApi', () {
      test('should load pipe from API by QR code and save locally', () async {
        // Arrange
        final qrCode = 'PL-COMPANY-123e4567-e89b-12d3-a456-426614174000';
        final pipeDto = MockData.createPipeDto(
          id: 'pipe-123',
          qrCode: qrCode,
        );
        final localPipe = LocalPipe(
          id: 'pipe-123',
          qrCode: qrCode,
          manufacturer: pipeDto.manufacturer,
          material: pipeDto.material,
          diameterMm: pipeDto.diameterMm,
          riskScore: pipeDto.riskScore,
          predictedLifetimeYears: pipeDto.predictedLifetimeYears,
          currentStatus: pipeDto.currentStatus,
          wallThicknessMm: pipeDto.wallThicknessMm,
          lengthMeters: pipeDto.lengthMeters,
          location: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        mockApiClient.setupGetPipeSuccess(pipeDto);
        when(() => mockDatabase.savePipe(any())).thenAnswer((_) async => {});
        when(() => mockDatabase.getPipeByQrCode(qrCode))
            .thenAnswer((_) async => localPipe);

        // Act
        final result = await repository.loadPipeFromApi(qrCode);

        // Assert
        expect(result, isNotNull);
        expect(result?.qrCode, equals(qrCode));
        verify(() => mockApiClient.getPipe(qrCode)).called(1);
        verify(() => mockDatabase.savePipe(any())).called(1);
        verify(() => mockDatabase.getPipeByQrCode(qrCode)).called(1);
      });

      test('should return null when API call fails', () async {
        // Arrange
        final qrCode = 'PL-COMPANY-NOTFOUND';
        mockApiClient.setupGetPipeError(
          ApiException(
            statusCode: 404,
            message: 'Pipe not found',
          ),
        );

        // Act
        final result = await repository.loadPipeFromApi(qrCode);

        // Assert
        expect(result, isNull);
        verify(() => mockApiClient.getPipe(qrCode)).called(1);
        verifyNever(() => mockDatabase.savePipe(any()));
      });

      test('should return null when API client is not available', () async {
        // Arrange
        final repositoryWithoutApi = PipeRepository(
          database: mockDatabase,
          apiClient: null,
        );
        final qrCode = 'PL-COMPANY-123';

        // Act
        final result = await repositoryWithoutApi.loadPipeFromApi(qrCode);

        // Assert
        expect(result, isNull);
        verifyNever(() => mockDatabase.savePipe(any()));
      });

      test('should handle network errors gracefully', () async {
        // Arrange
        final qrCode = 'PL-COMPANY-123';
        mockApiClient.setupGetPipeError(
          NetworkException(
            message: 'No internet connection',
            originalError: Exception('Network error'),
          ),
        );

        // Act
        final result = await repository.loadPipeFromApi(qrCode);

        // Assert
        expect(result, isNull);
        verify(() => mockApiClient.getPipe(qrCode)).called(1);
      });
    });

    group('savePipe with QR code', () {
      test('should save pipe with QR code to local database', () async {
        // Arrange
        final pipeDto = MockData.createPipeDto(
          id: 'pipe-123',
          qrCode: 'PL-COMPANY-123e4567-e89b-12d3-a456-426614174000',
        );

        when(() => mockDatabase.savePipe(any())).thenAnswer((_) async => {});

        // Act
        await repository.savePipe(pipeDto);

        // Assert
        verify(() => mockDatabase.savePipe(any())).called(1);
      });

      test('should save pipe with different QR code formats', () async {
        // Arrange
        final qrCodes = [
          'PL-COMPANY-123',
          'PL-TUTAS-9757a1cd-8292-4535-8e44-979d608a2588',
          'PL-MYCOMPANY-abc123',
        ];

        when(() => mockDatabase.savePipe(any())).thenAnswer((_) async => {});

        for (final qrCode in qrCodes) {
          final pipeDto = MockData.createPipeDto(
            id: 'pipe-${qrCode.hashCode}',
            qrCode: qrCode,
          );

          // Act
          await repository.savePipe(pipeDto);

          // Assert
          verify(() => mockDatabase.savePipe(any())).called(1);
        }
      });
    });

    group('QR code validation in repository', () {
      test('should handle valid QR codes correctly', () async {
        // Arrange
        final validQRCodes = [
          'PL-COMPANY-123e4567-e89b-12d3-a456-426614174000',
          'PL-TUTAS-9757a1cd-8292-4535-8e44-979d608a2588',
          'PL-TEST-abc123',
        ];

        when(() => mockDatabase.getPipeByQrCode(any()))
            .thenAnswer((_) async => null);

        for (final qrCode in validQRCodes) {
          // Act
          final result = await repository.getPipeByQrCode(qrCode);

          // Assert
          // Should not throw, even if not found
          expect(result, isNull);
          verify(() => mockDatabase.getPipeByQrCode(qrCode)).called(1);
        }
      });
    });
  });
}
