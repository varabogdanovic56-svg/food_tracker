using Microsoft.Data.Sqlite;

namespace FoodLogic.Core.Services;

public class DatabaseService : IDisposable
{
    private readonly string _connectionString;
    private SqliteConnection? _connection;

    public DatabaseService(string databasePath)
    {
        _connectionString = $"Data Source={databasePath}";
        InitializeDatabase();
    }

    private SqliteConnection GetConnection()
    {
        if (_connection == null)
        {
            _connection = new SqliteConnection(_connectionString);
            _connection.Open();
        }
        return _connection;
    }

    private void InitializeDatabase()
    {
        var conn = GetConnection();
        
        var createTables = @"
            CREATE TABLE IF NOT EXISTS Products (
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
            );

            CREATE TABLE IF NOT EXISTS Meals (
                Id INTEGER PRIMARY KEY AUTOINCREMENT,
                Date TEXT NOT NULL,
                MealType INTEGER NOT NULL
            );

            CREATE TABLE IF NOT EXISTS MealEntries (
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
                FOREIGN KEY (MealId) REFERENCES Meals(Id) ON DELETE CASCADE,
                FOREIGN KEY (ProductId) REFERENCES Products(Id)
            );

            CREATE TABLE IF NOT EXISTS WaterIntake (
                Id INTEGER PRIMARY KEY AUTOINCREMENT,
                Date TEXT NOT NULL,
                AmountMl INTEGER NOT NULL,
                Timestamp TEXT NOT NULL
            );

            CREATE TABLE IF NOT EXISTS WeightRecords (
                Id INTEGER PRIMARY KEY AUTOINCREMENT,
                WeightKg REAL NOT NULL,
                Date TEXT NOT NULL,
                Note TEXT,
                CreatedAt TEXT NOT NULL
            );

            CREATE TABLE IF NOT EXISTS UserGoals (
                Id INTEGER PRIMARY KEY,
                CaloriesPerDay REAL NOT NULL,
                ProteinPerDay REAL NOT NULL,
                CarbsPerDay REAL NOT NULL,
                FatPerDay REAL NOT NULL,
                WaterPerDayMl INTEGER NOT NULL,
                TargetWeightKg REAL
            );

            INSERT OR IGNORE INTO UserGoals (Id, CaloriesPerDay, ProteinPerDay, CarbsPerDay, FatPerDay, WaterPerDayMl)
            VALUES (1, 2000, 100, 250, 65, 2000);
        ";

        using var cmd = new SqliteCommand(createTables, conn);
        cmd.ExecuteNonQuery();

        SeedDefaultProducts(conn);
    }

    private void SeedDefaultProducts(SqliteConnection conn)
    {
        var checkCmd = new SqliteCommand("SELECT COUNT(*) FROM Products", conn);
        var count = Convert.ToInt64(checkCmd.ExecuteScalar());
        
        if (count > 0) return;

        var defaultProducts = new[]
        {
            ("Яблоко", 52, 0.3, 14, 0.2, "Фрукты"),
            ("Банан", 89, 1.1, 23, 0.3, "Фрукты"),
            ("Куриная грудка", 165, 31, 0, 3.6, "Мясо"),
            ("Рис отварной", 130, 2.7, 28, 0.3, "Крупы"),
            ("Яйцо куриное", 155, 13, 1.1, 11, "Яйца"),
            ("Молоко 3.2%", 61, 3.2, 4.8, 3.3, "Молочные"),
            ("Творог 5%", 121, 17, 3.6, 5, "Молочные"),
            ("Хлеб пшеничный", 265, 8, 49, 3.2, "Выпечка"),
            ("Картофель", 77, 2, 17, 0.1, "Овощи"),
            ("Огурец", 15, 0.7, 3.6, 0.1, "Овощи"),
            ("Гречка", 343, 12.6, 68, 2.6, "Крупы"),
            ("Овсянка", 389, 16.9, 66, 6.9, "Крупы"),
            ("Свинина", 242, 27, 0, 14, "Мясо"),
            ("Лосось", 208, 20, 0, 13, "Рыба"),
            ("Макароны", 131, 5, 25, 1.1, "Крупы")
        };

        foreach (var (name, cal, prot, carbs, fat, category) in defaultProducts)
        {
            var insertCmd = new SqliteCommand(
                "INSERT INTO Products (Name, CaloriesPer100g, ProteinPer100g, CarbsPer100g, FatPer100g, DefaultGrams, Category, IsCustom, CreatedAt) VALUES (@name, @cal, @prot, @carbs, @fat, 100, @cat, 0, @created)",
                conn);
            insertCmd.Parameters.AddWithValue("@name", name);
            insertCmd.Parameters.AddWithValue("@cal", cal);
            insertCmd.Parameters.AddWithValue("@prot", prot);
            insertCmd.Parameters.AddWithValue("@carbs", carbs);
            insertCmd.Parameters.AddWithValue("@fat", fat);
            insertCmd.Parameters.AddWithValue("@cat", category);
            insertCmd.Parameters.AddWithValue("@created", DateTime.UtcNow.ToString("o"));
            insertCmd.ExecuteNonQuery();
        }
    }

    public SqliteConnection GetDb() => GetConnection();

    public void Dispose()
    {
        _connection?.Close();
        _connection?.Dispose();
    }
}
