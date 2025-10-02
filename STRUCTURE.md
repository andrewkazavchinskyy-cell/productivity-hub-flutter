# Структура проекта Productivity Hub

## 📁 Общая структура

```
lib/
├── core/                           # Базовая функциональность
│   ├── constants/                  # Константы приложения
│   │   └── api_constants.dart     # API endpoints и конфигурация
│   ├── di/                        # Dependency Injection
│   │   └── injection.dart         # Настройка GetIt
│   ├── errors/                    # Обработка ошибок
│   │   └── failures.dart          # Классы ошибок
│   ├── navigation/                # Навигация
│   │   └── app_router.dart        # GoRouter конфигурация
│   ├── network/                   # Сетевое взаимодействие
│   │   └── dio_client.dart        # Dio клиент
│   ├── theme/                     # Темы приложения
│   │   └── app_theme.dart         # Material Theme 3
│   └── utils/                     # Утилиты
│       └── logger.dart            # Логирование
│
├── features/                      # Модули приложения
│   ├── calendar/                  # Модуль календаря
│   │   ├── data/
│   │   │   ├── datasources/       # Источники данных (API, Local)
│   │   │   ├── models/            # Data models с JSON
│   │   │   └── repositories/      # Реализация репозиториев
│   │   ├── domain/
│   │   │   ├── entities/          # Бизнес-сущности
│   │   │   │   └── event.dart    # Событие календаря
│   │   │   ├── repositories/      # Интерфейсы репозиториев
│   │   │   └── usecases/          # Бизнес-логика
│   │   └── presentation/
│   │       ├── bloc/              # State management (BLoC)
│   │       ├── pages/             # Экраны
│   │       │   └── calendar_page.dart
│   │       └── widgets/           # UI компоненты
│   │
│   ├── email/                     # Модуль почты
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── email.dart    # Email сущность
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── bloc/
│   │       ├── pages/
│   │       │   └── email_page.dart
│   │       └── widgets/
│   │
│   ├── ai/                        # AI-ассистент
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── chat_message.dart
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── bloc/
│   │       ├── pages/
│   │       │   └── ai_chat_page.dart
│   │       └── widgets/
│   │
│   ├── home/                      # Главный экран
│   │   └── presentation/
│   │       ├── bloc/
│   │       ├── pages/
│   │       │   └── home_page.dart
│   │       └── widgets/
│   │
│   └── settings/                  # Настройки
│       ├── data/
│       │   ├── datasources/
│       │   ├── models/
│       │   └── repositories/
│       ├── domain/
│       │   ├── entities/
│       │   ├── repositories/
│       │   └── usecases/
│       └── presentation/
│           ├── bloc/
│           ├── pages/
│           │   └── settings_page.dart
│           └── widgets/
│
├── shared/                        # Общие компоненты
│   ├── models/                    # Общие модели данных
│   └── widgets/                   # Переиспользуемые виджеты
│       └── bottom_nav_bar.dart
│
└── main.dart                      # Точка входа

assets/                            # Ресурсы
├── images/                        # Изображения
├── icons/                         # Иконки
└── animations/                    # Lottie анимации
```

## 🏗️ Архитектура

Проект следует **Clean Architecture** принципам с разделением на слои:

### 1. Data Layer (Слой данных)
- **Datasources**: Взаимодействие с API и локальным хранилищем
  - `Remote`: Google Calendar API, Gmail API, OpenAI API
  - `Local`: Hive, SharedPreferences, SecureStorage
- **Models**: Data Transfer Objects с JSON сериализацией
- **Repositories**: Реализация интерфейсов из Domain слоя

### 2. Domain Layer (Слой бизнес-логики)
- **Entities**: Чистые бизнес-объекты без зависимостей
- **Repositories**: Абстрактные интерфейсы
- **UseCases**: Бизнес-логика приложения (один use case = одно действие)

### 3. Presentation Layer (Слой представления)
- **BLoC**: State management с помощью flutter_bloc
- **Pages**: Экраны приложения
- **Widgets**: UI компоненты

## 🔧 Технологический стек

### State Management
- **flutter_bloc**: Управление состоянием
- **rxdart**: Реактивное программирование

### Dependency Injection
- **get_it**: Service locator
- **injectable**: Генерация кода для DI

### Navigation
- **go_router**: Декларативная маршрутизация

### Network
- **dio**: HTTP клиент
- **retrofit**: REST API генератор
- **googleapis**: Google APIs
- **google_sign_in**: Google аутентификация

### Local Storage
- **hive**: NoSQL база данных
- **shared_preferences**: Key-value хранилище
- **flutter_secure_storage**: Безопасное хранилище

### UI/UX
- **Material Design 3**: Современный дизайн
- **flutter_svg**: SVG иконки
- **lottie**: Анимации
- **cached_network_image**: Кэширование изображений

### AI Integration
- **langchain**: AI workflows
- **langchain_openai**: OpenAI интеграция

### Code Generation
- **freezed**: Immutable модели
- **json_serializable**: JSON сериализация
- **build_runner**: Генератор кода

## 📋 Основные модули

### 📅 Calendar Module
**Функции:**
- Интеграция с Google Calendar
- Создание/редактирование/удаление событий
- Множественные виды (день, неделя, месяц)
- Поиск свободного времени
- Уведомления о событиях

**Entities:**
- `Event`: Событие календаря

### 📧 Email Module
**Функции:**
- Интеграция с Gmail API
- AI-категоризация писем
- Быстрые действия (ответ, архив, задача)
- Умные сводки писем

**Entities:**
- `Email`: Письмо с метаданными
- `EmailCategory`: Категории (Important, Waiting, Info)

### 🤖 AI Assistant Module
**Функции:**
- Интеллектуальный чат
- Автоматизация задач
- Быстрые команды
- Контекстная помощь

**Entities:**
- `ChatMessage`: Сообщение в чате
- `MessageRole`: Роль (User, Assistant, System)

### 🏠 Home Module
**Функции:**
- Обзор дня
- Быстрые действия
- Статистика продуктивности
- Навигация по модулям

### ⚙️ Settings Module
**Функции:**
- Управление темой
- Подключение аккаунтов
- Настройка уведомлений
- Персонализация

## 🚀 Начало работы

### Установка зависимостей
```bash
flutter pub get
```

### Генерация кода
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Запуск приложения
```bash
flutter run
```

## 📝 Code Style

- **Clean Code**: Чистый и читаемый код
- **SOLID принципы**: Модульная архитектура
- **DRY**: Don't Repeat Yourself
- **Immutability**: Использование Freezed для immutable классов
- **Type Safety**: Строгая типизация

## 🔐 Безопасность

- Токены хранятся в `flutter_secure_storage`
- API ключи не в коде (используйте .env)
- Минимальные разрешения
- Шифрование чувствительных данных

## 📈 Дальнейшее развитие

### TODO:
- [ ] Реализация Calendar API integration
- [ ] Реализация Gmail API integration
- [ ] Реализация AI chat с OpenAI
- [ ] Система задач и напоминаний
- [ ] Офлайн режим
- [ ] Unit и Integration тесты
- [ ] CI/CD pipeline

---

**Productivity Hub** - Clean Architecture Flutter App