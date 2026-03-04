class WaterIntake {
  final int id;
  final DateTime date;
  final int amountMl;
  final DateTime timestamp;

  WaterIntake({
    required this.id,
    required this.date,
    required this.amountMl,
    required this.timestamp,
  });

  factory WaterIntake.fromJson(Map<String, dynamic> json) {
    return WaterIntake(
      id: json['id'] as int,
      date: DateTime.parse(json['date'] as String),
      amountMl: json['amountMl'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'amountMl': amountMl,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class DailyWaterSummary {
  final DateTime date;
  final int totalMl;
  final int goalMl;
  final List<WaterIntake> entries;

  DailyWaterSummary({
    required this.date,
    required this.totalMl,
    required this.goalMl,
    this.entries = const [],
  });

  factory DailyWaterSummary.fromJson(Map<String, dynamic> json) {
    return DailyWaterSummary(
      date: DateTime.parse(json['date'] as String),
      totalMl: json['totalMl'] as int,
      goalMl: json['goalMl'] as int,
      entries:
          (json['entries'] as List<dynamic>?)
              ?.map((e) => WaterIntake.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  double get progress => goalMl > 0 ? (totalMl / goalMl).clamp(0.0, 1.0) : 0;
}
