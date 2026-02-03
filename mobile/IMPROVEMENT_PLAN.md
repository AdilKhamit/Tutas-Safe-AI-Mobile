# План улучшений мобильного приложения

> **Дата создания:** 2025-01-19  
> **Версия:** 1.0.0+1  
> **Статус:** План (не реализовано)

---

## 📋 Содержание

1. [Тестирование](#1-тестирование)
2. [Мониторинг](#2-мониторинг)
3. [UX/UI улучшения](#3-uxui-улучшения)

---

## 1. Тестирование

### 📊 Текущее состояние

**Оценка:** ⭐⭐⭐ (3/5)

**Что есть:**
- ✅ Unit тесты для критичных сервисов (4 файла)
- ✅ Моки для всех основных сервисов (15+ моков)
- ✅ Test helpers и fixtures
- ✅ Базовая структура тестов

**Что отсутствует:**
- ❌ Widget тесты (только placeholder)
- ❌ Integration тесты
- ❌ Низкое покрытие (~30-40%)
- ❌ Много placeholder тестов (не реализованы полностью)

### 🎯 Цель

Увеличить покрытие тестами до **70%+** и добавить widget/integration тесты.

### 📝 План действий

#### Этап 1: Завершение Unit тестов (Приоритет: 🔴 Высокий)

**Время:** 2-3 недели  
**Покрытие:** +20-30%

##### 1.1. Завершить тесты AuthService

**Файл:** `test/unit/services/auth_service_test.dart`

**Текущие проблемы:**
- Много placeholder тестов (строки 30-59, 100-118)
- Не тестируется реальная логика login/logout
- Нет тестов для token validation

**Что нужно сделать:**

```dart
// Добавить реальные тесты для:
1. login() - успешный вход
   - Мокировать Dio response
   - Проверить сохранение токенов
   - Проверить возврат AuthResult.success

2. login() - ошибки
   - 401 Unauthorized
   - 404 Not Found
   - Network errors
   - Проверить возврат AuthResult.failure

3. logout() - полный тест
   - Проверить вызов API logout
   - Проверить очистку storage
   - Проверить обработку ошибок API

4. isTokenValid() - валидация токенов
   - Валидный токен
   - Истекший токен
   - Невалидный формат

5. refreshAccessToken() - обновление токена
   - Успешное обновление
   - Ошибка обновления
   - Логирование при ошибке
```

**Зависимости:**
- `http_mock_adapter` или `dio_mock_adapter` для мокирования Dio

**🌐 Решения из интернета (2026):**
- **Mockito/Mockk** – стандартные библиотеки для мокирования зависимостей в Flutter/Dart. Используются для изолированного тестирования функций без реальных API вызовов[1][5]
- **http_mock_adapter** – специализированный пакет для мокирования Dio HTTP запросов, позволяет легко создавать mock responses для тестирования[3]
- **JUnit 5 + Mockito** – стандарт для Android unit-тестирования, позволяет достичь 60-70% покрытия базовой логики[5]
- **Рекомендация:** Использовать Page Object Model для структурирования тестов[5]

**Оценка времени:** 1-2 дня

##### 1.2. Завершить тесты DefectRepository

**Файл:** `test/unit/repositories/defect_repository_test.dart`

**Текущие проблемы:**
- Упрощенные тесты (строки 34-46, 50-64)
- Не тестируется батчинг синхронизации
- Нет тестов для конфликтов

**🌐 Решения из интернета (2026):**
- **Integration Testing Framework** – тестирование взаимодействия между компонентами (API, БД, UI)[4]
- **MockWebServer (Retrofit)** – для имитации API-ответов при тестировании синхронизации[1]
- **Drift Test Database** – использование in-memory базы данных для тестирования репозиториев без реальной БД[3]
- **BDD подход (Given-When-Then)** – структурирование тестов для лучшей читаемости[1]

**Что нужно сделать:**

```dart
// Добавить полные тесты для:
1. saveDefect() - сохранение дефекта
   - Проверить создание UUID если нет id
   - Проверить сохранение в БД
   - Проверить syncStatus = Pending

2. syncPendingDefects() - синхронизация
   - Тест батчинга (10 дефектов за раз)
   - Тест успешной синхронизации
   - Тест обработки ошибок
   - Тест смешанных результатов (synced + failed + conflicts)

3. syncPendingDefects() - конфликты
   - Тест ConflictException
   - Проверить сохранение serverVersionJson
   - Проверить syncStatus = Conflict

4. acceptServerVersion() - разрешение конфликтов
   - Проверить замену локальной версии
   - Проверить обновление syncStatus = Synced
   - Проверить очистку serverVersionJson

5. keepLocalVersion() - сохранение локальной версии
   - Проверить syncStatus = Pending
   - Проверить очистку serverVersionJson

6. _syncSingleDefect() - загрузка фото
   - Тест загрузки фото перед синхронизацией
   - Тест обработки ошибок загрузки фото
   - Тест замены локальных путей на URLs
```

**Оценка времени:** 2-3 дня

##### 1.3. Добавить тесты для PipeRepository

**Файл:** `test/unit/repositories/pipe_repository_test.dart` (создать новый)

**Что тестировать:**

```dart
1. getAllPipes() - получение всех труб
   - Тест пустого списка
   - Тест списка с данными
   - Тест обработки ошибок БД

2. getPipeById() - получение трубы по ID
   - Успешное получение
   - Труба не найдена
   - Ошибка БД

3. savePipe() - сохранение трубы
   - Проверить сохранение в БД
   - Проверить обновление updatedAt

4. syncPipes() - синхронизация с сервером
   - Тест успешной синхронизации
   - Тест обработки ошибок
   - Тест обновления существующих труб

5. getPipesPaginated() - пагинация
   - Тест первой страницы
   - Тест следующих страниц
   - Тест пустого результата
```

**Оценка времени:** 1-2 дня

##### 1.4. Добавить тесты для остальных сервисов

**Новые файлы:**

1. `test/unit/services/image_upload_service_test.dart`
   - Тест загрузки одного фото
   - Тест загрузки нескольких фото
   - Тест обработки ошибок
   - Тест progress tracking

2. `test/unit/services/image_compression_service_test.dart`
   - Тест сжатия изображения
   - Тест параметров сжатия
   - Тест обработки ошибок

3. `test/unit/services/encryption_service_test.dart`
   - Тест шифрования файла
   - Тест расшифровки файла
   - Тест шифрования строки
   - Тест инициализации

4. `test/unit/services/backup_service_test.dart`
   - Тест экспорта данных
   - Тест импорта данных
   - Тест валидации backup файла

5. `test/unit/services/data_cleanup_service_test.dart`
   - Тест очистки старых дефектов
   - Тест очистки старых труб
   - Тест получения статистики

**Оценка времени:** 3-4 дня

##### 1.5. Улучшить тесты ApiClient

**Файл:** `test/unit/services/api_client_test.dart`

**Что добавить:**

```dart
1. Retry логика
   - Тест exponential backoff
   - Тест максимального количества попыток
   - Тест jitter

2. Обработка ошибок
   - Network errors
   - Timeout errors
   - 4xx/5xx errors
   - ConflictException (409)

3. Token injection
   - Тест добавления токена в headers
   - Тест использования API key если нет токена

4. Connectivity service integration
   - Тест проверки онлайн статуса
   - Тест обработки offline режима
```

**Оценка времени:** 1-2 дня

**Итого для Этапа 1:** 8-13 дней

---

#### Этап 2: Widget тесты (Приоритет: 🔴 Высокий)

**Время:** 2-3 недели  
**Покрытие:** +15-20%

**🌐 Решения из интернета (2026):**
- **Flutter Test Framework** – встроенный инструмент для тестирования виджетов. Использует `WidgetTester` для взаимодействия с UI компонентами[1][5]
- **Espresso (Android)** – основной инструмент Google для UI-тестирования Android. Автоматизирует проверку интерфейса[1][3]
- **XCUITest (iOS)** – встроенный фреймворк Apple для UI-тестов. Нативный инструмент для iOS приложений[1][3]
- **Compose Testing API** – для тестирования Jetpack Compose UI-компонентов[1]
- **Page Object Model** – паттерн для структурирования UI-тестов, улучшает читаемость и поддерживаемость[5]
- **Целевое покрытие:** 20-30% функционала через widget тесты[5]

##### 2.1. Создать базовую инфраструктуру для widget тестов

**Новый файл:** `test/helpers/widget_test_helpers.dart`

**Содержимое:**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// ... импорты моков

class WidgetTestHelpers {
  /// Создать ProviderScope с моками для тестов
  static ProviderScope createTestProviderScope({
    MockApiClient? apiClient,
    MockAuthService? authService,
    // ... другие моки
  }) {
    // Настройка провайдеров с моками
  }

  /// Создать MaterialApp с роутером для тестов
  static Widget createTestApp({
    String initialLocation = '/login',
    ProviderScope? providerScope,
  }) {
    // Создание MaterialApp.router с тестовым роутером
  }

  /// Ожидание анимации
  static Future<void> waitForAnimation(WidgetTester tester) async {
    await tester.pumpAndSettle();
  }

  /// Найти виджет по типу
  static T findWidget<T>(WidgetTester tester) {
    return tester.widget<T>(find.byType(T));
  }
}
```

**Оценка времени:** 1 день

##### 2.2. Widget тесты для основных виджетов

**Приоритет 1: Критичные виджеты**

1. **`test/widget/empty_state_test.dart`**
   ```dart
   - Тест отображения EmptyListState
   - Тест отображения EmptyErrorState
   - Тест отображения EmptySearchState
   - Тест кнопки retry
   - Тест кнопки действия
   ```

2. **`test/widget/sync_indicator_test.dart`**
   ```dart
   - Тест отображения статуса Pending
   - Тест отображения статуса Syncing
   - Тест отображения статуса Synced
   - Тест отображения статуса Failed
   - Тест отображения количества pending
   ```

3. **`test/widget/skeleton_loader_test.dart`**
   ```dart
   - Тест отображения SkeletonCard
   - Тест отображения SkeletonList
   - Тест анимации загрузки
   ```

4. **`test/widget/offline_banner_test.dart`**
   ```dart
   - Тест отображения в offline режиме
   - Тест скрытия в online режиме
   - Тест кнопки retry
   ```

5. **`test/widget/integrity_gauge_test.dart`**
   ```dart
   - Тест отображения разных уровней целостности
   - Тест цветов для разных уровней
   - Тест анимации прогресса
   ```

**Оценка времени:** 2-3 дня

**Приоритет 2: Навигационные виджеты**

6. **`test/widget/main_navigation_test.dart`**
   ```dart
   - Тест отображения bottom navigation
   - Тест переключения между вкладками
   - Тест активной вкладки
   ```

**Оценка времени:** 1 день

##### 2.3. Widget тесты для экранов

**Приоритет 1: Критичные экраны**

1. **`test/widget/login_screen_test.dart`**
   ```dart
   - Тест отображения формы логина
   - Тест валидации email
   - Тест валидации пароля
   - Тест кнопки входа
   - Тест биометрической аутентификации
   - Тест обработки ошибок
   - Тест навигации после успешного входа
   ```

2. **`test/widget/scanner_screen_test.dart`**
   ```dart
   - Тест отображения камеры
   - Тест обработки разрешений
   - Тест сканирования QR-кода
   - Тест debouncing
   - Тест навигации после сканирования
   - Тест обработки ошибок
   ```

3. **`test/widget/add_defect_screen_test.dart`**
   ```dart
   - Тест отображения формы
   - Тест выбора фото
   - Тест валидации полей
   - Тест сохранения дефекта
   - Тест обработки ошибок
   ```

4. **`test/widget/dashboard_screen_test.dart`**
   ```dart
   - Тест отображения статистики
   - Тест отображения графиков
   - Тест empty states
   - Тест loading states
   - Тест обработки ошибок
   ```

5. **`test/widget/assets_screen_test.dart`**
   ```dart
   - Тест отображения списка труб
   - Тест поиска
   - Тест фильтрации
   - Тест pull-to-refresh
   - Тест пагинации
   - Тест навигации к деталям
   ```

**Оценка времени:** 5-7 дней

**Приоритет 2: Вспомогательные экраны**

6. **`test/widget/settings_screen_test.dart`**
7. **`test/widget/profile_screen_test.dart`**
8. **`test/widget/sync_conflicts_screen_test.dart`**

**Оценка времени:** 2-3 дня

**Итого для Этапа 2:** 11-15 дней

---

#### Этап 3: Integration тесты (Приоритет: 🟡 Средний)

**Время:** 2-3 недели

**🌐 Решения из интернета (2026):**
- **Appium** – кросс-платформенный фреймворк для автоматизации UI-тестов на iOS и Android с поддержкой Selenium WebDriver[1][4]
- **Detox** – фреймворк для E2E-тестов React Native и Flutter приложений. Быстрые и стабильные тесты[5]
- **Firebase Test Lab** – облачное тестирование на реальных устройствах. Поддержка 2000+ устройств через BrowserStack[1][3]
- **Patrol** – современный инструмент для Flutter integration тестов (2026)[3]
- **Calabash** – автоматизация для iOS и Android сценариев[4]
- **Подход:** Тестировать критичные user journeys (вход, создание дефекта, синхронизация). Целевое покрытие: 10-15% функционала через E2E тесты[2][3]

##### 3.1. Настройка инфраструктуры

**Новая папка:** `integration_test/`

**Зависимости для `pubspec.yaml`:**

```yaml
dev_dependencies:
  integration_test:
    sdk: flutter
  # Опционально:
  patrol: ^3.0.0  # Для более продвинутых тестов
```

**Файл:** `integration_test/app_test.dart` (базовый)

**Оценка времени:** 1 день

##### 3.2. Критичные user flows

1. **`integration_test/auth_flow_test.dart`**
   ```dart
   - Полный flow входа
   - Выход
   - Биометрическая аутентификация
   ```

2. **`integration_test/qr_scan_flow_test.dart`**
   ```dart
   - Сканирование QR-кода
   - Просмотр деталей трубы
   - Создание дефекта
   ```

3. **`integration_test/offline_sync_flow_test.dart`**
   ```dart
   - Создание дефекта офлайн
   - Восстановление соединения
   - Автоматическая синхронизация
   - Разрешение конфликтов
   ```

4. **`integration_test/navigation_flow_test.dart`**
   ```dart
   - Навигация между экранами
   - Bottom navigation
   - Deep linking
   ```

**Оценка времени:** 5-7 дней

##### 3.3. Performance тесты

**Файл:** `integration_test/performance_test.dart`

**Что тестировать:**

```dart
1. Время запуска приложения
2. Время загрузки экранов
3. Производительность БД операций
4. Производительность синхронизации
5. Использование памяти
```

**Оценка времени:** 2-3 дня

**Итого для Этапа 3:** 8-11 дней

---

#### Этап 4: Настройка CI/CD для тестов (Приоритет: 🟡 Средний)

**Время:** 1 неделя

**🌐 Решения из интернета (2026):**
- **GitHub Actions / GitLab CI** – автоматический запуск тестов при каждом коммите. Блокировка слияния при падении тестов[3][5]
- **Fastlane** – автоматизация сборки, тестирования и развертывания для мобильных приложений[3]
- **Codemagic** – CI/CD специально для мобильных приложений с поддержкой Flutter[3]
- **Codecov / SonarQube** – автоматическое формирование отчетов о покрытии кода и загрузка в PR[3]
- **Рекомендация:** Настроить автоматический запуск unit + integration тестов на каждый PR, E2E тесты на nightly builds[3][5]

##### 4.1. GitHub Actions workflow

**Файл:** `.github/workflows/test.yml`

**Что включить:**

```yaml
1. Запуск unit тестов
2. Запуск widget тестов
3. Генерация coverage report
4. Загрузка coverage в Codecov/SonarQube
5. Проверка минимального покрытия (70%)
```

**Оценка времени:** 1-2 дня

##### 4.2. Настройка coverage reporting

**Инструменты:**
- Codecov или SonarQube
- Автоматические отчеты в PR

**Оценка времени:** 1 день

**Итого для Этапа 4:** 2-3 дня

---

### 📊 Итоговая оценка для Тестирования

| Этап | Время | Покрытие | Приоритет |
|------|-------|----------|-----------|
| Этап 1: Unit тесты | 8-13 дней | +20-30% | 🔴 Высокий |
| Этап 2: Widget тесты | 11-15 дней | +15-20% | 🔴 Высокий |
| Этап 3: Integration тесты | 8-11 дней | +5-10% | 🟡 Средний |
| Этап 4: CI/CD | 2-3 дня | - | 🟡 Средний |
| **ИТОГО** | **29-42 дня** | **70%+** | |

---

## 2. Мониторинг

### 📊 Текущее состояние

**Оценка:** ⭐⭐ (2/5)

**Что есть:**
- ✅ `ErrorHandler` для UI (показ ошибок пользователю)
- ✅ Базовое логирование через `debugPrint`

**Что отсутствует:**
- ❌ Crash reporting (Firebase Crashlytics / Sentry)
- ❌ Performance monitoring
- ❌ Analytics
- ❌ Централизованное логирование ошибок
- ❌ Отслеживание метрик

### 🎯 Цель

Добавить полноценный мониторинг приложения с crash reporting и performance tracking.

### 📝 План действий

#### Этап 1: Crash Reporting (Приоритет: 🔴 Критично)

**Время:** 1-2 недели

##### 1.1. Выбор решения

**Варианты:**

1. **Firebase Crashlytics** (рекомендуется)
   - ✅ Бесплатно
   - ✅ Интеграция с Firebase
   - ✅ Хорошая документация
   - ✅ Автоматический сбор crash reports

2. **Sentry**
   - ✅ Отличная функциональность
   - ✅ Поддержка Flutter
   - ⚠️ Платный для больших объемов

**Рекомендация:** Firebase Crashlytics

**🌐 Решения из интернета (2026):**
- **Firebase Crashlytics** – бесплатное решение от Google, встроено в Firebase Console. Автоматически отслеживает краши, их стеки и затронутых пользователей. Интеграция занимает 1-2 дня разработки[1][2][3]
- **Sentry** – более продвинутое решение с детальным контекстом ошибок, session replay и performance monitoring. Поддерживает offline-first сценарии. Платный для больших объемов[2][3]
- **Bugsnag** – альтернатива с красивым UI и автоматическим обнаружением регрессий[1]
- **Datadog** – комплексный мониторинг приложений с crash reporting[2]
- **Рекомендация 2026:** Начать с Firebase Crashlytics (бесплатно), при необходимости перейти на Sentry для более детальной аналитики[1][2][3]

##### 1.2. Установка зависимостей

**Файл:** `pubspec.yaml`

```yaml
dependencies:
  firebase_core: ^3.0.0
  firebase_crashlytics: ^4.0.0
  # Опционально для analytics:
  firebase_analytics: ^11.0.0
```

**Оценка времени:** 0.5 дня

##### 1.3. Настройка Firebase проекта

**Шаги:**

1. Создать проект в Firebase Console
2. Добавить Android app (package name из `android/app/build.gradle`)
3. Добавить iOS app (bundle ID из `ios/Runner.xcodeproj`)
4. Скачать конфигурационные файлы:
   - `google-services.json` для Android
   - `GoogleService-Info.plist` для iOS

**Файлы для обновления:**

- `android/app/build.gradle` - добавить plugin
- `android/build.gradle` - добавить classpath
- `ios/Podfile` - добавить Firebase pods
- `ios/Runner/Info.plist` - добавить конфигурацию

**Оценка времени:** 1 день

##### 1.4. Создание сервиса для crash reporting

**Новый файл:** `lib/core/services/crash_reporting_service.dart`

**Содержимое:**

```dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class CrashReportingService {
  static final CrashReportingService _instance = CrashReportingService._internal();
  factory CrashReportingService() => _instance;
  CrashReportingService._internal();

  bool _initialized = false;

  /// Инициализация crash reporting
  Future<void> initialize() async {
    if (_initialized) return;
    
    // Настройка для Flutter errors
    FlutterError.onError = (FlutterErrorDetails details) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
      // В debug режиме показываем ошибку
      if (kDebugMode) {
        FlutterError.presentError(details);
      }
    };

    // Настройка для platform errors
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    _initialized = true;
  }

  /// Логирование нефатальной ошибки
  static void recordError(
    dynamic exception,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
  }) {
    FirebaseCrashlytics.instance.recordError(
      exception,
      stack,
      reason: reason,
      fatal: fatal,
    );
  }

  /// Логирование сообщения
  static void log(String message) {
    FirebaseCrashlytics.instance.log(message);
  }

  /// Установка пользовательского идентификатора
  static void setUserId(String userId) {
    FirebaseCrashlytics.instance.setUserIdentifier(userId);
  }

  /// Установка custom keys
  static void setCustomKey(String key, dynamic value) {
    FirebaseCrashlytics.instance.setCustomKey(key, value);
  }

  /// Тест crash (только для разработки)
  static void testCrash() {
    FirebaseCrashlytics.instance.crash();
  }
}
```

**Оценка времени:** 1 день

##### 1.5. Интеграция в приложение

**Файл:** `lib/main.dart`

**Изменения:**

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Инициализация Firebase
  await Firebase.initializeApp();
  
  // Инициализация Crash Reporting
  await CrashReportingService().initialize();
  
  // ... остальная инициализация
}
```

**Оценка времени:** 0.5 дня

##### 1.6. Интеграция с ErrorHandler

**Файл:** `lib/core/services/error_handler.dart`

**Изменения:**

```dart
class ErrorHandler {
  // ... существующий код

  /// Show error snackbar with crash reporting
  static void showError(BuildContext context, dynamic error) {
    // Логирование в Crashlytics
    CrashReportingService.recordError(
      error,
      StackTrace.current,
      reason: 'UI Error',
      fatal: false,
    );

    // ... существующий код показа SnackBar
  }
}
```

**Оценка времени:** 0.5 дня

##### 1.7. Добавление логирования в критичных местах

**Файлы для обновления:**

1. `lib/repositories/defect_repository.dart`
   - Логирование ошибок синхронизации
   - Логирование конфликтов

2. `lib/data/api/api_client.dart`
   - Логирование сетевых ошибок
   - Логирование retry попыток

3. `lib/core/services/auth_service.dart`
   - Логирование ошибок аутентификации

**Оценка времени:** 1 день

**Итого для Этапа 1:** 4-5 дней

---

#### Этап 2: Performance Monitoring (Приоритет: 🔴 Высокий)

**Время:** 1-2 недели

**🌐 Решения из интернета (2026):**
- **Firebase Performance Monitoring** – отслеживание времени загрузки, задержек сети, работы батареи. Встроена в Firebase, бесплатно до лимита[1][2]
- **New Relic Mobile** – детальный анализ производительности и UX-метрик. Real User Monitoring (RUM) с анализом по регионам[2][3]
- **Datadog** – комплексный мониторинг с интеграцией в APM. Метрики производительности батареи, памяти, CPU[2]
- **Amplitude** – поведенческая аналитика с отслеживанием производительности[2]
- **Метрики для отслеживания:** время холодного старта <2 секунд, не более 1 краша на 10,000 сессий, расход батареи в норме[3]

##### 2.1. Установка зависимостей

**Файл:** `pubspec.yaml`

```yaml
dependencies:
  firebase_performance: ^0.9.0
```

**Оценка времени:** 0.5 дня

##### 2.2. Создание сервиса для performance monitoring

**Новый файл:** `lib/core/services/performance_service.dart`

**Содержимое:**

```dart
import 'package:firebase_performance/firebase_performance.dart';

class PerformanceService {
  static final FirebasePerformance _performance = FirebasePerformance.instance;

  /// Начать отслеживание HTTP запроса
  static HttpMetric startHttpMetric(String url, HttpMethod method) {
    final metric = _performance.newHttpMetric(url, method);
    metric.start();
    return metric;
  }

  /// Завершить отслеживание HTTP запроса
  static Future<void> stopHttpMetric(
    HttpMetric metric, {
    int? statusCode,
    int? responsePayloadSize,
  }) async {
    if (statusCode != null) {
      metric.httpResponseCode = statusCode;
    }
    if (responsePayloadSize != null) {
      metric.responsePayloadSize = responsePayloadSize;
    }
    await metric.stop();
  }

  /// Начать отслеживание кастомной операции
  static Trace startTrace(String name) {
    final trace = _performance.newTrace(name);
    trace.start();
    return trace;
  }

  /// Завершить отслеживание кастомной операции
  static Future<void> stopTrace(Trace trace) async {
    await trace.stop();
  }

  /// Добавить атрибут к trace
  static void putAttribute(Trace trace, String name, String value) {
    trace.putAttribute(name, value);
  }

  /// Добавить метрику к trace
  static void incrementMetric(Trace trace, String name, int value) {
    trace.incrementMetric(name, value);
  }
}
```

**Оценка времени:** 1 день

##### 2.3. Интеграция в ApiClient

**Файл:** `lib/data/api/api_client.dart`

**Изменения:**

```dart
class ApiClient {
  // ... существующий код

  Future<Response> _makeRequest(
    String method,
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    final url = '$baseUrl$path';
    final httpMethod = _getHttpMethod(method);
    
    // Начать отслеживание
    final metric = PerformanceService.startHttpMetric(url, httpMethod);
    
    try {
      final response = await _dio.request(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(method: method),
      );

      // Завершить отслеживание
      await PerformanceService.stopHttpMetric(
        metric,
        statusCode: response.statusCode,
        responsePayloadSize: response.data?.toString().length,
      );

      return response;
    } catch (e) {
      // Завершить отслеживание с ошибкой
      await PerformanceService.stopHttpMetric(
        metric,
        statusCode: (e as DioException).response?.statusCode,
      );
      rethrow;
    }
  }
}
```

**Оценка времени:** 1 день

##### 2.4. Отслеживание критичных операций

**Файлы для обновления:**

1. **`lib/repositories/defect_repository.dart`**
   ```dart
   // Отслеживание синхронизации
   Future<SyncResult> syncPendingDefects() async {
     final trace = PerformanceService.startTrace('sync_pending_defects');
     try {
       // ... существующий код
       PerformanceService.putAttribute(trace, 'defect_count', pendingDefects.length.toString());
       return result;
     } finally {
       await PerformanceService.stopTrace(trace);
     }
   }
   ```

2. **`lib/ui/screens/improved_scanner_screen.dart`**
   ```dart
   // Отслеживание сканирования QR
   void _handleScan(String qrCode) async {
     final trace = PerformanceService.startTrace('qr_scan');
     try {
       // ... существующий код
     } finally {
       await PerformanceService.stopTrace(trace);
     }
   }
   ```

3. **`lib/core/services/image_upload_service.dart`**
   ```dart
   // Отслеживание загрузки фото
   Future<List<String>> uploadPhotos(List<String> paths) async {
     final trace = PerformanceService.startTrace('upload_photos');
     PerformanceService.putAttribute(trace, 'photo_count', paths.length.toString());
     try {
       // ... существующий код
     } finally {
       await PerformanceService.stopTrace(trace);
     }
   }
   ```

**Оценка времени:** 2 дня

##### 2.5. Отслеживание времени загрузки экранов

**Новый файл:** `lib/core/mixins/performance_tracker_mixin.dart`

**Содержимое:**

```dart
import 'package:flutter/material.dart';
import '../services/performance_service.dart';

mixin PerformanceTrackerMixin<T extends StatefulWidget> on State<T> {
  Trace? _screenTrace;
  String? _screenName;

  @override
  void initState() {
    super.initState();
    _screenName = widget.runtimeType.toString();
    _screenTrace = PerformanceService.startTrace('screen_load_$_screenName');
  }

  @override
  void dispose() {
    _screenTrace?.stop();
    super.dispose();
  }

  void markScreenReady() {
    _screenTrace?.stop();
    _screenTrace = null;
  }
}
```

**Использование:**

```dart
class DashboardScreen extends ConsumerStatefulWidget {
  // ...
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> 
    with PerformanceTrackerMixin {
  
  @override
  Widget build(BuildContext context) {
    // После загрузки данных
    WidgetsBinding.instance.addPostFrameCallback((_) {
      markScreenReady();
    });
    // ...
  }
}
```

**Оценка времени:** 1 день

**Итого для Этапа 2:** 5-6 дней

---

#### Этап 3: Analytics (Приоритет: 🟡 Средний)

**Время:** 1 неделя

**🌐 Решения из интернета (2026):**
- **Firebase Analytics / Google Analytics 4** – событийная аналитика, конверсии, retention. Встроена в Firebase, бесплатно[1][2]
- **AppMetrica (Яндекс)** – русскоязычная альтернатива с GDPR compliance. Метрики для мобильных приложений[2]
- **Amplitude** – продвинутая поведенческая аналитика с отслеживанием воронок и когорт[2][3]
- **Mixpanel** – детальная аналитика пользовательского поведения[2]
- **Рекомендация:** Начать с Firebase Analytics (бесплатно), при необходимости добавить Amplitude для более детального анализа[1][2]

##### 3.1. Установка зависимостей

**Файл:** `pubspec.yaml`

```yaml
dependencies:
  firebase_analytics: ^11.0.0
```

**Оценка времени:** 0.5 дня

##### 3.2. Создание сервиса для analytics

**Новый файл:** `lib/core/services/analytics_service.dart`

**Содержимое:**

```dart
import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Логирование события
  static Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    await _analytics.logEvent(
      name: name,
      parameters: parameters,
    );
  }

  /// Установка пользовательского свойства
  static Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    await _analytics.setUserProperty(name: name, value: value);
  }

  /// Установка идентификатора пользователя
  static Future<void> setUserId(String? userId) async {
    await _analytics.setUserId(userId);
  }

  /// Логирование экрана
  static Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass,
    );
  }

  // Предопределенные события
  static Future<void> logLogin({String? method}) async {
    await logEvent(
      name: 'login',
      parameters: {'method': method ?? 'email'},
    );
  }

  static Future<void> logQrScan({required String qrCode}) async {
    await logEvent(
      name: 'qr_scan',
      parameters: {'qr_code': qrCode},
    );
  }

  static Future<void> logDefectCreated({
    required String defectType,
    required int severity,
  }) async {
    await logEvent(
      name: 'defect_created',
      parameters: {
        'defect_type': defectType,
        'severity': severity,
      },
    );
  }

  static Future<void> logSyncCompleted({
    required int synced,
    required int failed,
    required int conflicts,
  }) async {
    await logEvent(
      name: 'sync_completed',
      parameters: {
        'synced': synced,
        'failed': failed,
        'conflicts': conflicts,
      },
    );
  }
}
```

**Оценка времени:** 1 день

##### 3.3. Интеграция в приложение

**Файлы для обновления:**

1. **`lib/ui/screens/login_screen.dart`**
   ```dart
   // После успешного входа
   await AnalyticsService.logLogin(method: 'email');
   ```

2. **`lib/ui/screens/improved_scanner_screen.dart`**
   ```dart
   // После сканирования QR
   await AnalyticsService.logQrScan(qrCode: qrCode);
   ```

3. **`lib/ui/screens/add_defect_screen.dart`**
   ```dart
   // После создания дефекта
   await AnalyticsService.logDefectCreated(
     defectType: defect.defectType,
     severity: defect.severity,
   );
   ```

4. **`lib/repositories/defect_repository.dart`**
   ```dart
   // После синхронизации
   await AnalyticsService.logSyncCompleted(
     synced: result.synced,
     failed: result.failed,
     conflicts: result.conflicts,
   );
   ```

**Оценка времени:** 2 дня

**Итого для Этапа 3:** 3-4 дня

---

### 📊 Итоговая оценка для Мониторинга

| Этап | Время | Приоритет |
|------|-------|-----------|
| Этап 1: Crash Reporting | 4-5 дней | 🔴 Критично |
| Этап 2: Performance Monitoring | 5-6 дней | 🔴 Высокий |
| Этап 3: Analytics | 3-4 дня | 🟡 Средний |
| **ИТОГО** | **12-15 дней** | |

---

## 3. UX/UI улучшения

### 📊 Текущее состояние

**Оценка:** ⭐⭐⭐⭐ (4/5)

**Что есть:**
- ✅ Современный Material Design
- ✅ Empty states
- ✅ Loading states (skeleton loaders)
- ✅ Базовые анимации (FadeTransition, SlideTransition)
- ✅ Обработка ошибок в UI

**Что отсутствует:**
- ❌ Onboarding для новых пользователей
- ❌ Hero animations для плавных переходов
- ❌ Расширенные анимации переходов между экранами
- ❌ Анимации появления элементов списка

### 🎯 Цель

Улучшить UX через onboarding и плавные анимации.

### 📝 План действий

#### Этап 1: Onboarding (Приоритет: 🔴 Высокий)

**Время:** 1-2 недели

**🌐 Решения из интернета (2026):**
- **Flutter Intro Slider / introduction_screen** – готовые пакеты для пошагового тура. Позволяют быстро создать 3-5 экранов с основными функциями[1][3]
- **ShowcaseView / TutorialCoachMark** – библиотеки для создания tutorial-слайдов с подсветкой элементов интерфейса[2][3]
- **Material 3 Carousel** – на базе Design Guidelines для современного дизайна[1]
- **Firebase Remote Config** – динамическое управление onboarding в зависимости от версии ОС и A/B тестирование[1][2]
- **Best practice 2026:** 2-4 экрана максимум, акцент на главной функции, skip-кнопка обязательна. Использовать A/B тестирование для оптимизации retention rate[1][3]

##### 1.1. Дизайн onboarding экранов

**Количество экранов:** 3-4

**Содержание:**

1. **Экран 1: Приветствие**
   - Заголовок: "Добро пожаловать в Tutas Safe"
   - Описание: "Мониторинг целостности трубопроводов"
   - Иллюстрация: Иконка или изображение

2. **Экран 2: Основные функции**
   - QR-сканер для быстрого доступа к трубам
   - Создание дефектов с фото
   - Офлайн режим работы

3. **Экран 3: Синхронизация**
   - Автоматическая синхронизация данных
   - Разрешение конфликтов

4. **Экран 4: Готово**
   - Кнопка "Начать работу"

**Оценка времени:** 1 день (дизайн)

##### 1.2. Создание onboarding экрана

**Новый файл:** `lib/ui/screens/onboarding_screen.dart`

**Структура:**

```dart
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Добро пожаловать',
      description: 'Мониторинг целостности трубопроводов',
      icon: Icons.pipeline,
      color: AppTheme.primaryDark,
    ),
    // ... другие страницы
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        itemCount: _pages.length,
        itemBuilder: (context, index) {
          return _buildPage(_pages[index]);
        },
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Container(
      // ... дизайн страницы
    );
  }

  Widget _buildBottomBar() {
    return Container(
      // Индикатор страниц
      // Кнопка "Пропустить" / "Далее" / "Начать"
    );
  }
}
```

**Оценка времени:** 2-3 дня

##### 1.3. Модель данных для onboarding

**Новый файл:** `lib/core/models/onboarding_page.dart`

**Содержимое:**

```dart
class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String? imagePath;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.imagePath,
  });
}
```

**Оценка времени:** 0.5 дня

##### 1.4. Локальное хранение статуса onboarding

**Файл:** `lib/core/services/onboarding_service.dart`

**Содержимое:**

```dart
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingService {
  static const String _onboardingCompletedKey = 'onboarding_completed';

  /// Проверить, прошел ли пользователь onboarding
  static Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingCompletedKey) ?? false;
  }

  /// Отметить onboarding как завершенный
  static Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompletedKey, true);
  }

  /// Сбросить onboarding (для тестирования)
  static Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_onboardingCompletedKey);
  }
}
```

**Оценка времени:** 0.5 дня

##### 1.5. Интеграция в роутер

**Файл:** `lib/router.dart`

**Изменения:**

```dart
final appRouter = GoRouter(
  initialLocation: '/onboarding', // Изменить на /onboarding
  redirect: (context, state) async {
    // Проверка onboarding
    final isOnboardingCompleted = await OnboardingService.isOnboardingCompleted();
    final location = state.uri.toString();
    
    if (!isOnboardingCompleted && location != '/onboarding') {
      return '/onboarding';
    }
    
    if (isOnboardingCompleted && location == '/onboarding') {
      return '/login';
    }
    
    // ... существующая логика аутентификации
  },
  routes: [
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    // ... остальные маршруты
  ],
);
```

**Оценка времени:** 1 день

##### 1.6. Локализация

**Файл:** `lib/core/l10n/app_localizations.dart`

**Добавить строки:**

```dart
// Onboarding
String get onboardingWelcomeTitle => _getString('onboardingWelcomeTitle');
String get onboardingWelcomeDescription => _getString('onboardingWelcomeDescription');
String get onboardingQrScannerTitle => _getString('onboardingQrScannerTitle');
// ... и т.д.
```

**Оценка времени:** 1 день

**Итого для Этапа 1:** 6-7 дней

---

#### Этап 2: Hero Animations (Приоритет: 🟡 Средний)

**Время:** 1-2 недели

**🌐 Решения из интернета (2026):**
- **Flutter Hero widget** – встроенный виджет для анимированного переноса элемента между экранами. Поддерживает iOS-like переходы с плавной анимацией[2][5]
- **Lottie** – библиотека для воспроизведения векторных анимаций из After Effects (JSON-формат). Уменьшает размер APK, поддерживает сложные анимации[1][2][3]
- **Flutter Staggered Animations** – пакет для создания каскадных анимаций с задержками. Идеально для списков[5]
- **Material 3 Transitions** – новый стандарт Google для анимаций переходов между экранами (2026)[3]
- **Rive** – профессиональный инструмент для сложных интерактивных 2D анимаций[1]
- **Best practices:** Длительность 200-500ms для smoothness, использовать Curves (easeInOut, elasticOut). Начать с 5-7 ключевых экранов[1][3]

##### 2.1. Идентификация элементов для Hero animations

**Элементы для анимации:**

1. **Изображения труб** (Assets → Asset Detail)
   - Hero tag: `pipe-image-${pipeId}`
   - Изображение трубы в списке → детальный экран

2. **QR-код** (Scanner → QR Detail)
   - Hero tag: `qr-code-${qrCode}`
   - QR-код в сканере → детальный экран

3. **Дефекты** (Dashboard → Asset Detail)
   - Hero tag: `defect-${defectId}`
   - Карточка дефекта → детальный экран

4. **Фото дефектов** (Asset Detail → Photo Viewer)
   - Hero tag: `defect-photo-${photoIndex}`
   - Миниатюра → полноэкранное фото

**Оценка времени:** 0.5 дня (планирование)

##### 2.2. Реализация Hero для изображений труб

**Файл:** `lib/ui/screens/assets_screen.dart`

**Изменения:**

```dart
// В списке труб
Hero(
  tag: 'pipe-image-${pipe.id}',
  child: CachedImageWidget(
    imageUrl: pipe.imageUrl,
    width: 60,
    height: 60,
  ),
)
```

**Файл:** `lib/ui/screens/asset_detail_screen.dart`

**Изменения:**

```dart
// В детальном экране
Hero(
  tag: 'pipe-image-${pipe.id}',
  child: CachedImageWidget(
    imageUrl: pipe.imageUrl,
    width: double.infinity,
    height: 200,
  ),
)
```

**Оценка времени:** 1 день

##### 2.3. Реализация Hero для QR-кодов

**Файл:** `lib/ui/screens/improved_scanner_screen.dart`

**Изменения:**

```dart
// После сканирования QR
Hero(
  tag: 'qr-code-${qrCode}',
  child: Container(
    // Визуализация QR-кода
  ),
)
```

**Файл:** `lib/ui/screens/qr_detail_screen.dart`

**Изменения:**

```dart
// В детальном экране
Hero(
  tag: 'qr-code-${qrCode}',
  child: Container(
    // Визуализация QR-кода
  ),
)
```

**Оценка времени:** 1 день

##### 2.4. Реализация Hero для дефектов

**Файл:** `lib/ui/screens/dashboard_screen.dart`

**Изменения:**

```dart
// В списке дефектов
Hero(
  tag: 'defect-${defect.id}',
  child: DefectCard(defect: defect),
)
```

**Файл:** `lib/ui/screens/asset_detail_screen.dart`

**Изменения:**

```dart
// В детальном экране
Hero(
  tag: 'defect-${defect.id}',
  child: DefectDetailCard(defect: defect),
)
```

**Оценка времени:** 1 день

##### 2.5. Реализация Hero для фото дефектов

**Файл:** `lib/ui/screens/asset_detail_screen.dart`

**Изменения:**

```dart
// Миниатюра фото
Hero(
  tag: 'defect-photo-${index}',
  child: GestureDetector(
    onTap: () {
      // Навигация к полноэкранному просмотру
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PhotoViewerScreen(
            photos: defect.photos,
            initialIndex: index,
          ),
        ),
      );
    },
    child: CachedImageWidget(
      imageUrl: photo,
      width: 100,
      height: 100,
    ),
  ),
)
```

**Новый файл:** `lib/ui/screens/photo_viewer_screen.dart`

**Содержимое:**

```dart
class PhotoViewerScreen extends StatelessWidget {
  final List<String> photos;
  final int initialIndex;

  const PhotoViewerScreen({
    super.key,
    required this.photos,
    this.initialIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        initialPage: initialIndex,
        itemCount: photos.length,
        itemBuilder: (context, index) {
          return Hero(
            tag: 'defect-photo-$index',
            child: InteractiveViewer(
              child: CachedImageWidget(
                imageUrl: photos[index],
                fit: BoxFit.contain,
              ),
            ),
          );
        },
      ),
    );
  }
}
```

**Оценка времени:** 2 дня

**Итого для Этапа 2:** 5-6 дней

---

#### Этап 3: Улучшенные переходы между экранами (Приоритет: 🟡 Средний)

**Время:** 1 неделя

**🌐 Решения из интернета (2026):**
- **GoRouter Custom Transitions** – настройка `pageBuilder` с `CustomTransitionPage` для кастомных анимаций[5]
- **Material Motion** – использование стандартных Material Design анимаций (FadeTransition, SlideTransition)[1]
- **SharedAxisTransition** – из Material Motion для плавных переходов между экранами[5]
- **flutter_staggered_animations** – пакет для анимации появления элементов списка с задержками[5]
- **Best practices:** Избегать сложных анимаций на слабых устройствах, использовать `RepaintBoundary` для оптимизации[1]

##### 3.1. Кастомные transitions для GoRouter

**Файл:** `lib/core/theme/app_transitions.dart`

**Содержимое:**

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppTransitions {
  /// Fade transition
  static CustomTransitionPage fadeTransition({
    required Widget child,
    required GoRouterState state,
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  /// Slide transition
  static CustomTransitionPage slideTransition({
    required Widget child,
    required GoRouterState state,
    Axis direction = Axis.rightToLeft,
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  /// Scale transition
  static CustomTransitionPage scaleTransition({
    required Widget child,
    required GoRouterState state,
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: animation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
```

**Оценка времени:** 1 день

##### 3.2. Интеграция в роутер

**Файл:** `lib/router.dart`

**Изменения:**

```dart
GoRoute(
  path: '/pipe/:id',
  name: 'pipe-detail',
  pageBuilder: (context, state) {
    return AppTransitions.slideTransition(
      child: AssetDetailScreen(
        pipeId: state.pathParameters['id']!,
      ),
      state: state,
    );
  },
),
```

**Оценка времени:** 1 день

##### 3.3. Анимации появления элементов списка

**Новый файл:** `lib/ui/widgets/animated_list_item.dart`

**Содержимое:**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class AnimatedListItem extends StatelessWidget {
  final Widget child;
  final int index;
  final Duration delay;

  const AnimatedListItem({
    super.key,
    required this.child,
    required this.index,
    this.delay = const Duration(milliseconds: 100),
  });

  @override
  Widget build(BuildContext context) {
    return AnimationConfiguration.staggeredList(
      position: index,
      duration: const Duration(milliseconds: 375),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: child,
        ),
      ),
    );
  }
}
```

**Зависимость:**

```yaml
dependencies:
  flutter_staggered_animations: ^1.1.1
```

**Использование:**

```dart
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return AnimatedListItem(
      index: index,
      child: ItemCard(item: items[index]),
    );
  },
)
```

**Оценка времени:** 1 день

##### 3.4. Интеграция в существующие экраны

**Файлы для обновления:**

1. `lib/ui/screens/assets_screen.dart`
   - Анимация появления карточек труб

2. `lib/ui/screens/dashboard_screen.dart`
   - Анимация появления задач
   - Анимация появления дефектов

3. `lib/ui/screens/tasks_screen.dart`
   - Анимация появления задач

**Оценка времени:** 2 дня

**Итого для Этапа 3:** 5 дней

---

#### Этап 4: Дополнительные UX улучшения (Приоритет: 🟢 Низкий)

**Время:** 1 неделя

**🌐 Решения из интернета (2026):**
- **flutter_haptic_feedback** – пакет для тактильной обратной связи (вибрация при нажатии). Улучшает UX взаимодействия[3]
- **Material Design Haptic Feedback** – встроенная поддержка в Material 3 для различных типов взаимодействий[1]
- **Accessibility (a11y)** – проверка с TalkBack (Android) и VoiceOver (iOS). Обеспечение контрастности текста (WCAG AA)[1][4]
- **Pixel Perfect Testing** – инструменты для проверки адаптивности на разных экранах (BrowserStack Mobile)[2]

##### 4.1. Haptic feedback

**Зависимость:**

```yaml
dependencies:
  flutter_haptic_feedback: ^0.6.0
```

**Использование:**

```dart
// При успешном сканировании QR
HapticFeedback.mediumImpact();

// При ошибке
HapticFeedback.heavyImpact();
```

**Оценка времени:** 1 день

##### 4.2. Pull-to-refresh анимации

**Улучшить существующий RefreshIndicator с кастомной анимацией**

**Оценка времени:** 1 день

##### 4.3. Skeleton loader анимации

**Улучшить существующие skeleton loaders с более плавными анимациями**

**Оценка времени:** 1 день

**Итого для Этапа 4:** 3 дня

---

### 📊 Итоговая оценка для UX/UI

| Этап | Время | Приоритет |
|------|-------|-----------|
| Этап 1: Onboarding | 6-7 дней | 🔴 Высокий |
| Этап 2: Hero Animations | 5-6 дней | 🟡 Средний |
| Этап 3: Улучшенные переходы | 5 дней | 🟡 Средний |
| Этап 4: Дополнительные улучшения | 3 дня | 🟢 Низкий |
| **ИТОГО** | **19-21 день** | |

---

## 📊 Общая сводка плана

### Временные оценки

| Область | Время | Приоритет |
|---------|-------|-----------|
| **1. Тестирование** | 29-42 дня | 🔴 Высокий |
| **2. Мониторинг** | 12-15 дней | 🔴 Высокий |
| **3. UX/UI** | 19-21 день | 🟡 Средний |
| **ИТОГО** | **60-78 дней** | |

### Приоритизация

#### Фаза 1: Критично (4-6 недель)
1. ✅ Завершение Unit тестов
2. ✅ Crash Reporting
3. ✅ Performance Monitoring
4. ✅ Onboarding

#### Фаза 2: Важно (3-4 недели)
1. ✅ Widget тесты
2. ✅ Hero Animations
3. ✅ Улучшенные переходы

#### Фаза 3: Желательно (2-3 недели)
1. ✅ Integration тесты
2. ✅ Analytics
3. ✅ Дополнительные UX улучшения
4. ✅ CI/CD для тестов

---

## 📝 Зависимости для добавления

### Тестирование

```yaml
dev_dependencies:
  integration_test:
    sdk: flutter
  # Опционально:
  patrol: ^3.0.0
  http_mock_adapter: ^1.0.0  # Для мокирования Dio
```

### Мониторинг

```yaml
dependencies:
  firebase_core: ^3.0.0
  firebase_crashlytics: ^4.0.0
  firebase_performance: ^0.9.0
  firebase_analytics: ^11.0.0
```

### UX/UI

```yaml
dependencies:
  flutter_staggered_animations: ^1.1.1
  flutter_haptic_feedback: ^0.6.0
```

---

## ✅ Чеклист реализации

### Тестирование
- [ ] Завершить unit тесты для всех сервисов
- [ ] Создать widget тесты для критичных экранов
- [ ] Настроить integration тесты
- [ ] Настроить CI/CD для автоматического запуска тестов
- [ ] Достичь покрытия 70%+

### Мониторинг
- [ ] Настроить Firebase проект
- [ ] Интегрировать Crashlytics
- [ ] Интегрировать Performance Monitoring
- [ ] Интегрировать Analytics
- [ ] Добавить логирование в критичных местах

### UX/UI
- [ ] Создать onboarding экраны
- [ ] Интегрировать onboarding в роутер
- [ ] Добавить Hero animations для изображений
- [ ] Добавить кастомные transitions
- [ ] Добавить анимации появления элементов

---

## 📚 Полезные ресурсы

### Тестирование
- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Widget Testing Guide](https://docs.flutter.dev/testing/widget-tests)
- [Integration Testing](https://docs.flutter.dev/testing/integration-tests)
- [Тестирование мобильного приложения: полное руководство](https://surf.ru/testirovanie-mobilnogo-prilozheniya) [1]
- [Про тестирование мобильных приложений. Часть 1. Обзор](https://habr.com/ru/articles/711718/) [5]

### Мониторинг
- [Firebase Crashlytics](https://firebase.google.com/docs/crashlytics)
- [Firebase Performance](https://firebase.google.com/docs/perf-mon)
- [Firebase Analytics](https://firebase.google.com/docs/analytics)
- [Аналитика мобильных приложений: полное руководство](https://surf.ru/analitika-mobilnyh-prilozhenij/) [2]

### UX/UI
- [Hero Animations](https://docs.flutter.dev/ui/animations/hero-animations)
- [Material Motion](https://m3.material.io/styles/motion/overview)
- [Flutter Staggered Animations](https://pub.dev/packages/flutter_staggered_animations)
- [Как правильно тестировать мобильные приложения?](https://aiston.ru/blog/kak-pravilno-testirovat-mobilnye-prilozheniya/) [3]

---

## 🌐 Источники решений из интернета (2026)

Все решения в этом плане основаны на актуальных практиках и рекомендациях 2026 года:

**[1] Surf.ru - Тестирование мобильного приложения: полное руководство по обеспечению качества**
- URL: https://surf.ru/testirovanie-mobilnogo-prilozheniya
- Описание: Полное руководство по тестированию мобильных приложений, включая unit, widget, integration и E2E тесты

**[2] Surf.ru - Аналитика мобильных приложений: полное руководство по метрикам и инструментам**
- URL: https://surf.ru/analitika-mobilnyh-prilozhenij/
- Описание: Руководство по настройке аналитики, crash reporting и performance monitoring

**[3] Aiston.ru - Как правильно тестировать мобильные приложения?**
- URL: https://aiston.ru/blog/kak-pravilno-testirovat-mobilnye-prilozheniya/
- Описание: Практические рекомендации по тестированию мобильных приложений

**[4] QATools.ru - Сокращение технического долга в UI-тестах**
- URL: https://qatools.ru/blog/what-is-a-mobile-app-testing
- Описание: Лучшие практики для стабильных UI-тестов и интеграционного тестирования

**[5] Habr - Про тестирование мобильных приложений. Часть 1. Обзор**
- URL: https://habr.com/ru/articles/711718/
- Описание: Обзор современных подходов к тестированию мобильных приложений

---

**Последнее обновление:** 2025-01-19  
**Статус:** План готов к реализации с актуальными решениями из интернета (2026)
