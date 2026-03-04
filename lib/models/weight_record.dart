class WeightRecord {
  final int id;
  final double weightKg;
  final DateTime date;
  final String? note;
  final DateTime createdAt;

  WeightRecord({
    required this.id,
    required this.weightKg,
    required this.date,
    this.note,
    required this.createdAt,
  });

  factory WeightRecord.fromJson(Map<String, dynamic> json) {
    return WeightRecord(
      id: json['id'] as int,
      weightKg: (json['weightKg'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'weightKg': weightKg,
      'date': date.toIso8601String(),
      'note': note,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  WeightRecord copyWith({
    int? id,
    double? weightKg,
    DateTime? date,
    String? note,
    DateTime? createdAt,
  }) {
    return WeightRecord(
      id: id ?? this.id,
      weightKg: weightKg ?? this.weightKg,
      date: date ?? this.date,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
