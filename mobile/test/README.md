# Тестирование мобильного приложения

## 📁 Структура тестов

```
test/
├── helpers/
│   └── test_helpers.dart          # Вспомогательные функции для тестов
├── fixtures/
│   └── mock_data.dart              # Тестовые данные (fixtures)
├── mocks/
│   ├── mocks.dart                  # Экспорт всех моков
│   ├── mock_api_client.dart        # Мок API клиента
│   ├── mock_auth_service.dart      # Мок сервиса аутентификации
│   ├── mock_database.dart          # Мок базы данных
│   ├── mock_connectivity_service.dart
│   ├── mock_image_upload_service.dart
│   ├── mock_image_compression_service.dart
│   ├── mock_secure_storage.dart
│   ├── mock_repositories.dart
│   ├── mock_backup_service.dart
│   ├── mock_encryption_service.dart
│   ├── mock_shared_preferences.dart
│   ├── mock_image_picker.dart
│   ├── mock_mobile_scanner.dart
│   └── mock_local_auth.dart
└── unit/
    ├── services/
    │   ├── auth_service_test.dart
    │   ├── api_client_test.dart
    │   └── connectivity_service_test.dart
    └── repositories/
        └── defect_repository_test.dart
```

## 🚀 Быстрый старт

### 1. Установите зависимости

```bash
cd mobile
flutter pub get
```

### 2. Запустите тесты

```bash
# Все тесты
flutter test

# Конкретный тест
flutter test test/unit/services/auth_service_test.dart

# С покрытием кода
flutter test --coverage
```

## 📝 Использование моков

### Пример использования моков в тестах

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import '../../mocks/mocks.dart';
import '../../fixtures/mock_data.dart';
import '../../helpers/test_helpers.dart';

void main() {
  late MockApiClient mockApiClient;
  late MockAuthService mockAuthService;

  setUpAll(() {
    TestHelpers.setupTestEnvironment();
  });

  setUp(() {
    mockApiClient = MockApiClient();
    mockAuthService = MockAuthService();
  });

  test('example test', () {
    // Arrange
    final pipe = MockData.createPipeDto();
    mockApiClient.setupGetPipeSuccess(pipe);

    // Act
    final result = await mockApiClient.getPipe('test-id');

    // Assert
    expect(result, isA<PipeDto>());
  });
}
```

## 🎯 Доступные моки

### Критичные сервисы
- ✅ `MockApiClient` - мок API клиента
- ✅ `MockAuthService` - мок сервиса аутентификации
- ✅ `MockAppDatabase` - мок базы данных
- ✅ `MockConnectivityService` - мок сервиса подключения

### Важные сервисы
- ✅ `MockImageUploadService` - мок загрузки изображений
- ✅ `MockImageCompressionService` - мок сжатия изображений
- ✅ `MockFlutterSecureStorage` - мок безопасного хранилища
- ✅ `MockDefectRepository` - мок репозитория дефектов
- ✅ `MockPipeRepository` - мок репозитория труб
- ✅ `MockBackupService` - мок резервного копирования
- ✅ `MockEncryptionService` - мок шифрования
- ✅ `MockSharedPreferences` - мок локальных настроек

### UI сервисы
- ✅ `MockImagePicker` - мок выбора изображений
- ✅ `MockMobileScannerController` - мок сканера QR кодов
- ✅ `MockLocalAuthentication` - мок биометрической аутентификации

## 📊 Тестовые данные (Fixtures)

Используйте `MockData` для создания тестовых данных:

```dart
// Создать тестовую трубу
final pipe = MockData.createPipeDto(
  id: 'pipe-123',
  qrCode: 'PL-COMPANY-pipe-123',
);

// Создать тестовый дефект
final defect = MockData.createDefectDto(
  id: 'defect-123',
  pipeId: 'pipe-123',
);

// Создать список труб
final pipes = MockData.createPipeList(count: 5);
```

## 🔧 Настройка моков

### ApiClient

```dart
final mockApiClient = MockApiClient();

// Успешный ответ
mockApiClient.setupGetPipeSuccess(pipe);

// Ошибка
mockApiClient.setupGetPipeError(ApiException(
  statusCode: 404,
  message: 'Not found',
));
```

### AuthService

```dart
final mockAuthService = MockAuthService();

// Успешный вход
mockAuthService.setupLoginSuccess(
  accessToken: 'token-123',
  refreshToken: 'refresh-123',
);

// Неудачный вход
mockAuthService.setupLoginFailure('Invalid credentials');
```

### ConnectivityService

```dart
final mockConnectivity = MockConnectivityService();

// Онлайн
mockConnectivity.setupOnline();

// Офлайн
mockConnectivity.setupOffline();

// Мобильный интернет
mockConnectivity.setupMobileData();
```

## 📈 Покрытие кода

Для просмотра покрытия кода тестами:

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## ⚠️ Важные замечания

1. **Всегда вызывайте `TestHelpers.setupTestEnvironment()` в `setUpAll()`**
2. **Используйте `setUp()` для инициализации моков перед каждым тестом**
3. **Очищайте состояние моков в `tearDown()` если необходимо**
4. **Используйте `MockData` для создания тестовых данных**

## 🔗 Полезные ссылки

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Mocktail Package](https://pub.dev/packages/mocktail)
- [Testing Best Practices](https://docs.flutter.dev/testing/best-practices)
