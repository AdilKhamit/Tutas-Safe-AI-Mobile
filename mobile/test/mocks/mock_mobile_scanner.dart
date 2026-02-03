import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:mocktail/mocktail.dart';

/// Mock MobileScannerController for testing
class MockMobileScannerController extends Mock implements MobileScannerController {
  MockMobileScannerController() {
    // Setup default behaviors
    when(() => start()).thenAnswer((_) async => {});
    when(() => stop()).thenAnswer((_) async => {});
    when(() => toggleTorch()).thenAnswer((_) async => {});
    when(() => switchCamera()).thenAnswer((_) async => {});
    when(() => dispose()).thenAnswer((_) async => {});
  }

  /// Setup successful start
  void setupStartSuccess() {
    when(() => start()).thenAnswer((_) async => {});
  }

  /// Setup start failure
  void setupStartError(Exception error) {
    when(() => start()).thenThrow(error);
  }

  /// Setup torch state
  void setupTorchState(bool isTorchOn) {
    // Note: MobileScannerController doesn't expose torch state directly
    // This is a simplified mock
  }

  /// Setup camera state
  void setupCameraState(CameraFacing facing) {
    // Note: MobileScannerController doesn't expose camera state directly
    // This is a simplified mock
  }
}

/// Helper class to create mock QR code scan results
class MockQrCodeScanResult {
  /// Create a mock BarcodeCapture with QR code
  static BarcodeCapture createBarcodeCapture({
    required String rawValue,
    String? displayValue,
    BarcodeFormat format = BarcodeFormat.qrCode,
  }) {
    final barcode = Barcode(
      rawValue: rawValue,
      displayValue: displayValue ?? rawValue,
      format: format,
    );

    return BarcodeCapture(
      barcodes: [barcode],
      image: null,
    );
  }

  /// Create a mock BarcodeCapture with multiple QR codes
  static BarcodeCapture createMultipleBarcodes(List<String> rawValues) {
    final barcodes = rawValues.map((value) => Barcode(
      rawValue: value,
      displayValue: value,
      format: BarcodeFormat.qrCode,
    )).toList();

    return BarcodeCapture(
      barcodes: barcodes,
      image: null,
    );
  }
}
