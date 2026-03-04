using System.Text.Json.Serialization;

namespace FoodLogic.Core.Models;

public class Meal
{
    [JsonPropertyName("id")]
    public long Id { get; set; }

    [JsonPropertyName("date")]
    public DateTime Date { get; set; }

    [JsonPropertyName("mealType")]
    public MealType MealType { get; set; }

    [JsonPropertyName("entries")]
    public List<MealEntry> Entries { get; set; } = new();

    [JsonPropertyName("totalCalories")]
    public double TotalCalories { get; set; }

    [JsonPropertyName("totalProtein")]
    public double TotalProtein { get; set; }

    [JsonPropertyName("totalCarbs")]
    public double TotalCarbs { get; set; }

    [JsonPropertyName("totalFat")]
    public double TotalFat { get; set; }
}

[JsonConverter(typeof(JsonStringEnumConverter))]
public enum MealType
{
    Breakfast = 0,
    Lunch = 1,
    Dinner = 2,
    Snack = 3
}
