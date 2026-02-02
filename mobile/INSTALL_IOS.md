# 📱 Установка на iPhone

## Быстрая установка

### Вариант 1: Через Flutter (Рекомендуется)

```bash
cd mobile
flutter pub get
flutter run -d <device-id>
```

Чтобы узнать device-id:
```bash
flutter devices
```

### Вариант 2: Через Xcode

1. Откройте проект в Xcode:
   ```bash
   open mobile/ios/Runner.xcworkspace
   ```

2. В Xcode:
   - Выберите ваше устройство в верхней панели
   - Выберите вашу команду разработчика (Signing & Capabilities)
   - Нажмите ▶️ (Run) или `Cmd+R`

## Настройка для физического устройства

### 1. Настройте API URL

Отредактируйте `mobile/.env`:
```bash
# Для физического устройства используйте IP адрес вашего компьютера
API_BASE_URL=http://192.168.1.XXX:8000
API_KEY=dev-api-key-12345
```

**Важно:** 
- Замените `192.168.1.XXX` на реальный IP адрес вашего Mac
- Убедитесь, что iPhone и Mac в одной Wi-Fi сети
- Убедитесь, что backend запущен и доступен по этому IP

### 2. Узнайте IP адрес Mac

```bash
# macOS
ifconfig | grep "inet " | grep -v 127.0.0.1

# Или через System Preferences > Network
```

### 3. Проверьте доступность backend

На iPhone откройте Safari и перейдите:
```
http://YOUR_IP:8000/health
```

Должен вернуться JSON: `{"status": "healthy", "service": "backend-api"}`

## Решение проблем

### Ошибка "Could not build the application"

1. Очистите проект:
   ```bash
   cd mobile
   flutter clean
   flutter pub get
   ```

2. Обновите CocoaPods:
   ```bash
   cd mobile/ios
   pod deintegrate
   pod install
   ```

### Ошибка подписи кода (Code Signing)

1. Откройте `mobile/ios/Runner.xcworkspace` в Xcode
2. Выберите проект Runner в навигаторе
3. Перейдите в "Signing & Capabilities"
4. Выберите вашу команду разработчика
5. Xcode автоматически создаст provisioning profile

### Приложение не подключается к backend

1. Проверьте, что backend запущен:
   ```bash
   curl http://localhost:8000/health
   ```

2. Проверьте firewall на Mac:
   - System Preferences > Security & Privacy > Firewall
   - Убедитесь, что Python/uvicorn разрешен

3. Проверьте IP адрес в .env файле

4. Убедитесь, что iPhone и Mac в одной сети

### Ошибка "Trust Developer"

На iPhone:
1. Settings > General > VPN & Device Management
2. Найдите ваше приложение
3. Нажмите "Trust [Your Name]"
4. Подтвердите

## Проверка установки

После установки:

1. Откройте приложение на iPhone
2. Должен появиться экран логина
3. Войдите с учетными данными:
   - Email: `test@tutas.ai`
   - Password: `test123456`

Если backend не запущен, сначала:
```bash
# Запустите backend
cd backend
poetry run uvicorn app.main:app --reload --host 0.0.0.0
```

## Production сборка

Для создания IPA файла:

```bash
cd mobile
flutter build ipa
```

IPA файл будет в: `build/ios/ipa/tutas_ai_mobile.ipa`

Для установки через TestFlight или App Store Connect требуется:
- Apple Developer Account ($99/год)
- Правильная настройка сертификатов и provisioning profiles
