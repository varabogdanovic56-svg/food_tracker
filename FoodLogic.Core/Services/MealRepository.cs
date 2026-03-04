using FoodLogic.Core.Models;
using Microsoft.Data.Sqlite;

namespace FoodLogic.Core.Services;

public class MealRepository
{
    private readonly DatabaseService _db;

    public MealRepository(DatabaseService db)
    {
        _db = db;
    }

    public List<Meal> GetMealsByDate(DateTime date)
    {
        var meals = new List<Meal>();
        var conn = _db.GetDb();
        var dateStr = date.Date.ToString("yyyy-MM-dd");
        
        using var cmd = new SqliteCommand(
            "SELECT * FROM Meals WHERE Date LIKE @date ORDER BY MealType", conn);
        cmd.Parameters.AddWithValue("@date", $"{dateStr}%");
        
        using var reader = cmd.ExecuteReader();
        
        while (reader.Read())
        {
            var meal = MapMeal(reader);
            meal.Entries = GetMealEntries(meal.Id);
            meals.Add(meal);
        }
        
        return meals;
    }

    public Meal? GetMeal(long id)
    {
        var conn = _db.GetDb();
        
        using var cmd = new SqliteCommand("SELECT * FROM Meals WHERE Id = @id", conn);
        cmd.Parameters.AddWithValue("@id", id);
        
        using var reader = cmd.ExecuteReader();
        
        if (reader.Read())
        {
            var meal = MapMeal(reader);
            meal.Entries = GetMealEntries(meal.Id);
            return meal;
        }
        
        return null;
    }

