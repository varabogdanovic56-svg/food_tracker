using System.Runtime.InteropServices;
using System.Text;
using System.Text.Json;
using FoodLogic.Core.Models;
using FoodLogic.Core.Services;

namespace FoodLogic.Core.Interop;

public class FoodTrackerFFI
{
    private DatabaseService? _db;
    private ProductRepository? _products;
    private MealRepository? _meals;
    private WaterRepository? _water;
    private WeightRepository? _weight;
    private UserGoalsService? _goals;
    private StatisticsService? _statistics;
    private bool _initialized;

    public void Initialize(string databasePath)
    {
        if (_initialized) return;
        
        _db = new DatabaseService(databasePath);
        _products = new ProductRepository(_db);
        _meals = new MealRepository(_db);
        _water = new WaterRepository(_db);
        _weight = new WeightRepository(_db);
        _goals = new UserGoalsService(_db);
        _statistics = new StatisticsService(_db);
        _initialized = true;
    }

    public string Execute(string jsonRequest)
    {
        if (!_initialized)
        {
            return CreateErrorResponse("Not initialized. Call Initialize first.");
        }

        try
        {
            using var doc = JsonDocument.Parse(jsonRequest);
            var root = doc.RootElement;
            
            var method = root.GetProperty("method").GetString();
            var paramsObj = root.TryGetProperty("params", out var p) ? p : default;
            
            var result = method switch
            {
                "getAllProducts" => GetAllProducts(),
                "searchProducts" => SearchProducts(GetString(paramsObj, "query")),
                "addProduct" => AddProduct(paramsObj),
                "updateProduct" => UpdateProduct(paramsObj),
                "deleteProduct" => DeleteProduct(GetLong(paramsObj, "id")),
                
                "getDailyReport" => GetDailyReport(GetDateTime(paramsObj, "date")),
                "getMeal" => GetMeal(GetLong(paramsObj, "mealId")),
                "getOrCreateMeal" => GetOrCreateMeal(GetDateTime(paramsObj, "date"), GetInt(paramsObj, "mealType")),
                "addMealEntry" => AddMealEntry(paramsObj),
                "deleteMealEntry" => DeleteMealEntry(GetLong(paramsObj, "entryId")),
                
                "getWaterByDate" => GetWaterByDate(GetDateTime(paramsObj, "date")),
                "addWaterIntake" => AddWaterIntake(GetDateTime(paramsObj, "date"), GetInt(paramsObj, "amountMl")),
                "deleteWaterIntake" => DeleteWaterIntake(GetLong(paramsObj, "id")),
                
                "getWeightByDate" => GetWeightByDate(GetDateTime(paramsObj, "date")),
                "getWeightHistory" => GetWeightHistory(GetInt(paramsObj, "days")),
                "addWeight" => AddWeight(paramsObj),
                "deleteWeight" => DeleteWeight(GetLong(paramsObj, "id")),
                
                "getGoals" => GetGoals(),
                "updateGoals" => UpdateGoals(paramsObj),
                
                "getWeeklyStats" => GetWeeklyStats(GetDateTime(paramsObj, "endDate")),
                
                "calculateEntry" => CalculateEntry(paramsObj),
                
                _ => throw new ArgumentException($"Unknown method: {method}")
            };

            return CreateSuccessResponse(result);
        }
        catch (Exception ex)
        {
            return CreateErrorResponse(ex.Message);
        }
    }

    private string GetAllProducts() => JsonSerializer.Serialize(_products!.GetAll());
    private string SearchProducts(string query) => JsonSerializer.Serialize(_products!.Search(query));
    
    private string AddProduct(JsonElement paramsObj)
    {
        var product = new Product
        {
            Name = GetString(paramsObj, "name"),
            CaloriesPer100g = GetDouble(paramsObj, "caloriesPer100g"),
            ProteinPer100g = GetDouble(paramsObj, "proteinPer100g"),
            CarbsPer100g = GetDouble(paramsObj, "carbsPer100g"),
            FatPer100g = GetDouble(paramsObj, "fatPer100g"),
            DefaultGrams = GetDouble(paramsObj, "defaultGrams", 100),
            Category = GetString(paramsObj, "category")
        };
        
        var result = _products!.Add(product);
        return JsonSerializer.Serialize(result);
    }

