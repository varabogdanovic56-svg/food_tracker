using FoodLogic.Core.Models;
using Microsoft.Data.Sqlite;

namespace FoodLogic.Core.Services;

public class ProductRepository
{
    private readonly DatabaseService _db;

    public ProductRepository(DatabaseService db)
    {
        _db = db;
    }

    public List<Product> GetAll()
    {
        var products = new List<Product>();
        var conn = _db.GetDb();
        
        using var cmd = new SqliteCommand("SELECT * FROM Products ORDER BY Name", conn);
        using var reader = cmd.ExecuteReader();
        
        while (reader.Read())
        {
            products.Add(MapProduct(reader));
        }
        
        return products;
    }

    public List<Product> Search(string query)
    {
        var products = new List<Product>();
        var conn = _db.GetDb();
        
        using var cmd = new SqliteCommand(
            "SELECT * FROM Products WHERE Name LIKE @query ORDER BY Name LIMIT 50", conn);
        cmd.Parameters.AddWithValue("@query", $"%{query}%");
        
        using var reader = cmd.ExecuteReader();
        
        while (reader.Read())
        {
            products.Add(MapProduct(reader));
        }
        
        return products;
    }

    public Product? GetById(long id)
    {
        var conn = _db.GetDb();
        
        using var cmd = new SqliteCommand("SELECT * FROM Products WHERE Id = @id", conn);
        cmd.Parameters.AddWithValue("@id", id);
        
        using var reader = cmd.ExecuteReader();
        
        if (reader.Read())
        {
            return MapProduct(reader);
        }
        
        return null;
    }

    public Product Add(Product product)
    {
        var conn = _db.GetDb();
        
        using var cmd = new SqliteCommand(@"
            INSERT INTO Products (Name, CaloriesPer100g, ProteinPer100g, CarbsPer100g, FatPer100g, DefaultGrams, Category, IsCustom, CreatedAt)
            VALUES (@name, @cal, @prot, @carbs, @fat, @grams, @cat, 1, @created);
            SELECT last_insert_rowid();", conn);
        
        cmd.Parameters.AddWithValue("@name", product.Name);
        cmd.Parameters.AddWithValue("@cal", product.CaloriesPer100g);
        cmd.Parameters.AddWithValue("@prot", product.ProteinPer100g);
        cmd.Parameters.AddWithValue("@carbs", product.CarbsPer100g);
        cmd.Parameters.AddWithValue("@fat", product.FatPer100g);
        cmd.Parameters.AddWithValue("@grams", product.DefaultGrams);
        cmd.Parameters.AddWithValue("@cat", product.Category ?? (object)DBNull.Value);
        cmd.Parameters.AddWithValue("@created", DateTime.UtcNow.ToString("o"));
        
        product.Id = Convert.ToInt64(cmd.ExecuteScalar());
        product.IsCustom = true;
        product.CreatedAt = DateTime.UtcNow;
        
        return product;
    }

    public void Update(Product product)
    {
        var conn = _db.GetDb();
        
        using var cmd = new SqliteCommand(@"
            UPDATE Products 
            SET Name = @name, CaloriesPer100g = @cal, ProteinPer100g = @prot, 
                CarbsPer100g = @carbs, FatPer100g = @fat, DefaultGrams = @grams, Category = @cat
            WHERE Id = @id", conn);
        
        cmd.Parameters.AddWithValue("@id", product.Id);
        cmd.Parameters.AddWithValue("@name", product.Name);
        cmd.Parameters.AddWithValue("@cal", product.CaloriesPer100g);
        cmd.Parameters.AddWithValue("@prot", product.ProteinPer100g);
        cmd.Parameters.AddWithValue("@carbs", product.CarbsPer100g);
        cmd.Parameters.AddWithValue("@fat", product.FatPer100g);
        cmd.Parameters.AddWithValue("@grams", product.DefaultGrams);
        cmd.Parameters.AddWithValue("@cat", product.Category ?? (object)DBNull.Value);
        
        cmd.ExecuteNonQuery();
    }

    public void Delete(long id)
    {
        var conn = _db.GetDb();
        
        using var cmd = new SqliteCommand("DELETE FROM Products WHERE Id = @id AND IsCustom = 1", conn);
        cmd.Parameters.AddWithValue("@id", id);
        cmd.ExecuteNonQuery();
    }

    private static Product MapProduct(SqliteDataReader reader)
    {
        return new Product
        {
            Id = reader.GetInt64(0),
            Name = reader.GetString(1),
            CaloriesPer100g = reader.GetDouble(2),
            ProteinPer100g = reader.GetDouble(3),
            CarbsPer100g = reader.GetDouble(4),
            FatPer100g = reader.GetDouble(5),
            DefaultGrams = reader.IsDBNull(6) ? 100 : reader.GetDouble(6),
            Category = reader.IsDBNull(7) ? null : reader.GetString(7),
            IsCustom = reader.GetInt32(8) == 1,
            CreatedAt = DateTime.Parse(reader.GetString(9))
        };
    }
}
