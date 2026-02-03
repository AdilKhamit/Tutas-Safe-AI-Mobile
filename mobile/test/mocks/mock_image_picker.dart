import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';

/// Mock ImagePicker for testing
class MockImagePicker extends Mock implements ImagePicker {
  MockImagePicker() {
    // Setup default behaviors
  }

  /// Setup successful image pick from gallery
  void setupPickImageFromGallery(XFile? file) {
    when(() => pickImage(
      source: any(named: 'source'),
      imageQuality: any(named: 'imageQuality'),
      maxWidth: any(named: 'maxWidth'),
      maxHeight: any(named: 'maxHeight'),
      preferredCameraDevice: any(named: 'preferredCameraDevice'),
    )).thenAnswer((_) async => file);
  }

  /// Setup image pick failure
  void setupPickImageError(Exception error) {
    when(() => pickImage(
      source: any(named: 'source'),
      imageQuality: any(named: 'imageQuality'),
      maxWidth: any(named: 'maxWidth'),
      maxHeight: any(named: 'maxHeight'),
      preferredCameraDevice: any(named: 'preferredCameraDevice'),
    )).thenThrow(error);
  }

  /// Setup successful image pick from camera
  void setupPickImageFromCamera(XFile? file) {
    when(() => pickImage(
      source: ImageSource.camera,
      imageQuality: any(named: 'imageQuality'),
      maxWidth: any(named: 'maxWidth'),
      maxHeight: any(named: 'maxHeight'),
      preferredCameraDevice: any(named: 'preferredCameraDevice'),
    )).thenAnswer((_) async => file);
  }

  // Note: pickMultipleImages might not be available in all versions of image_picker
  // Uncomment if your version supports it:
  // void setupPickMultipleImages(List<XFile> files) {
  //   when(() => pickMultipleImages(
  //     imageQuality: any(named: 'imageQuality'),
  //     maxWidth: any(named: 'maxWidth'),
  //     maxHeight: any(named: 'maxHeight'),
  //   )).thenAnswer((_) async => files);
  // }
}

/// Mock XFile for testing
class MockXFile extends Mock implements XFile {
  final String _path;
  final String _name;
  final int? _length;
  final String? _mimeType;

  MockXFile({
    required String path,
    String name = 'test_image.jpg',
    int? length,
    String? mimeType = 'image/jpeg',
  })  : _path = path,
        _name = name,
        _length = length,
        _mimeType = mimeType;

  @override
  String get path => _path;

  @override
  String get name => _name;

  @override
  Future<int> length() async => _length ?? 1024;

  @override
  String? get mimeType => _mimeType;
}
