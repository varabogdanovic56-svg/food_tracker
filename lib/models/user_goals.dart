class UserGoals {
  final int id;
  final double caloriesPerDay;
  final double proteinPerDay;
  final double carbsPerDay;
  final double fatPerDay;
  final int waterPerDayMl;
  final double? targetWeightKg;

  UserGoals({
    this.id = 1,
    this.caloriesPerDay = 2000,
    this.proteinPerDay = 100,
    this.carbsPerDay = 250,
    this.fatPerDay = 65,
    this.waterPerDayMl = 2000,
    this.targetWeightKg,
  });

  factory UserGoals.fromJson(Map<String, dynamic> json) {
    return UserGoals(
      id: json['id'] as int? ?? 1,
      caloriesPerDay: (json['caloriesPerDay'] as num?)?.toDouble() ?? 2000,
      proteinPerDay: (json['proteinPerDay'] as num?)?.toDouble() ?? 100,
      carbsPerDay: (json['carbsPerDay'] as num?)?.toDouble() ?? 250,
      fatPerDay: (json['fatPerDay'] as num?)?.toDouble() ?? 65,
      waterPerDayMl: json['waterPerDayMl'] as int? ?? 2000,
      targetWeightKg: (json['targetWeightKg'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'caloriesPerDay': caloriesPerDay,
      'proteinPerDay': proteinPerDay,
      'carbsPerDay': carbsPerDay,
      'fatPerDay': fatPerDay,
      'waterPerDayMl': waterPerDayMl,
      'targetWeightKg': targetWeightKg,
    };
  }

  UserGoals copyWith({
    int? id,
    double? caloriesPerDay,
    double? proteinPerDay,
    double? carbsPerDay,
    double? fatPerDay,
    int? waterPerDayMl,
    double? targetWeightKg,
  }) {
    return UserGoals(
      id: id ?? this.id,
      caloriesPerDay: caloriesPerDay ?? this.caloriesPerDay,
      proteinPerDay: proteinPerDay ?? this.proteinPerDay,
      carbsPerDay: carbsPerDay ?? this.carbsPerDay,
      fatPerDay: fatPerDay ?? this.fatPerDay,
      waterPerDayMl: waterPerDayMl ?? this.waterPerDayMl,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
    );
  }
}
