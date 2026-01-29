# Руководство по мультиязычности

## ✅ Что уже сделано

1. **Расширена локализация** - добавлены все строки для всех экранов приложения
2. **Обновлен improved_scanner_screen** - полностью использует локализацию
3. **Настроен locale_provider** - управление языком через Riverpod
4. **Поддержка 3 языков**: English, Русский, Қазақша

## 📝 Как использовать локализацию в экранах

### 1. Импортируйте локализацию

```dart
import '../../core/l10n/app_localizations.dart';
```

### 2. Получите экземпляр локализации

```dart
final l10n = AppLocalizations.of(context)!;
```

### 3. Используйте локализованные строки

**Вместо:**
```dart
Text('Настройки')
```

**Используйте:**
```dart
Text(l10n.settings)
```

## 🔄 Обновление экранов

### Home Screen

Замените хардкод строки:

```dart
// Было:
const Text('Tutas Ai')
const Text('Сканировать QR-код')
const Text('Последние инспекции')
const Text('Синхронизация...')
const Text('Онлайн')
const Text('Офлайн')
const Text('Нет сохраненных дефектов')
const Text('Требуют синхронизации')
const Text('Ошибка синхронизации')
const Text('Сегодня')
const Text('Вчера')
const Text('На этой неделе')
const Text('Ранее')
const Text('Труба: ${defect.pipeId}')
const Text('Ожидает')
const Text('Синхр.')
const Text('Ошибка')
const Text('Конфликт')

// Стало:
final l10n = AppLocalizations.of(context)!;
Text(l10n.appName)
Text(l10n.scanQrCode)
Text(l10n.recentInspections)
Text(l10n.synchronizing)
Text(l10n.online)
Text(l10n.offline)
Text(l10n.noSavedDefects)
Text(l10n.requiresSync)
Text(l10n.syncError)
Text(l10n.today)
Text(l10n.yesterday)
Text(l10n.thisWeek)
Text(l10n.earlier)
Text('${l10n.pipe}: ${defect.pipeId}')
Text(l10n.waiting)
Text(l10n.synced)
Text(l10n.syncErrorShort)
Text(l10n.conflict)
```

### Dashboard Screen

```dart
// Было:
const Text('Tutas Safe')
const Text('Operational Overview')
const Text('Integrity Index')
const Text('Compliance')
const Text('100% - ALL REGULATIONS MET')
const Text('Recent Tasks')
const Text('View All')
const Text('Network Map')
const Text('View Map')
const Text('No Tasks')
const Text('All tasks are completed. Great job!')
const Text('Loading error')
const Text('Open Risks')
const Text('Critical')
const Text('Low')

// Стало:
final l10n = AppLocalizations.of(context)!;
Text(l10n.dashboardTitle)
Text(l10n.operationalOverview)
Text(l10n.integrityIndex)
Text(l10n.compliance)
Text(l10n.allRegulationsMet)
Text(l10n.recentTasks)
Text(l10n.viewAll)
Text(l10n.networkMap)
Text(l10n.viewMap)
Text(l10n.noTasks)
Text(l10n.noTasksDescription)
Text(l10n.loadingError)
Text(l10n.openRisks)
Text(l10n.critical)
Text(l10n.low)
```

### Settings Screen

```dart
// Было:
const Text('Settings')
const Text('Account')
const Text('Profile')
const Text('Manage your account')
const Text('Security')
const Text('Password, biometrics')
const Text('Preferences')
const Text('Notifications')
const Text('Alert preferences')
const Text('Language')
const Text('About')
const Text('App Version')
const Text('Sign Out')
const Text('Выход')
const Text('Вы уверены, что хотите выйти?')
const Text('Отмена')
const Text('Выйти')
const Text('Выберите язык / Choose Language / Тілді таңдаңыз')
const Text('English')
const Text('Русский')
const Text('Қазақша')

// Стало:
final l10n = AppLocalizations.of(context)!;
Text(l10n.settings)
Text(l10n.account)
Text(l10n.profile)
Text(l10n.manageAccount)
Text(l10n.security)
Text(l10n.passwordBiometrics)
Text(l10n.preferences)
Text(l10n.notifications)
Text(l10n.alertPreferences)
Text(l10n.language)
Text(l10n.about)
Text(l10n.appVersion)
Text(l10n.signOut)
Text(l10n.signOutTitle)
Text(l10n.signOutMessage)
Text(l10n.cancel)
Text(l10n.signOutConfirm)
Text(l10n.chooseLanguage)
Text(l10n.english)
Text(l10n.russian)
Text(l10n.kazakh)
```

### Main.dart (Error messages)

```dart
// Было:
Text('Произошла ошибка')
Text('Приложение столкнулось с проблемой.\nПопытка восстановления...')
Text('Попробовать снова')
Text('Восстановление приложения')
Text('Ошибка отображения')
Text('Попытка восстановления...')

// Стало:
final l10n = AppLocalizations.of(context)!;
Text(l10n.errorOccurred)
Text(l10n.appEncounteredError)
Text(l10n.tryAgain)
Text(l10n.appRecovery)
Text(l10n.displayError)
Text(l10n.attemptingRecovery)
```

## 📋 Доступные строки локализации

Все доступные строки находятся в `AppLocalizations`. Полный список:

### Scanner Screen
- `scannerTitle`, `pointCameraAtQrCode`, `scanned`, `cameraAccess`, `cameraAccessRequired`, `howToEnablePermission`, `enablePermissionSteps`, `checkAgain`, `openSettings`, `checkingPermissions`, `initializingCamera`, `retry`, `cameraRestricted`, `failedToStartCamera`

### Home Screen
- `appName`, `scanQrCode`, `recentInspections`, `synchronizing`, `online`, `offline`, `noSavedDefects`, `error`, `requiresSync`, `syncError`, `today`, `yesterday`, `thisWeek`, `earlier`, `pipe`, `waiting`, `synced`, `syncErrorShort`, `conflict`, `unknown`

### Dashboard Screen
- `dashboardTitle`, `operationalOverview`, `integrityIndex`, `compliance`, `allRegulationsMet`, `recentTasks`, `viewAll`, `networkMap`, `viewMap`, `noTasks`, `noTasksDescription`, `loadingError`, `openRisks`, `critical`, `low`

### Settings Screen
- `settings`, `account`, `profile`, `manageAccount`, `security`, `passwordBiometrics`, `preferences`, `notifications`, `alertPreferences`, `language`, `about`, `appVersion`, `signOut`, `signOutTitle`, `signOutMessage`, `cancel`, `signOutConfirm`, `chooseLanguage`, `english`, `russian`, `kazakh`

### Scanner Screen (improved)
- `pipeInfo`, `qrCode`, `manufacturer`, `material`, `diameter`, `wallThickness`, `length`, `status`, `riskScore`, `predictedLifetime`, `years`, `close`, `details`, `loadingData`, `pipeNotFound`, `dataLoadError`, `connectionError`, `ok`

### Error messages
- `errorOccurred`, `appEncounteredError`, `tryAgain`, `appRecovery`, `displayError`, `attemptingRecovery`

## 🚀 Тестирование

1. Запустите приложение
2. Перейдите в Настройки → Язык
3. Выберите язык (English, Русский, Қазақша)
4. Проверьте, что все строки изменились

## 📝 Примечания

- Все строки уже переведены на 3 языка
- Локализация сохраняется в SharedPreferences
- При перезапуске приложения выбранный язык сохраняется
- Если строка не найдена, используется английская версия или ключ