    private string UpdateProduct(JsonElement paramsObj)
    {
        var product = new Product
        {
            Id = GetLong(paramsObj, "id"),
            Name = GetString(paramsObj, "name"),
            CaloriesPer100g = GetDouble(paramsObj, "caloriesPer100g"),
            ProteinPer100g = GetDouble(paramsObj, "proteinPer100g"),
            CarbsPer100g = GetDouble(paramsObj, "carbsPer100g"),
            FatPer100g = GetDouble(paramsObj, "fatPer100g"),
            DefaultGrams = GetDouble(paramsObj, "defaultGrams", 100),
            Category = GetString(paramsObj, "category")
        };
        
        _products!.Update(product);
        return "true";
    }

    private string DeleteProduct(long id)
    {
        _products!.Delete(id);
        return "true";
    }

    private string GetDailyReport(DateTime date)
    {
        var goals = _goals!.GetGoals();
        var report = _statistics!.GetDailyReport(date, goals);
        return JsonSerializer.Serialize(report);
    }

    private string GetMeal(long mealId)
    {
        var meal = _meals!.GetMeal(mealId);
        return JsonSerializer.Serialize(meal);
    }

    private string GetOrCreateMeal(DateTime date, int mealType)
    {
        var meal = _meals!.GetOrCreateMeal(date, (MealType)mealType);
        return JsonSerializer.Serialize(meal);
    }

    private string AddMealEntry(JsonElement paramsObj)
    {
        var entry = new MealEntry
        {
            MealId = GetLong(paramsObj, "mealId"),
            ProductId = GetLong(paramsObj, "productId"),
            ProductName = GetString(paramsObj, "productName"),
            Grams = GetDouble(paramsObj, "grams"),
            Calories = GetDouble(paramsObj, "calories"),
            Protein = GetDouble(paramsObj, "protein"),
            Carbs = GetDouble(paramsObj, "carbs"),
            Fat = GetDouble(paramsObj, "fat")
        };
        
        var result = _meals!.AddEntry(entry);
        return JsonSerializer.Serialize(result);
    }

    private string DeleteMealEntry(long entryId)
    {
        _meals!.DeleteEntry(entryId);
        return "true";
    }

    private string GetWaterByDate(DateTime date)
    {
        var water = _water!.GetWaterByDate(date);
        return JsonSerializer.Serialize(water);
    }

    private string AddWaterIntake(DateTime date, int amountMl)
    {
        var result = _water!.AddWaterIntake(date, amountMl);
        return JsonSerializer.Serialize(result);
    }

    private string DeleteWaterIntake(long id)
    {
        _water!.DeleteWaterIntake(id);
        return "true";
    }

    private string GetWeightByDate(DateTime date)
    {
        var weight = _weight!.GetWeightByDate(date);
        return JsonSerializer.Serialize(weight);
    }

    private string GetWeightHistory(int days)
    {
        var history = _weight!.GetWeightHistory(days);
        return JsonSerializer.Serialize(history);
    }

    private string AddWeight(JsonElement paramsObj)
    {
        var result = _weight!.AddOrUpdateWeight(
            GetDateTime(paramsObj, "date"),
            GetDouble(paramsObj, "weightKg"),
            GetString(paramsObj, "note"));
        
        return JsonSerializer.Serialize(result);
    }

    private string DeleteWeight(long id)
    {
        _weight!.DeleteWeight(id);
        return "true";
    }

    private string GetGoals()
    {
        var goals = _goals!.GetGoals();
        return JsonSerializer.Serialize(goals);
    }

    private string UpdateGoals(JsonElement paramsObj)
    {
        var goals = new UserGoals
        {
            CaloriesPerDay = GetDouble(paramsObj, "caloriesPerDay"),
            ProteinPerDay = GetDouble(paramsObj, "proteinPerDay"),
            CarbsPerDay = GetDouble(paramsObj, "carbsPerDay"),
            FatPerDay = GetDouble(paramsObj, "fatPerDay"),
            WaterPerDayMl = GetInt(paramsObj, "waterPerDayMl"),
            TargetWeightKg = paramsObj.TryGetProperty("targetWeightKg", out var tw) && tw.ValueKind != JsonValueKind.Null 
                ? tw.GetDouble() 
                : null
        };
        
        _goals!.UpdateGoals(goals);
        return "true";
    }

