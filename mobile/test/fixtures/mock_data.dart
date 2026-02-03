import '../../lib/data/models/defect_dto.dart';
import '../../lib/data/models/pipe_dto.dart';

/// Test data fixtures for unit tests
class MockData {
  /// Create a sample PipeDto for testing
  static PipeDto createPipeDto({
    String? id,
    String? qrCode,
    String? manufacturer,
    String? material,
    int? diameterMm,
    double? riskScore,
  }) {
    return PipeDto(
      id: id ?? 'pipe-123',
      qrCode: qrCode ?? 'PL-COMPANY-pipe-123',
      manufacturer: manufacturer ?? 'Test Manufacturer',
      material: material ?? 'Steel',
      diameterMm: diameterMm ?? 100,
      riskScore: riskScore ?? 0.5,
      predictedLifetimeYears: 20,
      currentStatus: 'active',
      wallThicknessMm: 5.0,
      lengthMeters: 10.0,
      location: {'lat': 43.238949, 'lon': 76.889709},
    );
  }

  /// Create a sample DefectDto for testing
  static DefectDto createDefectDto({
    String? id,
    String? pipeId,
    String? defectType,
    int? severity,
  }) {
    return DefectDto(
      id: id ?? 'defect-123',
      pipeId: pipeId ?? 'pipe-123',
      inspectionId: 'inspection-123',
      defectType: defectType ?? 'corrosion',
      severity: severity ?? 3,
      gpsCoordinates: {'lat': 43.238949, 'lon': 76.889709},
      locationOnPipe: '12 часов',
      lengthMm: 100.0,
      depthMm: 2.0,
      photos: ['/path/to/photo1.jpg'],
      aiDetected: false,
      aiConfidence: 0.85,
    );
  }

  /// Create a list of sample pipes
  static List<PipeDto> createPipeList({int count = 3}) {
    return List.generate(
      count,
      (index) => createPipeDto(
        id: 'pipe-$index',
        qrCode: 'PL-COMPANY-pipe-$index',
      ),
    );
  }

  /// Create a list of sample defects
  static List<DefectDto> createDefectList({int count = 3}) {
    return List.generate(
      count,
      (index) => createDefectDto(
        id: 'defect-$index',
        pipeId: 'pipe-${index % 3}',
      ),
    );
  }

  /// Sample access token
  static const String sampleAccessToken = 'test-access-token-12345';

  /// Sample refresh token
  static const String sampleRefreshToken = 'test-refresh-token-12345';

  /// Sample user email
  static const String sampleUserEmail = 'test@example.com';

  /// Sample API response for login
  static Map<String, dynamic> loginResponse = {
    'access_token': sampleAccessToken,
    'refresh_token': sampleRefreshToken,
    'token_type': 'Bearer',
    'expires_in': 3600,
  };

  /// Sample dashboard stats
  static Map<String, dynamic> dashboardStats = {
    'total_pipes': 100,
    'total_defects': 25,
    'high_risk_pipes': 10,
    'pending_sync': 5,
  };

  /// Sample chat response
  static Map<String, dynamic> chatResponse = {
    'response': 'This is a test AI response',
    'conversation_id': 'conv-123',
    'timestamp': '2024-01-01T00:00:00Z',
  };
}
