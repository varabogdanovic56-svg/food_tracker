import 'meal.dart';
import 'water_intake.dart';
import 'weight_record.dart';

class DailyReport {
  final DateTime date;
  final List<Meal> meals;
  final DailyWaterSummary? waterSummary;
  final WeightRecord? weightRecord;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final double caloriesGoal;
  final double proteinGoal;
  final double carbsGoal;
  final double fatGoal;
  final int waterGoalMl;

  DailyReport({
    required this.date,
    this.meals = const [],
    this.waterSummary,
    this.weightRecord,
    this.totalCalories = 0,
    this.totalProtein = 0,
    this.totalCarbs = 0,
    this.totalFat = 0,
    this.caloriesGoal = 2000,
    this.proteinGoal = 100,
    this.carbsGoal = 250,
    this.fatGoal = 65,
    this.waterGoalMl = 2000,
  });

  factory DailyReport.fromJson(Map<String, dynamic> json) {
    return DailyReport(
      date: DateTime.parse(json['date'] as String),
      meals:
          (json['meals'] as List<dynamic>?)
              ?.map((e) => Meal.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      waterSummary: json['waterSummary'] != null
          ? DailyWaterSummary.fromJson(
              json['waterSummary'] as Map<String, dynamic>,
            )
          : null,
      weightRecord: json['weightRecord'] != null
          ? WeightRecord.fromJson(json['weightRecord'] as Map<String, dynamic>)
          : null,
      totalCalories: (json['totalCalories'] as num?)?.toDouble() ?? 0,
      totalProtein: (json['totalProtein'] as num?)?.toDouble() ?? 0,
      totalCarbs: (json['totalCarbs'] as num?)?.toDouble() ?? 0,
      totalFat: (json['totalFat'] as num?)?.toDouble() ?? 0,
      caloriesGoal: (json['caloriesGoal'] as num?)?.toDouble() ?? 2000,
      proteinGoal: (json['proteinGoal'] as num?)?.toDouble() ?? 100,
      carbsGoal: (json['carbsGoal'] as num?)?.toDouble() ?? 250,
      fatGoal: (json['fatGoal'] as num?)?.toDouble() ?? 65,
      waterGoalMl: json['waterGoalMl'] as int? ?? 2000,
    );
  }

  double get caloriesProgress =>
      caloriesGoal > 0 ? (totalCalories / caloriesGoal).clamp(0.0, 1.5) : 0;
  double get proteinProgress =>
      proteinGoal > 0 ? (totalProtein / proteinGoal).clamp(0.0, 1.5) : 0;
  double get carbsProgress =>
      carbsGoal > 0 ? (totalCarbs / carbsGoal).clamp(0.0, 1.5) : 0;
  double get fatProgress =>
      fatGoal > 0 ? (totalFat / fatGoal).clamp(0.0, 1.5) : 0;
}
