import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mocktail/mocktail.dart';

/// Mock FlutterSecureStorage for testing
class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {
  final Map<String, String> _storage = {};

  MockFlutterSecureStorage() {
    // Setup default behaviors
    when(() => read(key: any(named: 'key'), iOptions: any(named: 'iOptions')))
        .thenAnswer((invocation) async {
      final key = invocation.namedArguments[#key] as String;
      return _storage[key];
    });

    when(() => write(key: any(named: 'key'), value: any(named: 'value'), iOptions: any(named: 'iOptions')))
        .thenAnswer((invocation) async {
      final key = invocation.namedArguments[#key] as String;
      final value = invocation.namedArguments[#value] as String;
      _storage[key] = value;
    });

    when(() => delete(key: any(named: 'key'), iOptions: any(named: 'iOptions')))
        .thenAnswer((invocation) async {
      final key = invocation.namedArguments[#key] as String;
      _storage.remove(key);
    });

    when(() => deleteAll(iOptions: any(named: 'iOptions')))
        .thenAnswer((_) async {
      _storage.clear();
    });

    when(() => readAll(iOptions: any(named: 'iOptions')))
        .thenAnswer((_) async => _storage);
  }

  /// Clear all stored values
  void clear() {
    _storage.clear();
  }

  /// Set a value directly (for testing)
  void setValue(String key, String value) {
    _storage[key] = value;
  }

  /// Get a value directly (for testing)
  String? getValue(String key) {
    return _storage[key];
  }
}
