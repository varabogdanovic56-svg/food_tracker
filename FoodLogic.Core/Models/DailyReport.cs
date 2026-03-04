using System.Text.Json.Serialization;

namespace FoodLogic.Core.Models;

public class DailyReport
{
    [JsonPropertyName("date")]
    public DateTime Date { get; set; }

    [JsonPropertyName("meals")]
    public List<Meal> Meals { get; set; } = new();

    [JsonPropertyName("waterSummary")]
    public DailyWaterSummary? WaterSummary { get; set; }

    [JsonPropertyName("weightRecord")]
    public WeightRecord? WeightRecord { get; set; }

    [JsonPropertyName("totalCalories")]
    public double TotalCalories { get; set; }

    [JsonPropertyName("totalProtein")]
    public double TotalProtein { get; set; }

    [JsonPropertyName("totalCarbs")]
    public double TotalCarbs { get; set; }

    [JsonPropertyName("totalFat")]
    public double TotalFat { get; set; }

    [JsonPropertyName("caloriesGoal")]
    public double CaloriesGoal { get; set; } = 2000;

    [JsonPropertyName("proteinGoal")]
    public double ProteinGoal { get; set; } = 100;

    [JsonPropertyName("carbsGoal")]
    public double CarbsGoal { get; set; } = 250;

    [JsonPropertyName("fatGoal")]
    public double FatGoal { get; set; } = 65;

    [JsonPropertyName("waterGoalMl")]
    public int WaterGoalMl { get; set; } = 2000;
}
