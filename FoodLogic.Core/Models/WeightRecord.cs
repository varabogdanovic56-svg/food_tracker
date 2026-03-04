using System.Text.Json.Serialization;

namespace FoodLogic.Core.Models;

public class WeightRecord
{
    [JsonPropertyName("id")]
    public long Id { get; set; }

    [JsonPropertyName("weightKg")]
    public double WeightKg { get; set; }

    [JsonPropertyName("date")]
    public DateTime Date { get; set; }

    [JsonPropertyName("note")]
    public string? Note { get; set; }

    [JsonPropertyName("createdAt")]
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
