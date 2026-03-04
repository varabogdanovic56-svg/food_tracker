class DailyStats {
  final DateTime date;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final int waterMl;
  final double? weightKg;

  DailyStats({
    required this.date,
    this.calories = 0,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
    this.waterMl = 0,
    this.weightKg,
  });

  factory DailyStats.fromJson(Map<String, dynamic> json) {
    return DailyStats(
      date: DateTime.parse(json['date'] as String),
      calories: (json['calories'] as num?)?.toDouble() ?? 0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0,
      waterMl: json['waterMl'] as int? ?? 0,
      weightKg: (json['weightKg'] as num?)?.toDouble(),
    );
  }
}

class WeeklyStats {
  final DateTime startDate;
  final DateTime endDate;
  final List<DailyStats> dailyStats;
  final double averageCalories;
  final double averageProtein;
  final double averageCarbs;
  final double averageFat;
  final double averageWaterMl;
  final int totalWaterMl;
  final double weightChange;
  final int daysTracked;

  WeeklyStats({
    required this.startDate,
    required this.endDate,
    this.dailyStats = const [],
    this.averageCalories = 0,
    this.averageProtein = 0,
    this.averageCarbs = 0,
    this.averageFat = 0,
    this.averageWaterMl = 0,
    this.totalWaterMl = 0,
    this.weightChange = 0,
    this.daysTracked = 0,
  });

  factory WeeklyStats.fromJson(Map<String, dynamic> json) {
    return WeeklyStats(
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      dailyStats:
          (json['dailyStats'] as List<dynamic>?)
              ?.map((e) => DailyStats.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      averageCalories: (json['averageCalories'] as num?)?.toDouble() ?? 0,
      averageProtein: (json['averageProtein'] as num?)?.toDouble() ?? 0,
      averageCarbs: (json['averageCarbs'] as num?)?.toDouble() ?? 0,
      averageFat: (json['averageFat'] as num?)?.toDouble() ?? 0,
      averageWaterMl: (json['averageWaterMl'] as num?)?.toDouble() ?? 0,
      totalWaterMl: json['totalWaterMl'] as int? ?? 0,
      weightChange: (json['weightChange'] as num?)?.toDouble() ?? 0,
      daysTracked: json['daysTracked'] as int? ?? 0,
    );
  }
}
