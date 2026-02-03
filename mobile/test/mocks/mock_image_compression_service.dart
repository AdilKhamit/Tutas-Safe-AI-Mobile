import 'package:mocktail/mocktail.dart';
import '../../lib/core/services/image_compression_service.dart';

/// Mock ImageCompressionService for testing
class MockImageCompressionService extends Mock implements ImageCompressionService {
  MockImageCompressionService() {
    // Setup default behavior - return original path
    when(() => compressImage(
      any(),
      quality: any(named: 'quality'),
      maxWidth: any(named: 'maxWidth'),
      maxHeight: any(named: 'maxHeight'),
      minWidth: any(named: 'minWidth'),
      minHeight: any(named: 'minHeight'),
    )).thenAnswer((invocation) async => invocation.positionalArguments[0] as String);
  }

  /// Setup compression to return compressed path
  void setupCompressImageSuccess(String compressedPath) {
    when(() => compressImage(
      any(),
      quality: any(named: 'quality'),
      maxWidth: any(named: 'maxWidth'),
      maxHeight: any(named: 'maxHeight'),
      minWidth: any(named: 'minWidth'),
      minHeight: any(named: 'minHeight'),
    )).thenAnswer((_) async => compressedPath);
  }

  /// Setup compression to return original path (no compression needed)
  void setupCompressImageNoCompression(String originalPath) {
    when(() => compressImage(
      any(),
      quality: any(named: 'quality'),
      maxWidth: any(named: 'maxWidth'),
      maxHeight: any(named: 'maxHeight'),
      minWidth: any(named: 'minWidth'),
      minHeight: any(named: 'minHeight'),
    )).thenAnswer((_) async => originalPath);
  }

  /// Setup compression failure
  void setupCompressImageError(Exception error) {
    when(() => compressImage(
      any(),
      quality: any(named: 'quality'),
      maxWidth: any(named: 'maxWidth'),
      maxHeight: any(named: 'maxHeight'),
      minWidth: any(named: 'minWidth'),
      minHeight: any(named: 'minHeight'),
    )).thenThrow(error);
  }

  /// Setup compress multiple images
  void setupCompressImagesSuccess(List<String> compressedPaths) {
    when(() => compressImages(any())).thenAnswer((_) async => compressedPaths);
  }
}
