using System.Text.Json.Serialization;

namespace FoodLogic.Core.Models;

public class MealEntry
{
    [JsonPropertyName("id")]
    public long Id { get; set; }

    [JsonPropertyName("mealId")]
    public long MealId { get; set; }

    [JsonPropertyName("productId")]
    public long ProductId { get; set; }

    [JsonPropertyName("productName")]
    public string ProductName { get; set; } = string.Empty;

    [JsonPropertyName("grams")]
    public double Grams { get; set; }

    [JsonPropertyName("calories")]
    public double Calories { get; set; }

    [JsonPropertyName("protein")]
    public double Protein { get; set; }

    [JsonPropertyName("carbs")]
    public double Carbs { get; set; }

    [JsonPropertyName("fat")]
    public double Fat { get; set; }

    [JsonPropertyName("createdAt")]
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
