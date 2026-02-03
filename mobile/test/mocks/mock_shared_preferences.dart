import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Mock SharedPreferences for testing
class MockSharedPreferences extends Mock implements SharedPreferences {
  final Map<String, dynamic> _storage = {};

  MockSharedPreferences() {
    // Setup default behaviors for common methods
    when(() => getString(any())).thenAnswer((invocation) {
      final key = invocation.positionalArguments[0] as String;
      return _storage[key] as String?;
    });

    when(() => setString(any(), any())).thenAnswer((invocation) async {
      final key = invocation.positionalArguments[0] as String;
      final value = invocation.positionalArguments[1] as String;
      _storage[key] = value;
      return true;
    });

    when(() => getBool(any())).thenAnswer((invocation) {
      final key = invocation.positionalArguments[0] as String;
      return _storage[key] as bool?;
    });

    when(() => setBool(any(), any())).thenAnswer((invocation) async {
      final key = invocation.positionalArguments[0] as String;
      final value = invocation.positionalArguments[1] as bool;
      _storage[key] = value;
      return true;
    });

    when(() => getInt(any())).thenAnswer((invocation) {
      final key = invocation.positionalArguments[0] as String;
      return _storage[key] as int?;
    });

    when(() => setInt(any(), any())).thenAnswer((invocation) async {
      final key = invocation.positionalArguments[0] as String;
      final value = invocation.positionalArguments[1] as int;
      _storage[key] = value;
      return true;
    });

    when(() => getDouble(any())).thenAnswer((invocation) {
      final key = invocation.positionalArguments[0] as String;
      return _storage[key] as double?;
    });

    when(() => setDouble(any(), any())).thenAnswer((invocation) async {
      final key = invocation.positionalArguments[0] as String;
      final value = invocation.positionalArguments[1] as double;
      _storage[key] = value;
      return true;
    });

    when(() => getStringList(any())).thenAnswer((invocation) {
      final key = invocation.positionalArguments[0] as String;
      return _storage[key] as List<String>?;
    });

    when(() => setStringList(any(), any())).thenAnswer((invocation) async {
      final key = invocation.positionalArguments[0] as String;
      final value = invocation.positionalArguments[1] as List<String>;
      _storage[key] = value;
      return true;
    });

    when(() => remove(any())).thenAnswer((invocation) async {
      final key = invocation.positionalArguments[0] as String;
      _storage.remove(key);
      return true;
    });

    when(() => clear()).thenAnswer((_) async {
      _storage.clear();
      return true;
    });

    when(() => containsKey(any())).thenAnswer((invocation) {
      final key = invocation.positionalArguments[0] as String;
      return _storage.containsKey(key);
    });

    when(() => getKeys()).thenAnswer((_) => _storage.keys.toSet());

    when(() => reload()).thenAnswer((_) async => this);
  }

  /// Clear all stored values
  void clearStorage() {
    _storage.clear();
  }

  /// Set a value directly (for testing)
  void setValue(String key, dynamic value) {
    _storage[key] = value;
  }

  /// Get a value directly (for testing)
  dynamic getValue(String key) {
    return _storage[key];
  }
}

/// Helper to create MockSharedPreferences instance
class MockSharedPreferencesHelper {
  static MockSharedPreferences create() {
    return MockSharedPreferences();
  }
}
