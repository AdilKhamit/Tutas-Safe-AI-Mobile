import 'package:mocktail/mocktail.dart';
import '../../lib/core/services/image_upload_service.dart';

/// Mock ImageUploadService for testing
class MockImageUploadService extends Mock implements ImageUploadService {
  MockImageUploadService() {
    // Setup default behaviors
  }

  /// Setup successful photo upload
  void setupUploadPhotoSuccess(String url) {
    when(() => uploadPhoto(
      any(),
      onProgress: any(named: 'onProgress'),
      compress: any(named: 'compress'),
    )).thenAnswer((_) async => url);
  }

  /// Setup photo upload failure
  void setupUploadPhotoError(Exception error) {
    when(() => uploadPhoto(
      any(),
      onProgress: any(named: 'onProgress'),
      compress: any(named: 'compress'),
    )).thenThrow(error);
  }

  /// Setup successful multiple photos upload
  void setupUploadPhotosSuccess(List<String> urls) {
    when(() => uploadPhotos(
      any(),
      onOverallProgress: any(named: 'onOverallProgress'),
      compress: any(named: 'compress'),
    )).thenAnswer((_) async => urls);
  }

  /// Setup multiple photos upload failure
  void setupUploadPhotosError(Exception error) {
    when(() => uploadPhotos(
      any(),
      onOverallProgress: any(named: 'onOverallProgress'),
      compress: any(named: 'compress'),
    )).thenThrow(error);
  }
}
