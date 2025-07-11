using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace SqlTableSeparator;

public class PostCategoryInfo
{
    public string NewInsert { get; set; } = string.Empty;
    public string PostId { get; set; } = string.Empty;
    public string PostCategory { get; set; } = string.Empty;
}

public class WordPressTableSeparator
{

    public PostCategoryInfo  RewriteWpPostSql(string line)
    {
        Regex wpPostsInsertPattern = new Regex(@"INSERT INTO `wp_posts`\s*\(([^)]+)\)\s*VALUES\s*\(([^)]+)\)", RegexOptions.IgnoreCase);
        var wpPostsMatch = wpPostsInsertPattern.Match(line);
        //if (wpPostsMatch.Success)
        //{
            var columns = wpPostsMatch.Groups[1].Value.Split(',').Select(s => s.Trim(' ', '`')).ToList();
            var values = wpPostsMatch.Groups[2].Value.Split(',').Select(s => s.Trim()).ToList();
            int postCategoryIdx = columns.IndexOf("post_category");
            int idIdx = columns.IndexOf("ID");
            // Remove post_category from columns/values for new insert
            //if (postCategoryIdx != -1)
            //{
                var p = (new PostCategoryInfo
                {
                    PostId = values[idIdx],
                    PostCategory = values[postCategoryIdx]
                });
                columns.RemoveAt(postCategoryIdx);
                values.RemoveAt(postCategoryIdx);
            //}
            // Add single quotes to all values
            for (int i = 0; i < values.Count; i++)
            {
                if (!values[i].StartsWith("'"))
                    values[i] = "'" + values[i].Trim('"', '\'') + "'";
            }
            // Rebuild the insert statement
            p.NewInsert = $"INSERT INTO `wp_posts`({string.Join(", ", columns.Select(c => "`" + c + "`"))}) VALUES ({string.Join(",", values)});";
        //}
        return p;
    }

    public bool Separate(string sqlFilePath , string outputDirectory)
    {

        // Create output directory if it doesn't exist
        if (!Directory.Exists(outputDirectory))
        {
            Directory.CreateDirectory(outputDirectory);
        }

        // Dictionary to store table content
        Dictionary<string, List<string>> tableContents = new Dictionary<string, List<string>>();
        string currentTable = "";
        bool inTableDefinition = false;

        // Regex patterns
        Regex createTablePattern = new Regex(@"CREATE TABLE `([^`]+)`", RegexOptions.IgnoreCase);
        Regex insertPattern = new Regex(@"INSERT INTO `([^`]+)`", RegexOptions.IgnoreCase);
        
        try
        {
            Console.WriteLine($"Reading SQL file: {sqlFilePath}");
            Console.WriteLine($"Output directory: {outputDirectory}");

            using (StreamReader reader = new StreamReader(sqlFilePath))
            {
                string? line;
                int lineNumber = 0;

                while ((line = reader.ReadLine()) != null)
                {
                    
                    lineNumber++;
                    if (string.IsNullOrWhiteSpace(line)) continue;
                    line = line.Trim();
                    // Check for CREATE TABLE statement
                    Match createMatch = createTablePattern.Match(line);
                    if (createMatch.Success)
                    {
                        currentTable = createMatch.Groups[1].Value;
                        inTableDefinition = true;

                        Console.WriteLine($"Found table: {currentTable} at line {lineNumber}");

                        if (!tableContents.ContainsKey(currentTable))
                        {
                            tableContents[currentTable] = new List<string>();
                        }
                        //tableContents[currentTable].Add(line);
                        continue;
                    }

                    // Check for INSERT statement
                    Match insertMatch = insertPattern.Match(line);
                    if (insertMatch.Success)
                    {
                        inTableDefinition = false;
                        string tableName = insertMatch.Groups[1].Value;

                        if (!tableContents.ContainsKey(tableName))
                        {
                            tableContents[tableName] = new List<string>();
                        }
                        tableContents[tableName].Add(line);
                        continue;
                    }

                    // Check for INSERT INTO wp_posts
                    
                    // Handle table definition closing - look for semicolon
                    if (inTableDefinition && currentTable != "")
                    {
                        if (!inTableDefinition)
                            tableContents[currentTable].Add(line);

                        // If we find a semicolon, we're done with the table definition
                        if (line.Trim().EndsWith(";"))
                        {
                            inTableDefinition = false;
                            currentTable = "";
                        }
                        continue;
                    }

                    // If we're currently processing a table, add the line to it
                    if (currentTable != "" && tableContents.ContainsKey(currentTable))
                    {
                        if(!inTableDefinition)
                        tableContents[currentTable].Add(line);
                    }
                }
            }

            // Write each table to a separate file
            Console.WriteLine("\nWriting table files...");
            foreach (var table in tableContents)
            {
                string fileName = $"{table.Key}.sql";
                string filePath = Path.Combine(outputDirectory, fileName);

                using (StreamWriter writer = new StreamWriter(filePath))
                {
                    foreach (string line in table.Value)
                    {
                        writer.WriteLine(line);
                    }
                }

                Console.WriteLine($"Created: {fileName} ({table.Value.Count} lines)");
            }

            Console.WriteLine($"\nProcess completed successfully!");
            Console.WriteLine($"Total tables found: {tableContents.Count}");
            Console.WriteLine($"Files created in: {outputDirectory}");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error: {ex.Message}");
            return false;
        }
        return true;
    }
}
