using FoodLogic.Core.Models;
using Microsoft.Data.Sqlite;

namespace FoodLogic.Core.Services;

public class StatisticsService
{
    private readonly DatabaseService _db;

    public StatisticsService(DatabaseService db)
    {
        _db = db;
    }

    public WeeklyStats GetWeeklyStats(DateTime endDate)
    {
        var startDate = endDate.AddDays(-6).Date;
        var conn = _db.GetDb();
        
        var dailyStats = new List<DailyStats>();
        double totalCal = 0, totalProt = 0, totalCarbs = 0, totalFat = 0;
        int totalWater = 0;
        double? firstWeight = null, lastWeight = null;
        
        for (var date = startDate; date <= endDate; date = date.AddDays(1))
        {
            var dateStr = date.ToString("yyyy-MM-dd");
            
            using var mealCmd = new SqliteCommand(@"
                SELECT COALESCE(SUM(TotalCalories), 0), COALESCE(SUM(TotalProtein), 0),
                       COALESCE(SUM(TotalCarbs), 0), COALESCE(SUM(TotalFat), 0)
                FROM Meals WHERE Date LIKE @date", conn);
            mealCmd.Parameters.AddWithValue("@date", $"{dateStr}%");
            
            double cal = 0, prot = 0, carbs = 0, fat = 0;
            using (var reader = mealCmd.ExecuteReader())
            {
                if (reader.Read())
                {
                    cal = reader.GetDouble(0);
                    prot = reader.GetDouble(1);
                    carbs = reader.GetDouble(2);
                    fat = reader.GetDouble(3);
                }
            }
            
            using var waterCmd = new SqliteCommand(
                "SELECT COALESCE(SUM(AmountMl), 0) FROM WaterIntake WHERE Date LIKE @date", conn);
            waterCmd.Parameters.AddWithValue("@date", $"{dateStr}%");
            var water = Convert.ToInt32(waterCmd.ExecuteScalar());
            
            double? weight = null;
            using var weightCmd = new SqliteCommand(
                "SELECT WeightKg FROM WeightRecords WHERE Date LIKE @date LIMIT 1", conn);
            weightCmd.Parameters.AddWithValue("@date", $"{dateStr}%");
            var weightResult = weightCmd.ExecuteScalar();
            if (weightResult != null)
            {
                weight = Convert.ToDouble(weightResult);
                if (firstWeight == null) firstWeight = weight;
                lastWeight = weight;
            }
            
            dailyStats.Add(new DailyStats
            {
                Date = date,
                Calories = cal,
                Protein = prot,
                Carbs = carbs,
                Fat = fat,
                WaterMl = water,
                WeightKg = weight
            });
            
            totalCal += cal;
            totalProt += prot;
            totalCarbs += carbs;
            totalFat += fat;
            totalWater += water;
        }
        
        var daysWithData = dailyStats.Count(d => d.Calories > 0);
        
        return new WeeklyStats
        {
            StartDate = startDate,
            EndDate = endDate,
            DailyStats = dailyStats,
            AverageCalories = daysWithData > 0 ? totalCal / daysWithData : 0,
            AverageProtein = daysWithData > 0 ? totalProt / daysWithData : 0,
            AverageCarbs = daysWithData > 0 ? totalCarbs / daysWithData : 0,
            AverageFat = daysWithData > 0 ? totalFat / daysWithData : 0,
            AverageWaterMl = daysWithData > 0 ? (double)totalWater / daysWithData : 0,
            TotalWaterMl = totalWater,
            WeightChange = (firstWeight.HasValue && lastWeight.HasValue) ? lastWeight.Value - firstWeight.Value : 0,
            DaysTracked = daysWithData
        };
    }

    public DailyReport GetDailyReport(DateTime date, UserGoals goals)
    {
        var conn = _db.GetDb();
        var dateStr = date.Date.ToString("yyyy-MM-dd");
        
        var meals = new List<Meal>();
        using var mealCmd = new SqliteCommand(
            "SELECT * FROM Meals WHERE Date LIKE @date ORDER BY MealType", conn);
        mealCmd.Parameters.AddWithValue("@date", $"{dateStr}%");
        
        using var mealReader = mealCmd.ExecuteReader();
        
        while (mealReader.Read())
        {
            var mealId = mealReader.GetInt64(0);
            var meal = new Meal
            {
                Id = mealId,
                Date = DateTime.Parse(mealReader.GetString(1)),
                MealType = (MealType)mealReader.GetInt32(2),
                TotalCalories = mealReader.IsDBNull(3) ? 0 : mealReader.GetDouble(3),
                TotalProtein = mealReader.IsDBNull(4) ? 0 : mealReader.GetDouble(4),
                TotalCarbs = mealReader.IsDBNull(5) ? 0 : mealReader.GetDouble(5),
                TotalFat = mealReader.IsDBNull(6) ? 0 : mealReader.GetDouble(6)
            };
            
            using var entryCmd = new SqliteCommand(
                "SELECT * FROM MealEntries WHERE MealId = @mealId ORDER BY CreatedAt", conn);
            entryCmd.Parameters.AddWithValue("@mealId", mealId);
            
            using var entryReader = entryCmd.ExecuteReader();
            
            while (entryReader.Read())
            {
                meal.Entries.Add(new MealEntry
                {
                    Id = entryReader.GetInt64(0),
                    MealId = entryReader.GetInt64(1),
                    ProductId = entryReader.GetInt64(2),
                    ProductName = entryReader.GetString(3),
                    Grams = entryReader.GetDouble(4),
                    Calories = entryReader.GetDouble(5),
                    Protein = entryReader.GetDouble(6),
                    Carbs = entryReader.GetDouble(7),
                    Fat = entryReader.GetDouble(8),
                    CreatedAt = DateTime.Parse(entryReader.GetString(9))
                });
            }
            
            meals.Add(meal);
        }
        
        using var waterCmd = new SqliteCommand(
            "SELECT * FROM WaterIntake WHERE Date LIKE @date ORDER BY Timestamp", conn);
        waterCmd.Parameters.AddWithValue("@date", $"{dateStr}%");
        
        var waterEntries = new List<WaterIntake>();
        var totalWater = 0;
        
        using var waterReader = waterCmd.ExecuteReader();
        
        while (waterReader.Read())
        {
            var entry = new WaterIntake
            {
                Id = waterReader.GetInt64(0),
                Date = DateTime.Parse(waterReader.GetString(1)),
                AmountMl = waterReader.GetInt32(2),
                Timestamp = DateTime.Parse(waterReader.GetString(3))
            };
            waterEntries.Add(entry);
            totalWater += entry.AmountMl;
        }
        
        WeightRecord? weightRecord = null;
        using var weightCmd = new SqliteCommand(
            "SELECT * FROM WeightRecords WHERE Date LIKE @date LIMIT 1", conn);
        weightCmd.Parameters.AddWithValue("@date", $"{dateStr}%");
        
        using var weightReader = weightCmd.ExecuteReader();
        
        if (weightReader.Read())
        {
            weightRecord = new WeightRecord
            {
                Id = weightReader.GetInt64(0),
                WeightKg = weightReader.GetDouble(1),
                Date = DateTime.Parse(weightReader.GetString(2)),
                Note = weightReader.IsDBNull(3) ? null : weightReader.GetString(3),
                CreatedAt = DateTime.Parse(weightReader.GetString(4))
            };
        }
        
        return new DailyReport
        {
            Date = date.Date,
            Meals = meals,
            WaterSummary = new DailyWaterSummary
            {
                Date = date.Date,
                TotalMl = totalWater,
                GoalMl = goals.WaterPerDayMl,
                Entries = waterEntries
            },
            WeightRecord = weightRecord,
            TotalCalories = meals.Sum(m => m.TotalCalories),
            TotalProtein = meals.Sum(m => m.TotalProtein),
            TotalCarbs = meals.Sum(m => m.TotalCarbs),
            TotalFat = meals.Sum(m => m.TotalFat),
            CaloriesGoal = goals.CaloriesPerDay,
            ProteinGoal = goals.ProteinPerDay,
            CarbsGoal = goals.CarbsPerDay,
            FatGoal = goals.FatPerDay,
            WaterGoalMl = goals.WaterPerDayMl
        };
    }
}
