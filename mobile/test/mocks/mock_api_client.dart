import 'package:mocktail/mocktail.dart';
import '../../lib/data/api/api_client.dart';
import '../../lib/data/models/defect_dto.dart';
import '../../lib/data/models/pipe_dto.dart';

/// Mock ApiClient for testing
class MockApiClient extends Mock implements ApiClient {
  MockApiClient() {
    // Setup default behaviors
    when(() => baseUrl).thenReturn('http://test-api.example.com');
    when(() => accessToken).thenReturn(null);
  }

  /// Setup successful postDefect response
  void setupPostDefectSuccess(DefectDto response) {
    when(() => postDefect(any())).thenAnswer((_) async => response);
  }

  /// Setup postDefect to throw exception
  void setupPostDefectError(Exception error) {
    when(() => postDefect(any())).thenThrow(error);
  }

  /// Setup successful getPipe response
  void setupGetPipeSuccess(PipeDto response) {
    when(() => getPipe(any())).thenAnswer((_) async => response);
  }

  /// Setup getPipe to throw exception
  void setupGetPipeError(Exception error) {
    when(() => getPipe(any())).thenThrow(error);
  }

  /// Setup successful getAllPipes response
  void setupGetAllPipesSuccess(List<PipeDto> response) {
    when(() => getAllPipes()).thenAnswer((_) async => response);
  }

  /// Setup successful chatWithAI response
  void setupChatWithAISuccess(ChatResponse response) {
    when(() => chatWithAI(any(), conversationId: any(named: 'conversationId')))
        .thenAnswer((_) async => response);
  }

  /// Setup successful getDashboardStats response
  void setupGetDashboardStatsSuccess(Map<String, dynamic> response) {
    when(() => getDashboardStats()).thenAnswer((_) async => response);
  }
}
