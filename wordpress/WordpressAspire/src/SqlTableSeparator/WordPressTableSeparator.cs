using SqlTableSeparator;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace SqlTableSeparator;

public class WordPressPost
{
    public int ID { get; set; }
    public int PostAuthor { get; set; }
    public DateTime PostDate { get; set; }
    public DateTime PostDateGmt { get; set; }
    public string PostContent { get; set; } = string.Empty;
    public string PostTitle { get; set; } = string.Empty;
    public int PostCategory { get; set; }
    public string PostExcerpt { get; set; } = string.Empty;
    public string PostStatus { get; set; } = string.Empty;
    public string CommentStatus { get; set; } = string.Empty;
    public string PingStatus { get; set; } = string.Empty;
    public string PostPassword { get; set; } = string.Empty;
    public string PostName { get; set; } = string.Empty;
    public string ToPing { get; set; } = string.Empty;
    public string Pinged { get; set; } = string.Empty;
    public DateTime PostModified { get; set; }
    public DateTime PostModifiedGmt { get; set; }
    public string PostContentFiltered { get; set; } = string.Empty;
    public int PostParent { get; set; }
    public string Guid { get; set; } = string.Empty;
    public int MenuOrder { get; set; }
    public string PostType { get; set; } = string.Empty;
    public string PostMimeType { get; set; } = string.Empty;
    public int CommentCount { get; set; }
}



public class WordPressTableSeparator
{

    public PostCategoryInfo RewriteWpPostSql(string line)
    {
        return new PostCategoryInfo
        {
            NewInsert = line,
            PostId = "",
            PostCategory = ""
        };
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
