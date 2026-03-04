import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/models.dart';

class DatabaseService {
  static DatabaseService? _instance;
  static Database? _database;

  static DatabaseService get instance {
    _instance ??= DatabaseService._();
    return _instance!;
  }

  DatabaseService._();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'food_tracker.db');
    return openDatabase(path, version: 1, onCreate: _createTables);
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE Products (
        Id INTEGER PRIMARY KEY AUTOINCREMENT,
        Name TEXT NOT NULL,
        CaloriesPer100g REAL NOT NULL,
        ProteinPer100g REAL NOT NULL,
        CarbsPer100g REAL NOT NULL,
        FatPer100g REAL NOT NULL,
        DefaultGrams REAL DEFAULT 100,
        Category TEXT,
        IsCustom INTEGER DEFAULT 0,
        CreatedAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE Meals (
        Id INTEGER PRIMARY KEY AUTOINCREMENT,
        Date TEXT NOT NULL,
        MealType INTEGER NOT NULL,
        TotalCalories REAL DEFAULT 0,
        TotalProtein REAL DEFAULT 0,
        TotalCarbs REAL DEFAULT 0,
        TotalFat REAL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE MealEntries (
        Id INTEGER PRIMARY KEY AUTOINCREMENT,
        MealId INTEGER NOT NULL,
        ProductId INTEGER NOT NULL,
        ProductName TEXT NOT NULL,
        Grams REAL NOT NULL,
        Calories REAL NOT NULL,
        Protein REAL NOT NULL,
        Carbs REAL NOT NULL,
        Fat REAL NOT NULL,
        CreatedAt TEXT NOT NULL,
        FOREIGN KEY (MealId) REFERENCES Meals(Id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE WaterIntake (
        Id INTEGER PRIMARY KEY AUTOINCREMENT,
        Date TEXT NOT NULL,
        AmountMl INTEGER NOT NULL,
        Timestamp TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE WeightRecords (
        Id INTEGER PRIMARY KEY AUTOINCREMENT,
        WeightKg REAL NOT NULL,
        Date TEXT NOT NULL,
        Note TEXT,
        CreatedAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE UserGoals (
        Id INTEGER PRIMARY KEY,
        CaloriesPerDay REAL NOT NULL,
        ProteinPerDay REAL NOT NULL,
        CarbsPerDay REAL NOT NULL,
        FatPerDay REAL NOT NULL,
        WaterPerDayMl INTEGER NOT NULL,
        TargetWeightKg REAL
      )
    ''');

    await db.insert('UserGoals', {
      'Id': 1,
      'CaloriesPerDay': 2000.0,
      'ProteinPerDay': 100.0,
      'CarbsPerDay': 250.0,
      'FatPerDay': 65.0,
      'WaterPerDayMl': 2000,
    });

    await _seedDefaultProducts(db);
  }

  Future<void> _seedDefaultProducts(Database db) async {
    final products = [
      {
        'name': 'Яблоко',
        'caloriesPer100g': 52.0,
        'proteinPer100g': 0.3,
        'carbsPer100g': 14.0,
        'fatPer100g': 0.2,
        'category': 'Фрукты',
      },
      {
        'name': 'Банан',
        'caloriesPer100g': 89.0,
        'proteinPer100g': 1.1,
        'carbsPer100g': 23.0,
        'fatPer100g': 0.3,
        'category': 'Фрукты',
      },
      {
        'name': 'Куриная грудка',
        'caloriesPer100g': 165.0,
        'proteinPer100g': 31.0,
        'carbsPer100g': 0.0,
        'fatPer100g': 3.6,
        'category': 'Мясо',
      },
      {
        'name': 'Рис отварной',
        'caloriesPer100g': 130.0,
        'proteinPer100g': 2.7,
        'carbsPer100g': 28.0,
        'fatPer100g': 0.3,
        'category': 'Крупы',
      },
      {
        'name': 'Яйцо куриное',
        'caloriesPer100g': 155.0,
        'proteinPer100g': 13.0,
        'carbsPer100g': 1.1,
        'fatPer100g': 11.0,
        'category': 'Яйца',
      },
      {
        'name': 'Молоко 3.2%',
        'caloriesPer100g': 61.0,
        'proteinPer100g': 3.2,
        'carbsPer100g': 4.8,
        'fatPer100g': 3.3,
        'category': 'Молочные',
      },
      {
        'name': 'Творог 5%',
        'caloriesPer100g': 121.0,
        'proteinPer100g': 17.0,
        'carbsPer100g': 3.6,
        'fatPer100g': 5.0,
        'category': 'Молочные',
      },
      {
        'name': 'Хлеб пшеничный',
        'caloriesPer100g': 265.0,
        'proteinPer100g': 8.0,
        'carbsPer100g': 49.0,
        'fatPer100g': 3.2,
        'category': 'Выпечка',
      },
      {
        'name': 'Картофель',
        'caloriesPer100g': 77.0,
        'proteinPer100g': 2.0,
        'carbsPer100g': 17.0,
        'fatPer100g': 0.1,
        'category': 'Овощи',
      },
      {
        'name': 'Огурец',
        'caloriesPer100g': 15.0,
        'proteinPer100g': 0.7,
        'carbsPer100g': 3.6,
        'fatPer100g': 0.1,
        'category': 'Овощи',
      },
      {
        'name': 'Гречка',
        'caloriesPer100g': 343.0,
        'proteinPer100g': 12.6,
        'carbsPer100g': 68.0,
        'fatPer100g': 2.6,
        'category': 'Крупы',
      },
      {
        'name': 'Овсянка',
        'caloriesPer100g': 389.0,
        'proteinPer100g': 16.9,
        'carbsPer100g': 66.0,
        'fatPer100g': 6.9,
        'category': 'Крупы',
      },
      {
        'name': 'Свинина',
        'caloriesPer100g': 242.0,
        'proteinPer100g': 27.0,
        'carbsPer100g': 0.0,
        'fatPer100g': 14.0,
        'category': 'Мясо',
      },
      {
        'name': 'Лосось',
        'caloriesPer100g': 208.0,
        'proteinPer100g': 20.0,
        'carbsPer100g': 0.0,
        'fatPer100g': 13.0,
        'category': 'Рыба',
      },
      {
        'name': 'Макароны',
        'caloriesPer100g': 131.0,
        'proteinPer100g': 5.0,
        'carbsPer100g': 25.0,
        'fatPer100g': 1.1,
        'category': 'Крупы',
      },
    ];

    for (final p in products) {
      await db.insert('Products', {
        ...p,
        'defaultGrams': 100.0,
        'isCustom': 0,
        'createdAt': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<List<Product>> getAllProducts() async {
    final db = await database;
    final maps = await db.query('Products', orderBy: 'Name');
    return maps.map((m) => Product.fromJson(_convertDbMap(m))).toList();
  }

  Future<List<Product>> searchProducts(String query) async {
    final db = await database;
    final maps = await db.query(
      'Products',
      where: 'Name LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'Name',
      limit: 50,
    );
    return maps.map((m) => Product.fromJson(_convertDbMap(m))).toList();
  }

  Future<Product?> getProductById(int id) async {
    final db = await database;
    final maps = await db.query(
      'Products',
      where: 'Id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Product.fromJson(_convertDbMap(maps.first));
  }

  Future<int> insertProduct(Product product) async {
    final db = await database;
    return db.insert('Products', {
      'Name': product.name,
      'CaloriesPer100g': product.caloriesPer100g,
      'ProteinPer100g': product.proteinPer100g,
      'CarbsPer100g': product.carbsPer100g,
      'FatPer100g': product.fatPer100g,
      'DefaultGrams': product.defaultGrams,
      'Category': product.category,
      'IsCustom': 1,
      'CreatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Meal>> getMealsByDate(DateTime date) async {
    final db = await database;
    final dateStr = _dateKey(date);
    final maps = await db.query(
      'Meals',
      where: 'Date LIKE ?',
      whereArgs: ['$dateStr%'],
      orderBy: 'MealType',
    );

    final meals = <Meal>[];
    for (final m in maps) {
      final mealId = m['Id'] as int;
      final entries = await db.query(
        'MealEntries',
        where: 'MealId = ?',
        whereArgs: [mealId],
        orderBy: 'CreatedAt',
      );
      meals.add(
        Meal.fromJson({
          ..._convertDbMap(m),
          'entries': entries.map((e) => _convertDbMap(e)).toList(),
        }),
      );
    }
    return meals;
  }

  Future<Meal> getOrCreateMeal(DateTime date, MealType mealType) async {
    final db = await database;
    final dateStr = _dateKey(date);

    final existing = await db.query(
      'Meals',
      where: 'Date LIKE ? AND MealType = ?',
      whereArgs: ['$dateStr%', mealType.index],
      limit: 1,
    );

    if (existing.isNotEmpty) {
      final mealId = existing.first['Id'] as int;
      final entries = await db.query(
        'MealEntries',
        where: 'MealId = ?',
        whereArgs: [mealId],
      );
      return Meal.fromJson({
        ..._convertDbMap(existing.first),
        'entries': entries.map((e) => _convertDbMap(e)).toList(),
      });
    }

    final id = await db.insert('Meals', {
      'Date': dateStr,
      'MealType': mealType.index,
      'TotalCalories': 0.0,
      'TotalProtein': 0.0,
      'TotalCarbs': 0.0,
      'TotalFat': 0.0,
    });

    return Meal(id: id, date: date, mealType: mealType, entries: []);
  }

  Future<int> insertMealEntry(MealEntry entry) async {
    final db = await database;
    final id = await db.insert('MealEntries', {
      'MealId': entry.mealId,
      'ProductId': entry.productId,
      'ProductName': entry.productName,
      'Grams': entry.grams,
      'Calories': entry.calories,
      'Protein': entry.protein,
      'Carbs': entry.carbs,
      'Fat': entry.fat,
      'CreatedAt': DateTime.now().toIso8601String(),
    });

    await _updateMealTotals(entry.mealId);
    return id;
  }

  Future<void> _updateMealTotals(int mealId) async {
    final db = await database;
    final result = await db.rawQuery(
      '''
      SELECT COALESCE(SUM(Calories), 0) as cal, COALESCE(SUM(Protein), 0) as prot,
             COALESCE(SUM(Carbs), 0) as carbs, COALESCE(SUM(Fat), 0) as fat
      FROM MealEntries WHERE MealId = ?
    ''',
      [mealId],
    );

    if (result.isNotEmpty) {
      await db.update(
        'Meals',
        {
          'TotalCalories': result.first['cal'],
          'TotalProtein': result.first['prot'],
          'TotalCarbs': result.first['carbs'],
          'TotalFat': result.first['fat'],
        },
        where: 'Id = ?',
        whereArgs: [mealId],
      );
    }
  }

  Future<void> deleteMealEntry(int entryId) async {
    final db = await database;
    final entries = await db.query(
      'MealEntries',
      where: 'Id = ?',
      whereArgs: [entryId],
      limit: 1,
    );
    if (entries.isEmpty) return;
    final mealId = entries.first['MealId'] as int;
    await db.delete('MealEntries', where: 'Id = ?', whereArgs: [entryId]);
    await _updateMealTotals(mealId);
  }

  Future<DailyWaterSummary> getWaterByDate(DateTime date) async {
    final db = await database;
    final dateStr = _dateKey(date);
    final maps = await db.query(
      'WaterIntake',
      where: 'Date LIKE ?',
      whereArgs: ['$dateStr%'],
      orderBy: 'Timestamp',
    );
    final entries = maps
        .map((m) => WaterIntake.fromJson(_convertDbMap(m)))
        .toList();
    final totalMl = entries.fold<int>(0, (sum, w) => sum + w.amountMl);
    return DailyWaterSummary(
      date: date,
      totalMl: totalMl,
      goalMl: 2000,
      entries: entries,
    );
  }

  Future<int> insertWaterIntake(DateTime date, int amountMl) async {
    final db = await database;
    return db.insert('WaterIntake', {
      'Date': _dateKey(date),
      'AmountMl': amountMl,
      'Timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<void> deleteWaterIntake(int id) async {
    final db = await database;
    await db.delete('WaterIntake', where: 'Id = ?', whereArgs: [id]);
  }

  Future<WeightRecord?> getWeightByDate(DateTime date) async {
    final db = await database;
    final dateStr = _dateKey(date);
    final maps = await db.query(
      'WeightRecords',
      where: 'Date LIKE ?',
      whereArgs: ['$dateStr%'],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return WeightRecord.fromJson(_convertDbMap(maps.first));
  }

  Future<List<WeightRecord>> getWeightHistory(int days) async {
    final db = await database;
    final startDate = DateTime.now().subtract(Duration(days: days));
    final maps = await db.query(
      'WeightRecords',
      where: 'Date >= ?',
      whereArgs: [_dateKey(startDate)],
      orderBy: 'Date DESC',
    );
    return maps.map((m) => WeightRecord.fromJson(_convertDbMap(m))).toList();
  }

  Future<int> insertWeight(DateTime date, double weightKg, String? note) async {
    final db = await database;
    final dateStr = _dateKey(date);
    final existing = await db.query(
      'WeightRecords',
      where: 'Date LIKE ?',
      whereArgs: ['$dateStr%'],
      limit: 1,
    );
    if (existing.isNotEmpty) {
      await db.update(
        'WeightRecords',
        {'WeightKg': weightKg, 'Note': note},
        where: 'Id = ?',
        whereArgs: [existing.first['Id']],
      );
      return existing.first['Id'] as int;
    }
    return db.insert('WeightRecords', {
      'WeightKg': weightKg,
      'Date': dateStr,
      'Note': note,
      'CreatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> deleteWeight(int id) async {
    final db = await database;
    await db.delete('WeightRecords', where: 'Id = ?', whereArgs: [id]);
  }

  Future<UserGoals> getGoals() async {
    final db = await database;
    final maps = await db.query('UserGoals', where: 'Id = 1', limit: 1);
    if (maps.isEmpty) return UserGoals();
    return UserGoals.fromJson(_convertDbMap(maps.first));
  }

  Future<void> updateGoals(UserGoals goals) async {
    final db = await database;
    await db.update('UserGoals', {
      'CaloriesPerDay': goals.caloriesPerDay,
      'ProteinPerDay': goals.proteinPerDay,
      'CarbsPerDay': goals.carbsPerDay,
      'FatPerDay': goals.fatPerDay,
      'WaterPerDayMl': goals.waterPerDayMl,
      'TargetWeightKg': goals.targetWeightKg,
    }, where: 'Id = 1');
  }

  String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Map<String, dynamic> _convertDbMap(Map<String, Object?> map) {
    final result = <String, dynamic>{};
    for (final entry in map.entries) {
      result[entry.key] = entry.value;
    }
    return result;
  }
}
