import 'package:mocktail/mocktail.dart';
import '../../lib/core/services/auth_service.dart';

/// Mock AuthService for testing
class MockAuthService extends Mock implements AuthService {
  MockAuthService() {
    // Setup default behaviors
    when(() => isAuthenticated()).thenAnswer((_) async => false);
    when(() => isTokenValid()).thenAnswer((_) async => false);
    when(() => getAccessToken()).thenAnswer((_) async => null);
    when(() => getRefreshToken()).thenAnswer((_) async => null);
    when(() => getUserEmail()).thenAnswer((_) async => null);
  }

  /// Setup successful login
  void setupLoginSuccess({
    String? accessToken,
    String? refreshToken,
  }) {
    when(() => login(any(), any())).thenAnswer(
      (_) async => AuthResult.success(
        accessToken: accessToken ?? 'test-access-token',
        refreshToken: refreshToken ?? 'test-refresh-token',
      ),
    );
  }

  /// Setup login failure
  void setupLoginFailure(String message) {
    when(() => login(any(), any())).thenAnswer(
      (_) async => AuthResult.failure(message: message),
    );
  }

  /// Setup successful logout
  void setupLogoutSuccess() {
    when(() => logout()).thenAnswer((_) async => {});
  }

  /// Setup successful token refresh
  void setupRefreshTokenSuccess({
    String? accessToken,
    String? refreshToken,
  }) {
    when(() => refreshAccessToken()).thenAnswer(
      (_) async => AuthResult.success(
        accessToken: accessToken ?? 'new-access-token',
        refreshToken: refreshToken ?? 'new-refresh-token',
      ),
    );
  }

  /// Setup token refresh failure
  void setupRefreshTokenFailure(String message) {
    when(() => refreshAccessToken()).thenAnswer(
      (_) async => AuthResult.failure(message: message),
    );
  }

  /// Setup authenticated state
  void setupAuthenticated({
    String? accessToken,
    String? refreshToken,
    String? email,
    bool isValid = true,
  }) {
    when(() => isAuthenticated()).thenAnswer((_) async => true);
    when(() => isTokenValid()).thenAnswer((_) async => isValid);
    when(() => getAccessToken()).thenAnswer((_) async => accessToken ?? 'test-token');
    when(() => getRefreshToken()).thenAnswer((_) async => refreshToken);
    when(() => getUserEmail()).thenAnswer((_) async => email ?? 'test@example.com');
  }
}
