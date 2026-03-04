using System.Text.Json.Serialization;

namespace FoodLogic.Core.Models;

public class Product
{
    [JsonPropertyName("id")]
    public long Id { get; set; }

    [JsonPropertyName("name")]
    public string Name { get; set; } = string.Empty;

    [JsonPropertyName("caloriesPer100g")]
    public double CaloriesPer100g { get; set; }

    [JsonPropertyName("proteinPer100g")]
    public double ProteinPer100g { get; set; }

    [JsonPropertyName("carbsPer100g")]
    public double CarbsPer100g { get; set; }

    [JsonPropertyName("fatPer100g")]
    public double FatPer100g { get; set; }

    [JsonPropertyName("defaultGrams")]
    public double DefaultGrams { get; set; } = 100;

    [JsonPropertyName("category")]
    public string? Category { get; set; }

    [JsonPropertyName("isCustom")]
    public bool IsCustom { get; set; }

    [JsonPropertyName("createdAt")]
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
