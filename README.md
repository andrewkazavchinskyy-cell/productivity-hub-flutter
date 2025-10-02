# Productivity Hub - Flutter App

Персональное приложение для повышения продуктивности с интеграцией календаря, почты и AI-ассистента.

## 🚀 Возможности

- **📅 Умный календарь** - интеграция с Google Calendar
- **📧 Управление почтой** - синхронизация с Gmail, AI-анализ и категоризация писем
- **🤖 AI-ассистент** - автоматизация задач и планирование
- **⚙️ Настройки** - персонализация и безопасность

## 🏗️ Архитектура

- **Flutter** с Clean Architecture (MVVM)
- **BLoC** для управления состоянием
- **GoRouter** для навигации
- **Material Design 3** с темной/светлой темой
- **Google APIs** интеграция
- **OpenAI** для AI-функций

## 📱 Модули

- `calendar/` - Календарь и события
- `email/` - Почта и уведомления  
- `ai/` - AI-ассистент и чат
- `home/` - Главный экран
- `settings/` - Настройки приложения

## 🛠️ Технологии

- Flutter SDK ^3.5.0
- BLoC для state management
- Dio для HTTP запросов
- Hive для локального хранения
- Google Sign In для аутентификации
- Gmail API (чтение и управление статусом писем)
- OpenAI API для AI функций

## 📖 Документация

- [STRUCTURE.md](STRUCTURE.md) - Подробная структура проекта
- [GETTING_STARTED.md](GETTING_STARTED.md) - Руководство по началу работы

## ✉️ Интеграция Gmail API

- Авторизация реализована через `GoogleSignIn` с правами `gmail.readonly`, `gmail.metadata` и `gmail.modify`.
- `GmailApiProvider` предоставляет аутентифицированный клиент Gmail API и переиспользует сессию пользователя.
- `GmailRemoteDataSource` загружает письма из `INBOX`, подтягивая метаданные (`From`, `Subject`, `Date`) и поддерживает отметку писем как прочитанных.
- `EmailRepositoryImpl` конвертирует исключения уровня данных в `Failure`, обеспечивая предсказуемый контракт для доменного слоя.
- Use cases `GetRecentEmails` и `MarkEmailAsRead` служат точками входа для слоя представления.

## 🔧 Установка

```bash
flutter pub get
flutter run
```

## 📄 Лицензия

MIT License
