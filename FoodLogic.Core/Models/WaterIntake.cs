using System.Text.Json.Serialization;

namespace FoodLogic.Core.Models;

public class WaterIntake
{
    [JsonPropertyName("id")]
    public long Id { get; set; }

    [JsonPropertyName("date")]
    public DateTime Date { get; set; }

    [JsonPropertyName("amountMl")]
    public int AmountMl { get; set; }

    [JsonPropertyName("timestamp")]
    public DateTime Timestamp { get; set; } = DateTime.UtcNow;
}

public class DailyWaterSummary
{
    [JsonPropertyName("date")]
    public DateTime Date { get; set; }

    [JsonPropertyName("totalMl")]
    public int TotalMl { get; set; }

    [JsonPropertyName("goalMl")]
    public int GoalMl { get; set; }

    [JsonPropertyName("entries")]
    public List<WaterIntake> Entries { get; set; } = new();
}
