# 📱 Установка приложения на iPhone

## Способ 1: Через Xcode (Рекомендуется)

### Шаг 1: Откройте проект в Xcode

```bash
cd mobile
open ios/Runner.xcworkspace
```

**ВАЖНО:** Открывайте `.xcworkspace`, а не `.xcodeproj`!

### Шаг 2: Настройте подпись (Signing)

1. В Xcode выберите проект **Runner** в левой панели
2. Выберите таргет **Runner**
3. Перейдите на вкладку **Signing & Capabilities**
4. Выберите вашу команду разработчика (Team)
5. Убедитесь, что **Bundle Identifier** уникален (например: `com.yourname.tutasAiMobile`)

### Шаг 3: Выберите устройство

1. В верхней панели Xcode выберите ваше устройство **iPhone (Әділет)**
2. Убедитесь, что устройство разблокировано и доверено

### Шаг 4: Соберите и установите

1. Нажмите **▶️ Run** (или `Cmd+R`)
2. Если появится запрос на доверие - нажмите **Trust**
3. На iPhone: **Settings > General > VPN & Device Management** > Доверьте разработчику

### Шаг 5: Запустите приложение

После установки приложение появится на главном экране iPhone.

---

## Способ 2: Через Flutter CLI

### Предварительные требования

1. Убедитесь, что устройство подключено и доверено:
   ```bash
   flutter devices
   ```

2. Установите UTF-8 кодировку:
   ```bash
   export LANG=en_US.UTF-8
   export LC_ALL=en_US.UTF-8
   ```

### Установка

```bash
cd mobile

# Очистка и подготовка
flutter clean
flutter pub get
cd ios && pod install && cd ..

# Установка на устройство
flutter run -d "00008110-0008584C142A401E"
```

---

## Способ 3: Сборка IPA файла

Если нужно создать файл для установки:

```bash
cd mobile

# Сборка IPA
flutter build ipa

# Файл будет в:
# build/ios/ipa/tutas_ai_mobile.ipa
```

Затем установите через:
- **Xcode** (Window > Devices and Simulators > + > выберите IPA)
- **Apple Configurator 2**
- **TestFlight** (для бета-тестирования)

---

## 🔧 Решение проблем

### Проблема: "Command PhaseScriptExecution failed"

**Решение:**
```bash
cd mobile
./fix_ios_build.sh
```

### Проблема: "No signing certificate"

**Решение:**
1. Откройте Xcode
2. Xcode > Settings > Accounts
3. Добавьте ваш Apple ID
4. Выберите команду разработчика

### Проблема: "Device not trusted"

**Решение:**
1. На iPhone: **Settings > General > VPN & Device Management**
2. Найдите вашего разработчика
3. Нажмите **Trust**

### Проблема: "App installation failed"

**Решение:**
1. Убедитесь, что Bundle ID уникален
2. Проверьте, что устройство разблокировано
3. Перезапустите Xcode и попробуйте снова

---

## ✅ Проверка после установки

1. ✅ Приложение появилось на главном экране
2. ✅ Приложение запускается без ошибок
3. ✅ Можно войти: `test@tutas.ai` / `test123456`
4. ✅ Все функции работают

---

**Готово! Приложение установлено на iPhone!** 🎉
