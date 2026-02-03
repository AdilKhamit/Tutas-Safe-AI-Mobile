import 'package:local_auth/local_auth.dart';
import 'package:mocktail/mocktail.dart';

/// Mock LocalAuthentication for testing
class MockLocalAuthentication extends Mock implements LocalAuthentication {
  MockLocalAuthentication() {
    // Setup default behaviors
    when(() => isDeviceSupported()).thenAnswer((_) async => true);
    when(() => getAvailableBiometrics()).thenAnswer((_) async => []);
    when(() => canCheckBiometrics).thenAnswer((_) async => true);
    when(() => stopAuthentication()).thenAnswer((_) async => true);
  }

  /// Setup successful authentication
  void setupAuthenticateSuccess() {
    when(() => authenticate(
      localizedReason: any(named: 'localizedReason'),
      options: any(named: 'options'),
    )).thenAnswer((_) async => true);
  }

  /// Setup authentication failure
  void setupAuthenticateFailure() {
    when(() => authenticate(
      localizedReason: any(named: 'localizedReason'),
      options: any(named: 'options'),
    )).thenAnswer((_) async => false);
  }

  /// Setup authentication exception
  void setupAuthenticateException(Exception error) {
    when(() => authenticate(
      localizedReason: any(named: 'localizedReason'),
      options: any(named: 'options'),
    )).thenThrow(error);
  }

  /// Setup device not supported
  void setupDeviceNotSupported() {
    when(() => isDeviceSupported()).thenAnswer((_) async => false);
    when(() => canCheckBiometrics).thenAnswer((_) async => false);
  }

  /// Setup available biometrics
  void setupAvailableBiometrics(List<BiometricType> biometrics) {
    when(() => getAvailableBiometrics()).thenAnswer((_) async => biometrics);
  }

  /// Setup no biometrics available
  void setupNoBiometrics() {
    when(() => getAvailableBiometrics()).thenAnswer((_) async => []);
    when(() => canCheckBiometrics).thenAnswer((_) async => false);
  }

  /// Setup Face ID available
  void setupFaceIdAvailable() {
    when(() => getAvailableBiometrics()).thenAnswer((_) async => [BiometricType.face]);
    when(() => canCheckBiometrics).thenAnswer((_) async => true);
  }

  /// Setup Fingerprint available
  void setupFingerprintAvailable() {
    when(() => getAvailableBiometrics()).thenAnswer((_) async => [BiometricType.fingerprint]);
    when(() => canCheckBiometrics).thenAnswer((_) async => true);
  }
}
