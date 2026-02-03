import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import '../../../lib/data/api/api_client.dart';
import '../../../lib/data/models/defect_dto.dart';
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

  group('ApiClient', () {
    group('postDefect', () {
      test('should post defect successfully', () async {
        // Arrange
        final defect = MockData.createDefectDto();
        mockApiClient.setupPostDefectSuccess(defect);

        // Act
        final result = await mockApiClient.postDefect(defect);

        // Assert
        expect(result, isA<DefectDto>());
        expect(result.id, defect.id);
      });

      test('should throw ConflictException on 409 status', () async {
        // Arrange
        final defect = MockData.createDefectDto();
        mockApiClient.setupPostDefectError(
          ConflictException(
            serverVersion: {'id': 'server-id'},
            message: 'Conflict occurred',
          ),
        );

        // Act & Assert
        expect(
          () => mockApiClient.postDefect(defect),
          throwsA(isA<ConflictException>()),
        );
      });
    });

    group('getPipe', () {
      test('should get pipe successfully', () async {
        // Arrange
        final pipe = MockData.createPipeDto();
        mockApiClient.setupGetPipeSuccess(pipe);

        // Act
        final result = await mockApiClient.getPipe('PL-COMPANY-pipe-123');

        // Assert
        expect(result, isA<PipeDto>());
        expect(result.id, pipe.id);
      });

      test('should throw ApiException on 404', () async {
        // Arrange
        mockApiClient.setupGetPipeError(
          ApiException(statusCode: 404, message: 'Pipe not found'),
        );

        // Act & Assert
        expect(
          () => mockApiClient.getPipe('invalid-id'),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('getAllPipes', () {
      test('should get all pipes successfully', () async {
        // Arrange
        final pipes = MockData.createPipeList(count: 3);
        mockApiClient.setupGetAllPipesSuccess(pipes);

        // Act
        final result = await mockApiClient.getAllPipes();

        // Assert
        expect(result, isA<List<PipeDto>>());
        expect(result.length, 3);
      });
    });

    group('chatWithAI', () {
      test('should chat with AI successfully', () async {
        // Arrange
        final chatResponse = ChatResponse(
          response: 'Test response',
          conversationId: 'conv-123',
          timestamp: DateTime.now(),
        );
        mockApiClient.setupChatWithAISuccess(chatResponse);

        // Act
        final result = await mockApiClient.chatWithAI('Hello');

        // Assert
        expect(result, isA<ChatResponse>());
        expect(result.response, 'Test response');
      });
    });

    group('getDashboardStats', () {
      test('should get dashboard stats successfully', () async {
        // Arrange
        final stats = MockData.dashboardStats;
        mockApiClient.setupGetDashboardStatsSuccess(stats);

        // Act
        final result = await mockApiClient.getDashboardStats();

        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result['total_pipes'], 100);
      });
    });
  });
}
