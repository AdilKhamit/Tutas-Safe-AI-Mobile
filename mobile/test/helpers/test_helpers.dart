import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import '../../lib/data/models/defect_dto.dart';
import '../../lib/data/models/pipe_dto.dart';
import '../../lib/data/local/database.dart';

/// Helper class for common test utilities
class TestHelpers {
  /// Register fallback values for mocktail
  static void registerFallbacks() {
    // Register fallback values for common types
    registerFallbackValue(Uri());
    registerFallbackValue(const Duration());
    
    // Register fallback values for DTOs
    registerFallbackValue(DefectDto(
      id: 'test-id',
      pipeId: 'test-pipe-id',
      defectType: 'corrosion',
      severity: 1,
      photos: [],
    ));
    
    registerFallbackValue(PipeDto(
      id: 'test-id',
      qrCode: 'test-qr',
      currentStatus: 'active',
    ));
    
    // Register fallback for LocalDefect
    registerFallbackValue(LocalDefect(
      id: 'test-id',
      pipeId: 'test-pipe-id',
      inspectionId: 'test-inspection',
      defectType: 'corrosion',
      severity: 1,
      gpsCoordinates: '{}',
      locationOnPipe: 'test',
      lengthMm: 0.0,
      depthMm: 0.0,
      photos: '[]',
      aiDetected: false,
      aiConfidence: 0.0,
      syncStatus: SyncStatus.pending,
      serverVersionJson: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));
  }

  /// Setup test environment
  static void setupTestEnvironment() {
    registerFallbacks();
  }
}
