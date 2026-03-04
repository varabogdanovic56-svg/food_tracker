using System.Text.Json.Serialization;

namespace FoodLogic.Core.Models;

public class WeeklyStats
{
    [JsonPropertyName("startDate")]
    public DateTime StartDate { get; set; }

    [JsonPropertyName("endDate")]
    public DateTime EndDate { get; set; }

    [JsonPropertyName("dailyStats")]
    public List<DailyStats> DailyStats { get; set; } = new();

    [JsonPropertyName("averageCalories")]
    public double AverageCalories { get; set; }

    [JsonPropertyName("averageProtein")]
    public double AverageProtein { get; set; }

    [JsonPropertyName("averageCarbs")]
    public double AverageCarbs { get; set; }

    [JsonPropertyName("averageFat")]
    public double AverageFat { get; set; }

    [JsonPropertyName("averageWaterMl")]
    public double AverageWaterMl { get; set; }

    [JsonPropertyName("totalWaterMl")]
    public int TotalWaterMl { get; set; }

    [JsonPropertyName("weightChange")]
    public double WeightChange { get; set; }

    [JsonPropertyName("daysTracked")]
    public int DaysTracked { get; set; }
}

public class DailyStats
{
    [JsonPropertyName("date")]
    public DateTime Date { get; set; }

    [JsonPropertyName("calories")]
    public double Calories { get; set; }

    [JsonPropertyName("protein")]
    public double Protein { get; set; }

    [JsonPropertyName("carbs")]
    public double Carbs { get; set; }

    [JsonPropertyName("fat")]
    public double Fat { get; set; }

    [JsonPropertyName("waterMl")]
    public int WaterMl { get; set; }

    [JsonPropertyName("weightKg")]
    public double? WeightKg { get; set; }
}
