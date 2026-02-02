# 🚀 Быстрая установка на iPhone

## Способ 1: Через Xcode (Самый простой) ⭐

1. **Проект уже открыт в Xcode** (если нет, выполните):
   ```bash
   cd mobile
   open ios/Runner.xcworkspace
   ```

2. **В Xcode:**
   - В верхней панели выберите ваше устройство "iPhone (Әділет)"
   - Если устройства нет в списке, подключите iPhone через USB
   - Нажмите ▶️ (Run) или `Cmd+R`

3. **На iPhone:**
   - Если появится предупреждение "Untrusted Developer":
     - Settings > General > VPN & Device Management
     - Найдите ваше имя/команду разработчика
     - Нажмите "Trust [Your Name]"

4. **Готово!** Приложение установлено и запущено

## Способ 2: Через терминал

```bash
cd mobile
./install_ios.sh
```

Или вручную:
```bash
cd mobile
flutter pub get
flutter run -d "00008110-0008584C142A401E"
```

## ⚙️ Настройка API

Перед первым запуском убедитесь, что `mobile/.env` настроен правильно:

```bash
# Для физического устройства используйте IP адрес Mac
API_BASE_URL=http://192.168.1.XXX:8000
API_KEY=dev-api-key-12345
```

**Как узнать IP адрес Mac:**
```bash
ifconfig | grep "inet " | grep -v 127.0.0.1
```

**Важно:**
- iPhone и Mac должны быть в одной Wi-Fi сети
- Backend должен быть запущен и доступен по указанному IP
- Проверьте доступность: откройте Safari на iPhone и перейдите на `http://YOUR_IP:8000/health`

## 🔐 Первый вход

После установки откройте приложение и войдите:
- **Email:** `test@tutas.ai`
- **Password:** `test123456`

Если пользователь еще не создан, сначала зарегистрируйте его:
```bash
python3 scripts/register_user.py test@tutas.ai test123456 "Test User"
```

## ❌ Решение проблем

### "Could not build"
```bash
cd mobile
flutter clean
flutter pub get
cd ios
pod install
```

### "Untrusted Developer"
На iPhone: Settings > General > VPN & Device Management > Trust

### Не подключается к backend
1. Проверьте IP в `.env`
2. Убедитесь, что backend запущен: `cd backend && poetry run uvicorn app.main:app --reload --host 0.0.0.0`
3. Проверьте firewall на Mac

---

**Готово!** Приложение должно работать на вашем iPhone! 🎉
