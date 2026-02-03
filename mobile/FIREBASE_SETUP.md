# Настройка Firebase для Crash Reporting

## 📋 Шаги настройки

### 1. Создание проекта в Firebase Console

1. Перейдите на [Firebase Console](https://console.firebase.google.com/)
2. Нажмите "Add project" или выберите существующий проект
3. Следуйте инструкциям мастера создания проекта

### 2. Добавление Android приложения

1. В Firebase Console выберите ваш проект
2. Нажмите на иконку Android или "Add app" → Android
3. Введите package name из `android/app/build.gradle`:
   ```gradle
   android {
       defaultConfig {
           applicationId "com.example.tutas_ai_mobile"  // <-- это package name
       }
   }
   ```
4. Скачайте файл `google-services.json`
5. Поместите его в `android/app/google-services.json`

### 3. Добавление iOS приложения

1. В Firebase Console нажмите "Add app" → iOS
2. Введите Bundle ID из `ios/Runner.xcodeproj`:
   - Откройте Xcode
   - Выберите Runner → General → Bundle Identifier
3. Скачайте файл `GoogleService-Info.plist`
4. Поместите его в `ios/Runner/GoogleService-Info.plist`
5. В Xcode добавьте файл в проект (перетащите в Runner)

### 4. Обновление конфигурации Android

**Файл:** `android/build.gradle`

```gradle
buildscript {
    dependencies {
        // ... существующие зависимости
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

**Файл:** `android/app/build.gradle`

```gradle
apply plugin: 'com.android.application'
apply plugin: 'kotlin-android'
apply plugin: 'com.google.gms.google-services'  // <-- добавить в конец

dependencies {
    // ... существующие зависимости
}
```

### 5. Обновление конфигурации iOS

**Файл:** `ios/Podfile`

```ruby
platform :ios, '12.0'

target 'Runner' do
  use_frameworks!
  use_modular_headers!

  # ... существующие pods
  
  # Firebase pods
  pod 'Firebase/Core'
  pod 'Firebase/Crashlytics'
end
```

Затем выполните:
```bash
cd ios
pod install
```

### 6. Включение Crashlytics в коде

**Файл:** `lib/main.dart`

Раскомментируйте строки инициализации Firebase:

```dart
// Initialize Firebase
await Firebase.initializeApp();
await CrashReportingService().initialize();
```

### 7. Тестирование

После настройки можно протестировать crash reporting:

```dart
// Только в debug режиме!
if (kDebugMode) {
  CrashReportingService.testCrash();
}
```

⚠️ **ВНИМАНИЕ:** Это вызовет краш приложения! Используйте только для тестирования.

## ✅ Проверка работы

1. Запустите приложение
2. Проверьте логи - должно быть сообщение: `✅ Crash Reporting initialized`
3. В Firebase Console → Crashlytics должны появиться отчеты (может занять несколько минут)

## 🔧 Troubleshooting

### Ошибка: "Firebase not configured"
- Убедитесь, что файлы `google-services.json` и `GoogleService-Info.plist` на месте
- Проверьте, что package name / bundle ID совпадают с Firebase Console

### Ошибка: "Plugin not found"
- Убедитесь, что добавили `classpath 'com.google.gms:google-services:4.4.0'` в `android/build.gradle`
- Выполните `flutter clean` и `flutter pub get`

### Crashlytics не отправляет отчеты
- Убедитесь, что приложение запущено не в debug режиме (в debug режиме отчеты могут не отправляться)
- Проверьте интернет-соединение
- Отчеты могут появиться с задержкой до 24 часов

## 📚 Дополнительные ресурсы

- [Firebase Crashlytics Documentation](https://firebase.google.com/docs/crashlytics)
- [FlutterFire Setup](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com/)