    public Meal GetOrCreateMeal(DateTime date, MealType mealType)
    {
        var conn = _db.GetDb();
        var dateStr = date.Date.ToString("yyyy-MM-dd");
        
        using var cmd = new SqliteCommand(
            "SELECT * FROM Meals WHERE Date LIKE @date AND MealType = @type", conn);
        cmd.Parameters.AddWithValue("@date", $"{dateStr}%");
        cmd.Parameters.AddWithValue("@type", (int)mealType);
        
        using var reader = cmd.ExecuteReader();
        
        if (reader.Read())
        {
            var meal = MapMeal(reader);
            meal.Entries = GetMealEntries(meal.Id);
            return meal;
        }
        
        using var insertCmd = new SqliteCommand(@"
            INSERT INTO Meals (Date, MealType) VALUES (@date, @type);
            SELECT last_insert_rowid();", conn);
        
        insertCmd.Parameters.AddWithValue("@date", dateStr);
        insertCmd.Parameters.AddWithValue("@type", (int)mealType);
        
        var id = Convert.ToInt64(insertCmd.ExecuteScalar());
        
        return new Meal
        {
            Id = id,
            Date = date.Date,
            MealType = mealType,
            Entries = new List<MealEntry>()
        };
    }

    public MealEntry AddEntry(MealEntry entry)
    {
        var conn = _db.GetDb();
        
        using var cmd = new SqliteCommand(@"
            INSERT INTO MealEntries (MealId, ProductId, ProductName, Grams, Calories, Protein, Carbs, Fat, CreatedAt)
            VALUES (@mealId, @productId, @productName, @grams, @cal, @prot, @carbs, @fat, @created);
            SELECT last_insert_rowid();", conn);
        
        cmd.Parameters.AddWithValue("@mealId", entry.MealId);
        cmd.Parameters.AddWithValue("@productId", entry.ProductId);
        cmd.Parameters.AddWithValue("@productName", entry.ProductName);
        cmd.Parameters.AddWithValue("@grams", entry.Grams);
        cmd.Parameters.AddWithValue("@cal", entry.Calories);
        cmd.Parameters.AddWithValue("@prot", entry.Protein);
        cmd.Parameters.AddWithValue("@carbs", entry.Carbs);
        cmd.Parameters.AddWithValue("@fat", entry.Fat);
        cmd.Parameters.AddWithValue("@created", DateTime.UtcNow.ToString("o"));
        
        entry.Id = Convert.ToInt64(cmd.ExecuteScalar());
        entry.CreatedAt = DateTime.UtcNow;
        
        UpdateMealTotals(entry.MealId);
        
        return entry;
    }

    public void DeleteEntry(long entryId)
    {
        var conn = _db.GetDb();
        
        using var getCmd = new SqliteCommand("SELECT MealId FROM MealEntries WHERE Id = @id", conn);
        getCmd.Parameters.AddWithValue("@id", entryId);
        var mealId = Convert.ToInt64(getCmd.ExecuteScalar());
        
        using var cmd = new SqliteCommand("DELETE FROM MealEntries WHERE Id = @id", conn);
        cmd.Parameters.AddWithValue("@id", entryId);
        cmd.ExecuteNonQuery();
        
        UpdateMealTotals(mealId);
    }

    public void DeleteMeal(long mealId)
    {
        var conn = _db.GetDb();
        
        using var cmd = new SqliteCommand("DELETE FROM Meals WHERE Id = @id", conn);
        cmd.Parameters.AddWithValue("@id", mealId);
        cmd.ExecuteNonQuery();
    }

    private void UpdateMealTotals(long mealId)
    {
        var conn = _db.GetDb();
        
        using var cmd = new SqliteCommand(@"
            SELECT COALESCE(SUM(Calories), 0), COALESCE(SUM(Protein), 0), 
                   COALESCE(SUM(Carbs), 0), COALESCE(SUM(Fat), 0)
            FROM MealEntries WHERE MealId = @mealId", conn);
        cmd.Parameters.AddWithValue("@mealId", mealId);
        
        using var reader = cmd.ExecuteReader();
        
        if (reader.Read())
        {
            var cal = reader.GetDouble(0);
            var prot = reader.GetDouble(1);
            var carbs = reader.GetDouble(2);
            var fat = reader.GetDouble(3);
            
            using var updateCmd = new SqliteCommand(@"
                UPDATE Meals SET TotalCalories = @cal, TotalProtein = @prot, 
                                 TotalCarbs = @carbs, TotalFat = @fat
                WHERE Id = @mealId", conn);
            updateCmd.Parameters.AddWithValue("@mealId", mealId);
            updateCmd.Parameters.AddWithValue("@cal", cal);
            updateCmd.Parameters.AddWithValue("@prot", prot);
            updateCmd.Parameters.AddWithValue("@carbs", carbs);
            updateCmd.Parameters.AddWithValue("@fat", fat);
            updateCmd.ExecuteNonQuery();
        }
    }

    private List<MealEntry> GetMealEntries(long mealId)
    {
        var entries = new List<MealEntry>();
        var conn = _db.GetDb();
        
        using var cmd = new SqliteCommand(
            "SELECT * FROM MealEntries WHERE MealId = @mealId ORDER BY CreatedAt", conn);
        cmd.Parameters.AddWithValue("@mealId", mealId);
        
        using var reader = cmd.ExecuteReader();
        
        while (reader.Read())
        {
            entries.Add(new MealEntry
            {
                Id = reader.GetInt64(0),
                MealId = reader.GetInt64(1),
                ProductId = reader.GetInt64(2),
                ProductName = reader.GetString(3),
                Grams = reader.GetDouble(4),
                Calories = reader.GetDouble(5),
                Protein = reader.GetDouble(6),
                Carbs = reader.GetDouble(7),
                Fat = reader.GetDouble(8),
                CreatedAt = DateTime.Parse(reader.GetString(9))
            });
        }
        
        return entries;
    }

    private static Meal MapMeal(SqliteDataReader reader)
    {
        return new Meal
        {
            Id = reader.GetInt64(0),
            Date = DateTime.Parse(reader.GetString(1)),
            MealType = (MealType)reader.GetInt32(2),
            TotalCalories = reader.IsDBNull(3) ? 0 : reader.GetDouble(3),
            TotalProtein = reader.IsDBNull(4) ? 0 : reader.GetDouble(4),
            TotalCarbs = reader.IsDBNull(5) ? 0 : reader.GetDouble(5),
            TotalFat = reader.IsDBNull(6) ? 0 : reader.GetDouble(6)
        };
    }
}
