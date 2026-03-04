using FoodLogic.Core.Models;
using Microsoft.Data.Sqlite;

namespace FoodLogic.Core.Services;

public class WeightRepository
{
    private readonly DatabaseService _db;

    public WeightRepository(DatabaseService db)
    {
        _db = db;
    }

    public WeightRecord? GetWeightByDate(DateTime date)
    {
        var conn = _db.GetDb();
        var dateStr = date.Date.ToString("yyyy-MM-dd");
        
        using var cmd = new SqliteCommand(
            "SELECT * FROM WeightRecords WHERE Date LIKE @date LIMIT 1", conn);
        cmd.Parameters.AddWithValue("@date", $"{dateStr}%");
        
        using var reader = cmd.ExecuteReader();
        
        if (reader.Read())
        {
            return MapWeightRecord(reader);
        }
        
        return null;
    }

    public WeightRecord? GetLatestWeight()
    {
        var conn = _db.GetDb();
        
        using var cmd = new SqliteCommand(
            "SELECT * FROM WeightRecords ORDER BY Date DESC LIMIT 1", conn);
        
        using var reader = cmd.ExecuteReader();
        
        if (reader.Read())
        {
            return MapWeightRecord(reader);
        }
        
        return null;
    }

    public List<WeightRecord> GetWeightHistory(int days = 30)
    {
        var records = new List<WeightRecord>();
        var conn = _db.GetDb();
        var startDate = DateTime.Now.AddDays(-days).Date.ToString("yyyy-MM-dd");
        
        using var cmd = new SqliteCommand(
            "SELECT * FROM WeightRecords WHERE Date >= @start ORDER BY Date", conn);
        cmd.Parameters.AddWithValue("@start", startDate);
        
        using var reader = cmd.ExecuteReader();
        
        while (reader.Read())
        {
            records.Add(MapWeightRecord(reader));
        }
        
        return records;
    }

    public WeightRecord AddOrUpdateWeight(DateTime date, double weightKg, string? note = null)
    {
        var conn = _db.GetDb();
        var dateStr = date.Date.ToString("yyyy-MM-dd");
        
        var existingCmd = new SqliteCommand(
            "SELECT Id FROM WeightRecords WHERE Date LIKE @date", conn);
        existingCmd.Parameters.AddWithValue("@date", $"{dateStr}%");
        
        var existingId = existingCmd.ExecuteScalar();
        
        if (existingId != null)
        {
            using var updateCmd = new SqliteCommand(@"
                UPDATE WeightRecords SET WeightKg = @weight, Note = @note WHERE Id = @id", conn);
            updateCmd.Parameters.AddWithValue("@id", existingId);
            updateCmd.Parameters.AddWithValue("@weight", weightKg);
            updateCmd.Parameters.AddWithValue("@note", note ?? (object)DBNull.Value);
            updateCmd.ExecuteNonQuery();
            
            return new WeightRecord
            {
                Id = Convert.ToInt64(existingId),
                Date = date.Date,
                WeightKg = weightKg,
                Note = note
            };
        }
        
        using var insertCmd = new SqliteCommand(@"
            INSERT INTO WeightRecords (WeightKg, Date, Note, CreatedAt) VALUES (@weight, @date, @note, @created);
            SELECT last_insert_rowid();", conn);
        
        insertCmd.Parameters.AddWithValue("@weight", weightKg);
        insertCmd.Parameters.AddWithValue("@date", dateStr);
        insertCmd.Parameters.AddWithValue("@note", note ?? (object)DBNull.Value);
        insertCmd.Parameters.AddWithValue("@created", DateTime.UtcNow.ToString("o"));
        
        var id = Convert.ToInt64(insertCmd.ExecuteScalar());
        
        return new WeightRecord
        {
            Id = id,
            Date = date.Date,
            WeightKg = weightKg,
            Note = note,
            CreatedAt = DateTime.UtcNow
        };
    }

    public void DeleteWeight(long id)
    {
        var conn = _db.GetDb();
        
        using var cmd = new SqliteCommand("DELETE FROM WeightRecords WHERE Id = @id", conn);
        cmd.Parameters.AddWithValue("@id", id);
        cmd.ExecuteNonQuery();
    }

    private static WeightRecord MapWeightRecord(SqliteDataReader reader)
    {
        return new WeightRecord
        {
            Id = reader.GetInt64(0),
            WeightKg = reader.GetDouble(1),
            Date = DateTime.Parse(reader.GetString(2)),
            Note = reader.IsDBNull(3) ? null : reader.GetString(3),
            CreatedAt = DateTime.Parse(reader.GetString(4))
        };
    }
}
