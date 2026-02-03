import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:mocktail/mocktail.dart';
import '../../lib/core/services/connectivity_service.dart';

/// Mock ConnectivityService for testing
class MockConnectivityService extends Mock implements ConnectivityService {
  MockConnectivityService() {
    // Setup default behaviors
    when(() => getCurrentStatus()).thenAnswer((_) async => ConnectivityResult.wifi);
    when(() => isOnline()).thenAnswer((_) async => true);
    when(() => hasWifi()).thenAnswer((_) async => true);
    when(() => hasMobileData()).thenAnswer((_) async => false);
    when(() => onConnectivityChanged).thenAnswer((_) => const Stream.empty());
  }

  /// Setup online state
  void setupOnline() {
    when(() => getCurrentStatus()).thenAnswer((_) async => ConnectivityResult.wifi);
    when(() => isOnline()).thenAnswer((_) async => true);
    when(() => hasWifi()).thenAnswer((_) async => true);
    when(() => hasMobileData()).thenAnswer((_) async => false);
  }

  /// Setup offline state
  void setupOffline() {
    when(() => getCurrentStatus()).thenAnswer((_) async => ConnectivityResult.none);
    when(() => isOnline()).thenAnswer((_) async => false);
    when(() => hasWifi()).thenAnswer((_) async => false);
    when(() => hasMobileData()).thenAnswer((_) async => false);
  }

  /// Setup mobile data state
  void setupMobileData() {
    when(() => getCurrentStatus()).thenAnswer((_) async => ConnectivityResult.mobile);
    when(() => isOnline()).thenAnswer((_) async => true);
    when(() => hasWifi()).thenAnswer((_) async => false);
    when(() => hasMobileData()).thenAnswer((_) async => true);
  }

  /// Setup connectivity stream
  void setupConnectivityStream(Stream<ConnectivityResult> stream) {
    when(() => onConnectivityChanged).thenAnswer((_) => stream);
  }
}
