using MySql.Data.MySqlClient;
using System;

namespace SqlTableSeparator;

public class MySqlDatabaseRepo
{
    private readonly string _connectionString;

    public MySqlDatabaseRepo(string connectionString)
    {
        _connectionString = connectionString;
    }

    public async Task<bool> Execute(string sqlCommand)
    {
        try
        {
            using var connection = new MySqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new MySqlCommand(sqlCommand, connection);
            await command.ExecuteNonQueryAsync();
            return true;
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error executing SQL command: {ex.Message}");
            throw;
        }
    }

    public async Task<bool> TestConnection()
    {
        try
        {
            using var connection = new MySqlConnection(_connectionString);
            await connection.OpenAsync();
            return true;
        }
        catch 
        {
            
            return false;
        }
    }
    internal async Task ExecuteFromSeparateTables(string outputDirectory)
    {
        await ExecutePosts(outputDirectory);
        await ExecuteTerms(outputDirectory);
        await ExecuteComments(outputDirectory);
    }

    private async Task ExecuteComments(string outputDirectory)
    {
        var sqlCommand = Path.Combine(outputDirectory, "wp_comments.sql");
        if (File.Exists(sqlCommand))
        {
            var sql = File.ReadAllText(sqlCommand);
            sql = "Delete from `wp_comments`;" + Environment.NewLine + sql;
            var result = await this.Execute(sql);
            Console.WriteLine($"SQL Command {sqlCommand} executed successfully: {result}");
        }
        else
        {
            Console.WriteLine($"SQL file not found: {sqlCommand}");
        }

    }

    private async Task ExecuteTerms(string outputDirectory)
    {
        var sqlCommand = Path.Combine(outputDirectory, "wp_terms.sql");
        if (File.Exists(sqlCommand))
        {
            var sql = File.ReadAllText(sqlCommand);
            sql = "Delete from `wp_terms`;" + Environment.NewLine + sql;
            var result = await this.Execute(sql);
            Console.WriteLine($"SQL Command {sqlCommand} executed successfully: {result}");
        }
        else
        {
            Console.WriteLine($"SQL file not found: {sqlCommand}");
        }
        sqlCommand = Path.Combine(outputDirectory, "wp_term_taxonomy.sql");
        if (File.Exists(sqlCommand))
        {
            var sql = File.ReadAllText(sqlCommand);
            sql = "Delete from `wp_term_taxonomy`;" + Environment.NewLine + sql;
            var result = await this.Execute(sql);
            Console.WriteLine($"SQL Command {sqlCommand} executed successfully: {result}");
        }
        else
        {
            Console.WriteLine($"SQL file not found: {sqlCommand}");
        }

        sqlCommand = Path.Combine(outputDirectory, "wp_term_relationships.sql");
        if (File.Exists(sqlCommand))
        {
            var sql = File.ReadAllText(sqlCommand);
            sql = "Delete from `wp_term_relationships`;" + Environment.NewLine + sql;
            var result = await this.Execute(sql);
            Console.WriteLine($"SQL Command {sqlCommand} executed successfully: {result}");
        }
        else
        {
            Console.WriteLine($"SQL file not found: {sqlCommand}");
        }

    }

    internal async Task ExecutePosts(string outputDirectory)
    {
        var sep = new WordPressTableSeparator();
        var sqlCommand = Path.Combine(outputDirectory, "wp_posts.sql");
        if (File.Exists(sqlCommand))
        {
            var sql = File.ReadAllText(sqlCommand);
            var result = await this.Execute("Delete from `wp_posts`;");
            sql = sql.Replace("0000-00-00 00:00:00", "2099-01-01 01:01:01");
            foreach (var line in sql.Split(Environment.NewLine))
            {
                if(string.IsNullOrWhiteSpace(line) || line.Trim().StartsWith("--") || line.Trim().StartsWith("#"))
                {
                    continue; // Skip empty lines and comments
                }
                var lineSql = ""; 

                try
                {
                    lineSql= sep.RewriteWpPostSql(line).NewInsert;
                    result = await this.Execute(lineSql);
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"Error executing line: \r\n {lineSql} \r\n from \r\n {line} \r\n. Exception: {ex.Message}");
                    throw;
                }

            }
            Console.WriteLine($"SQL Command {sqlCommand} executed successfully:");
        }
        else
        {
            Console.WriteLine($"SQL file not found: {sqlCommand}");
        }
    }
}