    private string GetWeeklyStats(DateTime endDate)
    {
        var stats = _statistics!.GetWeeklyStats(endDate);
        return JsonSerializer.Serialize(stats);
    }

    private string CalculateEntry(JsonElement paramsObj)
    {
        var product = new Product
        {
            Id = GetLong(paramsObj, "productId"),
            Name = GetString(paramsObj, "productName"),
            CaloriesPer100g = GetDouble(paramsObj, "caloriesPer100g"),
            ProteinPer100g = GetDouble(paramsObj, "proteinPer100g"),
            CarbsPer100g = GetDouble(paramsObj, "carbsPer100g"),
            FatPer100g = GetDouble(paramsObj, "fatPer100g")
        };
        
        var grams = GetDouble(paramsObj, "grams");
        var entry = NutritionCalculator.CalculateEntry(product, grams);
        return JsonSerializer.Serialize(entry);
    }

    private static string CreateSuccessResponse(string result)
    {
        return JsonSerializer.Serialize(new { success = true, data = JsonSerializer.Deserialize<JsonElement>(result) });
    }

    private static string CreateErrorResponse(string error)
    {
        return JsonSerializer.Serialize(new { success = false, error });
    }

    private static string GetString(JsonElement el, string key, string defaultValue = "")
    {
        return el.TryGetProperty(key, out var prop) && prop.ValueKind == JsonValueKind.String 
            ? prop.GetString() ?? defaultValue 
            : defaultValue;
    }

    private static double GetDouble(JsonElement el, string key, double defaultValue = 0)
    {
        return el.TryGetProperty(key, out var prop) && prop.ValueKind == JsonValueKind.Number 
            ? prop.GetDouble() 
            : defaultValue;
    }

    private static long GetLong(JsonElement el, string key, long defaultValue = 0)
    {
        return el.TryGetProperty(key, out var prop) && prop.ValueKind == JsonValueKind.Number 
            ? prop.GetInt64() 
            : defaultValue;
    }

    private static int GetInt(JsonElement el, string key, int defaultValue = 0)
    {
        return el.TryGetProperty(key, out var prop) && prop.ValueKind == JsonValueKind.Number 
            ? prop.GetInt32() 
            : defaultValue;
    }

    private static DateTime GetDateTime(JsonElement el, string key)
    {
        var str = GetString(el, key);
        return DateTime.TryParse(str, out var dt) ? dt : DateTime.Now.Date;
    }

    public void Dispose()
    {
        _db?.Dispose();
    }
}

public static class FFIBindings
{
    private static FoodTrackerFFI? _instance;
    private static readonly object _lock = new();

    [UnmanagedCallersOnly(EntryPoint = "initialize")]
    public static int Initialize(IntPtr pathPtr, int pathLength)
    {
        try
        {
            var path = Marshal.PtrToStringAnsi(pathPtr, pathLength) ?? "food_tracker.db";
            _instance = new FoodTrackerFFI();
            _instance.Initialize(path);
            return 1;
        }
        catch
        {
            return 0;
        }
    }

    [UnmanagedCallersOnly(EntryPoint = "execute")]
    public static IntPtr Execute(IntPtr requestPtr, int requestLength)
    {
        try
        {
            var request = Marshal.PtrToStringAnsi(requestPtr, requestLength) ?? "{}";
            
            if (_instance == null)
            {
                var error = JsonSerializer.Serialize(new { success = false, error = "Not initialized" });
                return Marshal.StringToHGlobalAnsi(error);
            }
            
            var response = _instance.Execute(request);
            return Marshal.StringToHGlobalAnsi(response);
        }
        catch (Exception ex)
        {
            var error = JsonSerializer.Serialize(new { success = false, error = ex.Message });
            return Marshal.StringToHGlobalAnsi(error);
        }
    }

    [UnmanagedCallersOnly(EntryPoint = "dispose")]
    public static void Dispose()
    {
        _instance?.Dispose();
        _instance = null;
    }
}
