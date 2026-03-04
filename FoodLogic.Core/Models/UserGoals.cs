using System.Text.Json.Serialization;

namespace FoodLogic.Core.Models;

public class UserGoals
{
    [JsonPropertyName("id")]
    public long Id { get; set; } = 1;

    [JsonPropertyName("caloriesPerDay")]
    public double CaloriesPerDay { get; set; } = 2000;

    [JsonPropertyName("proteinPerDay")]
    public double ProteinPerDay { get; set; } = 100;

    [JsonPropertyName("carbsPerDay")]
    public double CarbsPerDay { get; set; } = 250;

    [JsonPropertyName("fatPerDay")]
    public double FatPerDay { get; set; } = 65;

    [JsonPropertyName("waterPerDayMl")]
    public int WaterPerDayMl { get; set; } = 2000;

    [JsonPropertyName("targetWeightKg")]
    public double? TargetWeightKg { get; set; }
}
