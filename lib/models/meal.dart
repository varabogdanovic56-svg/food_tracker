import 'meal_entry.dart';

enum MealType {
  breakfast,
  lunch,
  dinner,
  snack;

  String get displayName {
    switch (this) {
      case MealType.breakfast:
        return 'Завтрак';
      case MealType.lunch:
        return 'Обед';
      case MealType.dinner:
        return 'Ужин';
      case MealType.snack:
        return 'Перекус';
    }
  }

  static MealType fromIndex(int index) {
    return MealType.values[index];
  }
}

class Meal {
  final int id;
  final DateTime date;
  final MealType mealType;
  final List<MealEntry> entries;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;

  Meal({
    required this.id,
    required this.date,
    required this.mealType,
    this.entries = const [],
    this.totalCalories = 0,
    this.totalProtein = 0,
    this.totalCarbs = 0,
    this.totalFat = 0,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'] as int,
      date: DateTime.parse(json['date'] as String),
      mealType: MealType.fromIndex(json['mealType'] as int),
      entries:
          (json['entries'] as List<dynamic>?)
              ?.map((e) => MealEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalCalories: (json['totalCalories'] as num?)?.toDouble() ?? 0,
      totalProtein: (json['totalProtein'] as num?)?.toDouble() ?? 0,
      totalCarbs: (json['totalCarbs'] as num?)?.toDouble() ?? 0,
      totalFat: (json['totalFat'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'mealType': mealType.index,
      'entries': entries.map((e) => e.toJson()).toList(),
      'totalCalories': totalCalories,
      'totalProtein': totalProtein,
      'totalCarbs': totalCarbs,
      'totalFat': totalFat,
    };
  }

  Meal copyWith({
    int? id,
    DateTime? date,
    MealType? mealType,
    List<MealEntry>? entries,
    double? totalCalories,
    double? totalProtein,
    double? totalCarbs,
    double? totalFat,
  }) {
    return Meal(
      id: id ?? this.id,
      date: date ?? this.date,
      mealType: mealType ?? this.mealType,
      entries: entries ?? this.entries,
      totalCalories: totalCalories ?? this.totalCalories,
      totalProtein: totalProtein ?? this.totalProtein,
      totalCarbs: totalCarbs ?? this.totalCarbs,
      totalFat: totalFat ?? this.totalFat,
    );
  }
}
