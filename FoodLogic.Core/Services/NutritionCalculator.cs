using FoodLogic.Core.Models;

namespace FoodLogic.Core.Services;

public static class NutritionCalculator
{
    public static MealEntry CalculateEntry(Product product, double grams)
    {
        var multiplier = grams / 100.0;
        
        return new MealEntry
        {
            ProductId = product.Id,
            ProductName = product.Name,
            Grams = grams,
            Calories = Math.Round(product.CaloriesPer100g * multiplier, 1),
            Protein = Math.Round(product.ProteinPer100g * multiplier, 1),
            Carbs = Math.Round(product.CarbsPer100g * multiplier, 1),
            Fat = Math.Round(product.FatPer100g * multiplier, 1)
        };
    }

    public static (double calories, double protein, double carbs, double fat) 
        CalculateMealTotals(IEnumerable<MealEntry> entries)
    {
        var list = entries.ToList();
        
        return (
            Math.Round(list.Sum(e => e.Calories), 1),
            Math.Round(list.Sum(e => e.Protein), 1),
            Math.Round(list.Sum(e => e.Carbs), 1),
            Math.Round(list.Sum(e => e.Fat), 1)
        );
    }

    public static double CalculateCalorieDeficit(double consumed, double goal)
    {
        return goal - consumed;
    }

    public static double CalculateMacroPercentage(double macroCalories, double totalCalories)
    {
        if (totalCalories <= 0) return 0;
        return Math.Round((macroCalories / totalCalories) * 100, 1);
    }

    public static (double protein, double carbs, double fat) CalculateMacrosFromCalories(double calories)
    {
        var protein = calories * 0.3 / 4;
        var carbs = calories * 0.4 / 4;
        var fat = calories * 0.3 / 9;
        
        return (Math.Round(protein, 1), Math.Round(carbs, 1), Math.Round(fat, 1));
    }
}
