import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../services/database_service.dart';

final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

final dailyReportProvider = FutureProvider.family<DailyReport, DateTime>((
  ref,
  date,
) async {
  final db = DatabaseService.instance;
  final goals = await db.getGoals();
  final meals = await db.getMealsByDate(date);
  final waterSummary = await db.getWaterByDate(date);
  final weightRecord = await db.getWeightByDate(date);

  double totalCal = 0, totalProt = 0, totalCarbs = 0, totalFat = 0;
  for (final meal in meals) {
    totalCal += meal.totalCalories;
    totalProt += meal.totalProtein;
    totalCarbs += meal.totalCarbs;
    totalFat += meal.totalFat;
  }

  return DailyReport(
    date: date,
    meals: meals,
    waterSummary: waterSummary,
    weightRecord: weightRecord,
    totalCalories: totalCal,
    totalProtein: totalProt,
    totalCarbs: totalCarbs,
    totalFat: totalFat,
    caloriesGoal: goals.caloriesPerDay,
    proteinGoal: goals.proteinPerDay,
    carbsGoal: goals.carbsPerDay,
    fatGoal: goals.fatPerDay,
    waterGoalMl: goals.waterPerDayMl,
  );
});

final currentDayReportProvider = FutureProvider<DailyReport>((ref) async {
  final date = ref.watch(selectedDateProvider);
  final db = DatabaseService.instance;
  final goals = await db.getGoals();
  final meals = await db.getMealsByDate(date);
  final waterSummary = await db.getWaterByDate(date);
  final weightRecord = await db.getWeightByDate(date);

  double totalCal = 0, totalProt = 0, totalCarbs = 0, totalFat = 0;
  for (final meal in meals) {
    totalCal += meal.totalCalories;
    totalProt += meal.totalProtein;
    totalCarbs += meal.totalCarbs;
    totalFat += meal.totalFat;
  }

  return DailyReport(
    date: date,
    meals: meals,
    waterSummary: waterSummary,
    weightRecord: weightRecord,
    totalCalories: totalCal,
    totalProtein: totalProt,
    totalCarbs: totalCarbs,
    totalFat: totalFat,
    caloriesGoal: goals.caloriesPerDay,
    proteinGoal: goals.proteinPerDay,
    carbsGoal: goals.carbsPerDay,
    fatGoal: goals.fatPerDay,
    waterGoalMl: goals.waterPerDayMl,
  );
});

final productsProvider = FutureProvider<List<Product>>((ref) async {
  return DatabaseService.instance.getAllProducts();
});

final productSearchProvider = FutureProvider.family<List<Product>, String>((
  ref,
  query,
) async {
  if (query.isEmpty) {
    return DatabaseService.instance.getAllProducts();
  }
  return DatabaseService.instance.searchProducts(query);
});

final goalsProvider = StateNotifierProvider<GoalsNotifier, UserGoals>((ref) {
  return GoalsNotifier();
});

class GoalsNotifier extends StateNotifier<UserGoals> {
  GoalsNotifier() : super(UserGoals()) {
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    state = await DatabaseService.instance.getGoals();
  }

  Future<void> update(UserGoals goals) async {
    await DatabaseService.instance.updateGoals(goals);
    state = goals;
  }

  Future<void> updateCalories(double value) async {
    final newGoals = state.copyWith(caloriesPerDay: value);
    await update(newGoals);
  }

  Future<void> updateProtein(double value) async {
    final newGoals = state.copyWith(proteinPerDay: value);
    await update(newGoals);
  }

  Future<void> updateCarbs(double value) async {
    final newGoals = state.copyWith(carbsPerDay: value);
    await update(newGoals);
  }

  Future<void> updateFat(double value) async {
    final newGoals = state.copyWith(fatPerDay: value);
    await update(newGoals);
  }

  Future<void> updateWater(int value) async {
    final newGoals = state.copyWith(waterPerDayMl: value);
    await update(newGoals);
  }
}

final weightHistoryProvider = FutureProvider.family<List<WeightRecord>, int>((
  ref,
  days,
) async {
  return DatabaseService.instance.getWeightHistory(days);
});

