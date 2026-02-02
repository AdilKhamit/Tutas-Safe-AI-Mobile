# 🔧 Исправление ошибки "Command PhaseScriptExecution failed with a nonzero exit code"

## Причины ошибки

Эта ошибка обычно возникает из-за:
1. **Несинхронизированные CocoaPods зависимости** - Podfile.lock не совпадает с Manifest.lock
2. **Проблемы с Flutter кэшем** - устаревшие или поврежденные файлы
3. **Проблемы с путями** - неправильные пути к Flutter или CocoaPods
4. **Проблемы с правами доступа** - скрипты не имеют прав на выполнение

## 🔨 Быстрое исправление

### ⚠️ ВАЖНО: Проблема с кодировкой UTF-8

Если вы видите ошибку `Unicode Normalization not appropriate for ASCII-8BIT`, нужно установить UTF-8 кодировку:

```bash
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
```

Или добавить в `~/.zshrc` или `~/.bash_profile`:
```bash
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
```

### Способ 1: Автоматический скрипт (Рекомендуется)

```bash
cd mobile
./fix_ios_build.sh
```

### Способ 2: Ручное исправление

#### Шаг 1: Очистка проекта

```bash
cd mobile

# Очистка Flutter
flutter clean
rm -rf build/

# Очистка iOS
cd ios
rm -rf Pods/
rm -rf Podfile.lock
rm -rf .symlinks/
rm -rf Flutter/Flutter.framework
rm -rf Flutter/Flutter.podspec
```

#### Шаг 2: Переустановка зависимостей

```bash
# Установить UTF-8 кодировку (ВАЖНО!)
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Вернуться в корень mobile
cd ..

# Получить Flutter зависимости
flutter pub get

# Установить CocoaPods зависимости
cd ios
pod deintegrate
pod install --repo-update
```

#### Шаг 3: Очистка Xcode кэша

```bash
# Очистить DerivedData
rm -rf ~/Library/Developer/Xcode/DerivedData/*
```

#### Шаг 4: Проверка путей

Убедитесь, что Flutter правильно настроен:

```bash
flutter doctor -v
```

Должны быть:
- ✅ Flutter установлен
- ✅ Xcode установлен
- ✅ CocoaPods установлен

## 🔍 Диагностика конкретной ошибки

### Если ошибка в скрипте CocoaPods:

```bash
cd mobile/ios
pod install --verbose
```

### Если ошибка в Flutter скрипте:

Проверьте, что `FLUTTER_ROOT` правильно установлен:

```bash
echo $FLUTTER_ROOT
flutter --version
```

Если `FLUTTER_ROOT` не установлен, добавьте в `~/.zshrc` или `~/.bash_profile`:

```bash
export FLUTTER_ROOT=/opt/homebrew/share/flutter
export PATH="$FLUTTER_ROOT/bin:$PATH"
```

### Если ошибка в путях:

Проверьте файл `ios/Flutter/Generated.xcconfig`:

```bash
cat ios/Flutter/Generated.xcconfig
```

Должен содержать правильный путь к Flutter.

## 🚀 Сборка после исправления

### Через Xcode:

1. Откройте проект:
   ```bash
   cd mobile
   open ios/Runner.xcworkspace
   ```

2. В Xcode:
   - Выберите устройство или симулятор
   - Нажмите `Cmd+Shift+K` (Clean Build Folder)
   - Нажмите `Cmd+B` (Build) или `Cmd+R` (Run)

### Через Flutter CLI:

```bash
cd mobile

# Для симулятора
flutter run

# Для физического устройства
flutter run -d "00008110-0008584C142A401E"

# Для сборки
flutter build ios
```

## ⚠️ Частые проблемы и решения

### Проблема 1: "Podfile.lock out of sync"

**Решение:**
```bash
cd mobile/ios
pod install
```

### Проблема 2: "Flutter framework not found"

**Решение:**
```bash
cd mobile
flutter clean
flutter pub get
cd ios
pod install
```

### Проблема 3: "Permission denied"

**Решение:**
```bash
chmod +x mobile/ios/Flutter/flutter_export_environment.sh
chmod +x mobile/fix_ios_build.sh
```

### Проблема 4: "CocoaPods not installed"

**Решение:**
```bash
sudo gem install cocoapods
pod setup
```

## 📝 Проверка после исправления

1. ✅ `flutter doctor -v` - все должно быть ✅
2. ✅ `cd mobile/ios && pod install` - без ошибок
3. ✅ `flutter build ios` - успешная сборка
4. ✅ Открыть в Xcode и собрать - без ошибок

## 🆘 Если ничего не помогает

1. **Обновите Flutter:**
   ```bash
   flutter upgrade
   ```

2. **Обновите CocoaPods:**
   ```bash
   sudo gem install cocoapods
   pod repo update
   ```

3. **Переустановите Xcode Command Line Tools:**
   ```bash
   sudo xcode-select --reset
   xcode-select --install
   ```

4. **Очистите все кэши:**
   ```bash
   cd mobile
   flutter clean
   rm -rf build/
   rm -rf ios/Pods/
   rm -rf ios/Podfile.lock
   rm -rf ~/Library/Developer/Xcode/DerivedData/*
   flutter pub get
   cd ios && pod install
   ```

---

**После выполнения этих шагов ошибка должна быть исправлена!** ✅
