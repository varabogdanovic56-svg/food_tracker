using FoodLogic.Core.Models;
using Microsoft.Data.Sqlite;

namespace FoodLogic.Core.Services;

public class UserGoalsService
{
    private readonly DatabaseService _db;

    public UserGoalsService(DatabaseService db)
    {
        _db = db;
    }

    public UserGoals GetGoals()
    {
        var conn = _db.GetDb();
        
        using var cmd = new SqliteCommand("SELECT * FROM UserGoals WHERE Id = 1", conn);
        
        using var reader = cmd.ExecuteReader();
        
        if (reader.Read())
        {
            return new UserGoals
            {
                Id = reader.GetInt64(0),
                CaloriesPerDay = reader.GetDouble(1),
                ProteinPerDay = reader.GetDouble(2),
                CarbsPerDay = reader.GetDouble(3),
                FatPerDay = reader.GetDouble(4),
                WaterPerDayMl = reader.GetInt32(5),
                TargetWeightKg = reader.IsDBNull(6) ? null : reader.GetDouble(6)
            };
        }
        
        return new UserGoals();
    }

    public void UpdateGoals(UserGoals goals)
    {
        var conn = _db.GetDb();
        
        using var cmd = new SqliteCommand(@"
            UPDATE UserGoals 
            SET CaloriesPerDay = @cal, ProteinPerDay = @prot, CarbsPerDay = @carbs, 
                FatPerDay = @fat, WaterPerDayMl = @water, TargetWeightKg = @target
            WHERE Id = 1", conn);
        
        cmd.Parameters.AddWithValue("@cal", goals.CaloriesPerDay);
        cmd.Parameters.AddWithValue("@prot", goals.ProteinPerDay);
        cmd.Parameters.AddWithValue("@carbs", goals.CarbsPerDay);
        cmd.Parameters.AddWithValue("@fat", goals.FatPerDay);
        cmd.Parameters.AddWithValue("@water", goals.WaterPerDayMl);
        cmd.Parameters.AddWithValue("@target", goals.TargetWeightKg ?? (object)DBNull.Value);
        
        cmd.ExecuteNonQuery();
    }
}
