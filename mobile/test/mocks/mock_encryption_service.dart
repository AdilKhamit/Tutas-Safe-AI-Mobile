import 'dart:io';
import 'dart:typed_data';
import 'package:mocktail/mocktail.dart';
import '../../lib/core/services/encryption_service.dart';

/// Mock EncryptionService for testing
/// Note: EncryptionService uses static methods, so we need to mock differently
class MockEncryptionService {
  static bool _isAvailable = true;
  static bool _shouldFail = false;

  /// Reset mock state
  static void reset() {
    _isAvailable = true;
    _shouldFail = false;
  }

  /// Setup encryption to be available
  static void setupAvailable() {
    _isAvailable = true;
    _shouldFail = false;
  }

  /// Setup encryption to be unavailable
  static void setupUnavailable() {
    _isAvailable = false;
  }

  /// Setup encryption to fail
  static void setupFailure() {
    _shouldFail = true;
  }

  /// Check if encryption is available (for testing)
  static bool get isAvailable => _isAvailable;

  /// Check if encryption should fail (for testing)
  static bool get shouldFail => _shouldFail;
}

/// Helper class to wrap EncryptionService for testing
class EncryptionServiceTestHelper {
  /// Mock encrypt file - returns original bytes if unavailable
  static Future<Uint8List> mockEncryptFile(File file) async {
    if (!MockEncryptionService.isAvailable || MockEncryptionService.shouldFail) {
      return await file.readAsBytes();
    }
    // In real tests, you might want to use actual encryption or return modified bytes
    return await file.readAsBytes();
  }

  /// Mock decrypt file - returns original bytes if unavailable
  static Future<Uint8List> mockDecryptFile(File encryptedFile) async {
    if (!MockEncryptionService.isAvailable || MockEncryptionService.shouldFail) {
      return await encryptedFile.readAsBytes();
    }
    return await encryptedFile.readAsBytes();
  }

  /// Mock encrypt string
  static String? mockEncryptString(String data) {
    if (!MockEncryptionService.isAvailable || MockEncryptionService.shouldFail) {
      return null;
    }
    // Return base64 encoded string for testing
    return data; // Simplified for testing
  }

  /// Mock decrypt string
  static String? mockDecryptString(String encryptedBase64) {
    if (!MockEncryptionService.isAvailable || MockEncryptionService.shouldFail) {
      return null;
    }
    return encryptedBase64; // Simplified for testing
  }
}
