class MealEntry {
  final int id;
  final int mealId;
  final int productId;
  final String productName;
  final double grams;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final DateTime createdAt;

  MealEntry({
    required this.id,
    required this.mealId,
    required this.productId,
    required this.productName,
    required this.grams,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.createdAt,
  });

  factory MealEntry.fromJson(Map<String, dynamic> json) {
    return MealEntry(
      id: json['id'] as int,
      mealId: json['mealId'] as int,
      productId: json['productId'] as int,
      productName: json['productName'] as String,
      grams: (json['grams'] as num).toDouble(),
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mealId': mealId,
      'productId': productId,
      'productName': productName,
      'grams': grams,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  MealEntry copyWith({
    int? id,
    int? mealId,
    int? productId,
    String? productName,
    double? grams,
    double? calories,
    double? protein,
    double? carbs,
    double? fat,
    DateTime? createdAt,
  }) {
    return MealEntry(
      id: id ?? this.id,
      mealId: mealId ?? this.mealId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      grams: grams ?? this.grams,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