final weeklyStatsProvider = FutureProvider.family<WeeklyStats, DateTime>((
  ref,
  endDate,
) async {
  final db = DatabaseService.instance;
  final startDate = endDate.subtract(const Duration(days: 6));
  final dailyStats = <DailyStats>[];
  double totalCal = 0, totalProt = 0, totalCarbs = 0, totalFat = 0;
  int totalWater = 0;
  double? firstWeight, lastWeight;

  for (int i = 0; i <= 6; i++) {
    final date = endDate.subtract(Duration(days: 6 - i));
    final meals = await db.getMealsByDate(date);
    final water = await db.getWaterByDate(date);
    final weight = await db.getWeightByDate(date);

    double cal = 0, prot = 0, carbs = 0, fat = 0;
    for (final m in meals) {
      cal += m.totalCalories;
      prot += m.totalProtein;
      carbs += m.totalCarbs;
      fat += m.totalFat;
    }

    dailyStats.add(
      DailyStats(
        date: date,
        calories: cal,
        protein: prot,
        carbs: carbs,
        fat: fat,
        waterMl: water.totalMl,
        weightKg: weight?.weightKg,
      ),
    );

    totalCal += cal;
    totalProt += prot;
    totalCarbs += carbs;
    totalFat += fat;
    totalWater += water.totalMl;

    if (weight != null) {
      firstWeight ??= weight.weightKg;
      lastWeight = weight.weightKg;
    }
  }

  final daysWithData = dailyStats.where((d) => d.calories > 0).length;

  return WeeklyStats(
    startDate: startDate,
    endDate: endDate,
    dailyStats: dailyStats,
    averageCalories: daysWithData > 0 ? totalCal / daysWithData : 0,
    averageProtein: daysWithData > 0 ? totalProt / daysWithData : 0,
    averageCarbs: daysWithData > 0 ? totalCarbs / daysWithData : 0,
    averageFat: daysWithData > 0 ? totalFat / daysWithData : 0,
    averageWaterMl: daysWithData > 0 ? totalWater / daysWithData : 0,
    totalWaterMl: totalWater,
    weightChange: (firstWeight != null && lastWeight != null)
        ? lastWeight - firstWeight
        : 0,
    daysTracked: daysWithData,
  );
});

final currentWeekStatsProvider = FutureProvider<WeeklyStats>((ref) async {
  final endDate = DateTime.now();
  final db = DatabaseService.instance;
  final startDate = endDate.subtract(const Duration(days: 6));
  final dailyStats = <DailyStats>[];
  double totalCal = 0, totalProt = 0, totalCarbs = 0, totalFat = 0;
  int totalWater = 0;
  double? firstWeight, lastWeight;

  for (int i = 0; i <= 6; i++) {
    final date = endDate.subtract(Duration(days: 6 - i));
    final meals = await db.getMealsByDate(date);
    final water = await db.getWaterByDate(date);
    final weight = await db.getWeightByDate(date);

    double cal = 0, prot = 0, carbs = 0, fat = 0;
    for (final m in meals) {
      cal += m.totalCalories;
      prot += m.totalProtein;
      carbs += m.totalCarbs;
      fat += m.totalFat;
    }

    dailyStats.add(
      DailyStats(
        date: date,
        calories: cal,
        protein: prot,
        carbs: carbs,
        fat: fat,
        waterMl: water.totalMl,
        weightKg: weight?.weightKg,
      ),
    );

    totalCal += cal;
    totalProt += prot;
    totalCarbs += carbs;
    totalFat += fat;
    totalWater += water.totalMl;

    if (weight != null) {
      firstWeight ??= weight.weightKg;
      lastWeight = weight.weightKg;
    }
  }

  final daysWithData = dailyStats.where((d) => d.calories > 0).length;

  return WeeklyStats(
    startDate: startDate,
    endDate: endDate,
    dailyStats: dailyStats,
    averageCalories: daysWithData > 0 ? totalCal / daysWithData : 0,
    averageProtein: daysWithData > 0 ? totalProt / daysWithData : 0,
    averageCarbs: daysWithData > 0 ? totalCarbs / daysWithData : 0,
    averageFat: daysWithData > 0 ? totalFat / daysWithData : 0,
    averageWaterMl: daysWithData > 0 ? totalWater / daysWithData : 0,
    totalWaterMl: totalWater,
    weightChange: (firstWeight != null && lastWeight != null)
        ? lastWeight - firstWeight
        : 0,
    daysTracked: daysWithData,
  );
});

