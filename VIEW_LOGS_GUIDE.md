# Как просмотреть логи приложения на iOS

## Способ 1: Flutter с verbose режимом
```bash
# Запустить на симуляторе с подробными логами
flutter run -d <device-id> --verbose

# Или просто на симуляторе iPhone
flutter run -d ios --verbose
```

## Способ 2: Xcode Console
1. Откройте проект в Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```
2. Запустите приложение из Xcode (⌘+R)
3. Логи будут видны в нижней панели (Console)

## Способ 3: Console.app (macOS)
1. Откройте приложение **Console** (встроенное в macOS)
2. В левой панели выберите ваш симулятор iPhone
3. Фильтруйте логи по "smile_ai" или "Runner"
4. Все системные логи и логи приложения будут видны

## Способ 4: Через xcrun simctl (симулятор)
```bash
# Получить ID симулятора
xcrun simctl list devices

# Просмотреть логи симулятора в реальном времени
xcrun simctl spawn booted log stream --level=debug --predicate 'processImagePath contains "smile_ai"'
```

## Способ 5: Фильтрация логов Flutter
```bash
# Запустить с фильтрацией по ключевым словам
flutter run -d ios 2>&1 | grep -E "(Error|Exception|Crash|Permission|Microphone|Speech)"
```

## Полезные команды для отладки

### Просмотр логов устройства iOS (физическое устройство)
```bash
# Установить приложение на устройство
flutter run -d <device-id>

# Затем в другом терминале:
idevicesyslog -u <device-udid>
```

### Очистка и пересборка
```bash
# Очистить кэш
flutter clean

# Переустановить зависимости
flutter pub get

# Для iOS также:
cd ios && pod install && cd ..
```

### Просмотр логов только ошибок
```bash
flutter run -d ios 2>&1 | grep -i error
```

## Что искать в логах при проблеме с микрофоном:
- `Permission.microphone` - запросы разрешений
- `SpeechToText` - ошибки распознавания речи
- `AVAudioSession` - ошибки аудио сессии iOS
- `NSMicrophoneUsageDescription` - проверка наличия описания в Info.plist
- `MissingPluginException` - отсутствующие плагины
- `Crash` или `Exception` - любые краши

