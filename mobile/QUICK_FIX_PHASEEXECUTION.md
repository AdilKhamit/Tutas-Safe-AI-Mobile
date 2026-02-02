# ⚡ Быстрое исправление PhaseScriptExecution

## Проблема
Ошибка `Command PhaseScriptExecution failed with a nonzero exit code` обычно связана с:
1. **Кодировкой UTF-8** - CocoaPods требует UTF-8
2. **Несинхронизированными зависимостями** - Podfile.lock не совпадает

## ✅ Решение (1 минута)

### Шаг 1: Установите UTF-8 кодировку

```bash
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
```

**Или добавьте в `~/.zshrc` (для постоянного решения):**
```bash
echo 'export LANG=en_US.UTF-8' >> ~/.zshrc
echo 'export LC_ALL=en_US.UTF-8' >> ~/.zshrc
source ~/.zshrc
```

### Шаг 2: Очистите и переустановите зависимости

```bash
cd mobile

# Очистка
flutter clean
rm -rf ios/Pods ios/Podfile.lock

# Переустановка
flutter pub get
cd ios
pod install
```

### Шаг 3: Соберите проект

```bash
cd mobile

# Через Flutter
flutter build ios --no-codesign

# Или через Xcode
open ios/Runner.xcworkspace
# Затем в Xcode: Cmd+B (Build)
```

## 🎯 Если все еще не работает

1. **Очистите Xcode кэш:**
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData/*
   ```

2. **Переустановите CocoaPods:**
   ```bash
   sudo gem install cocoapods
   pod repo update
   ```

3. **Используйте автоматический скрипт:**
   ```bash
   cd mobile
   ./fix_ios_build.sh
   ```

---

**После этих шагов ошибка должна быть исправлена!** ✅