class FoodService {
  Future<DailyReport> getDailyReport(DateTime date) async {
    final db = DatabaseService.instance;
    final goals = await db.getGoals();
    final meals = await db.getMealsByDate(date);
    final waterSummary = await db.getWaterByDate(date);
    final weightRecord = await db.getWeightByDate(date);

    double totalCal = 0, totalProt = 0, totalCarbs = 0, totalFat = 0;
    for (final meal in meals) {
      totalCal += meal.totalCalories;
      totalProt += meal.totalProtein;
      totalCarbs += meal.totalCarbs;
      totalFat += meal.totalFat;
    }

    return DailyReport(
      date: date,
      meals: meals,
      waterSummary: waterSummary,
      weightRecord: weightRecord,
      totalCalories: totalCal,
      totalProtein: totalProt,
      totalCarbs: totalCarbs,
      totalFat: totalFat,
      caloriesGoal: goals.caloriesPerDay,
      proteinGoal: goals.proteinPerDay,
      carbsGoal: goals.carbsPerDay,
      fatGoal: goals.fatPerDay,
      waterGoalMl: goals.waterPerDayMl,
    );
  }

  Future<List<Product>> getAllProducts() =>
      DatabaseService.instance.getAllProducts();
  Future<List<Product>> searchProducts(String query) =>
      DatabaseService.instance.searchProducts(query);
  Future<Product?> getProductById(int id) =>
      DatabaseService.instance.getProductById(id);
  Future<int> insertProduct(Product product) =>
      DatabaseService.instance.insertProduct(product);

  Future<Meal> getOrCreateMeal(DateTime date, MealType mealType) =>
      DatabaseService.instance.getOrCreateMeal(date, mealType);

  Future<int> addMealEntry(int mealId, Product product, double grams) async {
    final multiplier = grams / 100.0;
    final entry = MealEntry(
      id: 0,
      mealId: mealId,
      productId: product.id,
      productName: product.name,
      grams: grams,
      calories: product.caloriesPer100g * multiplier,
      protein: product.proteinPer100g * multiplier,
      carbs: product.carbsPer100g * multiplier,
      fat: product.fatPer100g * multiplier,
      createdAt: DateTime.now(),
    );
    return DatabaseService.instance.insertMealEntry(entry);
  }

  Future<void> deleteMealEntry(int entryId) =>
      DatabaseService.instance.deleteMealEntry(entryId);

  Future<int> addWaterIntake(DateTime date, int amountMl) =>
      DatabaseService.instance.insertWaterIntake(date, amountMl);
  Future<void> deleteWaterIntake(int id) =>
      DatabaseService.instance.deleteWaterIntake(id);

  Future<WeightRecord?> getWeightByDate(DateTime date) =>
      DatabaseService.instance.getWeightByDate(date);
  Future<List<WeightRecord>> getWeightHistory(int days) =>
      DatabaseService.instance.getWeightHistory(days);
  Future<int> addWeight(DateTime date, double weightKg, String? note) =>
      DatabaseService.instance.insertWeight(date, weightKg, note);
  Future<void> deleteWeight(int id) =>
      DatabaseService.instance.deleteWeight(id);

  Future<UserGoals> getGoals() => DatabaseService.instance.getGoals();
  Future<void> updateGoals(UserGoals goals) =>
      DatabaseService.instance.updateGoals(goals);

  Map<String, dynamic> calculateEntry(Product product, double grams) {
    final multiplier = grams / 100.0;
    return {
      'productId': product.id,
      'productName': product.name,
      'grams': grams,
      'calories': product.caloriesPer100g * multiplier,
      'protein': product.proteinPer100g * multiplier,
      'carbs': product.carbsPer100g * multiplier,
      'fat': product.fatPer100g * multiplier,
    };
  }
}

final foodServiceProvider = Provider<FoodService>((ref) => FoodService());
