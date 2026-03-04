using FoodLogic.Core.Models;
using Microsoft.Data.Sqlite;

namespace FoodLogic.Core.Services;

public class WaterRepository
{
    private readonly DatabaseService _db;

    public WaterRepository(DatabaseService db)
    {
        _db = db;
    }

    public DailyWaterSummary GetWaterByDate(DateTime date)
    {
        var conn = _db.GetDb();
        var dateStr = date.Date.ToString("yyyy-MM-dd");
        
        using var cmd = new SqliteCommand(
            "SELECT * FROM WaterIntake WHERE Date LIKE @date ORDER BY Timestamp", conn);
        cmd.Parameters.AddWithValue("@date", $"{dateStr}%");
        
        var entries = new List<WaterIntake>();
        var totalMl = 0;
        
        using var reader = cmd.ExecuteReader();
        
        while (reader.Read())
        {
            var entry = new WaterIntake
            {
                Id = reader.GetInt64(0),
                Date = DateTime.Parse(reader.GetString(1)),
                AmountMl = reader.GetInt32(2),
                Timestamp = DateTime.Parse(reader.GetString(3))
            };
            entries.Add(entry);
            totalMl += entry.AmountMl;
        }
        
        return new DailyWaterSummary
        {
            Date = date.Date,
            TotalMl = totalMl,
            GoalMl = 2000,
            Entries = entries
        };
    }

    public WaterIntake AddWaterIntake(DateTime date, int amountMl)
    {
        var conn = _db.GetDb();
        var dateStr = date.Date.ToString("yyyy-MM-dd");
        
        using var cmd = new SqliteCommand(@"
            INSERT INTO WaterIntake (Date, AmountMl, Timestamp) VALUES (@date, @amount, @ts);
            SELECT last_insert_rowid();", conn);
        
        cmd.Parameters.AddWithValue("@date", dateStr);
        cmd.Parameters.AddWithValue("@amount", amountMl);
        cmd.Parameters.AddWithValue("@ts", DateTime.UtcNow.ToString("o"));
        
        var id = Convert.ToInt64(cmd.ExecuteScalar());
        
        return new WaterIntake
        {
            Id = id,
            Date = date.Date,
            AmountMl = amountMl,
            Timestamp = DateTime.UtcNow
        };
    }

    public void DeleteWaterIntake(long id)
    {
        var conn = _db.GetDb();
        
        using var cmd = new SqliteCommand("DELETE FROM WaterIntake WHERE Id = @id", conn);
        cmd.Parameters.AddWithValue("@id", id);
        cmd.ExecuteNonQuery();
    }

    public int GetTotalWaterForDateRange(DateTime startDate, DateTime endDate)
    {
        var conn = _db.GetDb();
        var startStr = startDate.Date.ToString("yyyy-MM-dd");
        var endStr = endDate.Date.ToString("yyyy-MM-dd");
        
        using var cmd = new SqliteCommand(@"
            SELECT COALESCE(SUM(AmountMl), 0) FROM WaterIntake 
            WHERE Date >= @start AND Date <= @end", conn);
        cmd.Parameters.AddWithValue("@start", startStr);
        cmd.Parameters.AddWithValue("@end", endStr);
        
        return Convert.ToInt32(cmd.ExecuteScalar());
    }
}
