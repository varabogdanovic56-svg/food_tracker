# Food Tracker - Инструкция по сборке

## Что создано

### C# проект (FoodLogic.Core/)
- Модели данных: Product, Meal, MealEntry, WaterIntake, WeightRecord, DailyReport, WeeklyStats, UserGoals
- Сервисы: DatabaseService, ProductRepository, MealRepository, WaterRepository, WeightRepository, UserGoalsService, StatisticsService, NutritionCalculator
- FFI точка входа с JSON-RPC

### Flutter проект
- Модели (mirror C#)
- FoodDataService (вместо FFI - работает с in-memory хранилищем)
- Riverpod providers
- Экраны: Главная, Дневник, Статистика, Продукты, Настройки, Добавить еду
- Навигация через go_router
- Графики через fl_chart

---

## Запуск Flutter приложения

### 1. Установите зависимости
```bash
flutter pub get
```

### 2. Запустите на устройстве/эмуляторе
```bash
flutter run
```

Или соберите APK:
```bash
flutter build apk --debug
```

---

## Опционально: Компиляция C# в NativeAOT

Для полноценной работы с C# NativeAOT нужно:

### Требования
- .NET 9 SDK
- Для Android: Android NDK

### Сборка C# библиотеки

```bash
cd FoodLogic.Core

# Восстановить зависимости
dotnet restore

# Собрать для Android (требуется NDK)
dotnet publish -c Release -r android-arm64 --self-contained true -p:NativeLib=Shared
```

### Подключение к Flutter

Скомпилированная библиотека `libFoodLogic.Core.so` должна быть помещена в:
- Android: `android/app/src/main/jniLibs/arm64-v8a/`

**Примечание:** Приложение работает и без нативной библиотеки - используется in-memory хранилище (FoodDataService).

---

## Структура проекта

```
FoodTracker/
├── FoodLogic.Core/           # C# NativeAOT библиотека
│   ├── Models/               # Модели данных
│   ├── Services/             # Бизнес-логика
│   └── Interop/              # FFI точка входа
│
└── FlutterApp/               # Flutter UI
    ├── lib/
    │   ├── models/           # Dart модели
    │   ├── services/         # Data service
    │   ├── providers/         # Riverpod
    │   ├── screens/           # Экраны
    │   ├── widgets/           # Виджеты
    │   ├── navigation.dart    # Маршрутизация
    │   └── main.dart          # Точка входа
    └── android/               # Android настройки
```

## Функции приложения

1. **Дневник питания** - записывайте приёмы пищи (завтрак, обед, ужин, перекус)
2. **КБЖУ** - отслеживайте калории, белки, углеводы, жиры
3. **Вода** - учитывайте потребление воды
4. **Вес** - записывайте и отслеживайте вес
5. **Статистика** - графики за неделю
6. **Продукты** - база продуктов с возможностью добавления своих

---

## Технологии

- Flutter 3.41 с Material 3
- Riverpod - state management
- go_router - навигация
- fl_chart - графики
- (Опционально) .NET 9 NativeAOT + FFI
