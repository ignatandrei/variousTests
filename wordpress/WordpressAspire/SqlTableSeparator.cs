using System;
using System.Collections.Generic;
using System.IO;
using System.Text.RegularExpressions;

class SqlTableSeparator
{
    static void Main(string[] args)
    {
        string sqlFilePath = @"D:\eu\cursor\WordpressAspire\backup\gratiwd.sql";
        string outputDirectory = @"D:\eu\cursor\WordpressAspire\backup\separated_tables";
        
        // Create output directory if it doesn't exist
        if (!Directory.Exists(outputDirectory))
        {
            Directory.CreateDirectory(outputDirectory);
        }
        
        // Dictionary to store table content
        Dictionary<string, List<string>> tableContents = new Dictionary<string, List<string>>();
        string currentTable = null;
        bool inTableDefinition = false;
        int braceCount = 0;
        
        // Regex patterns
        Regex createTablePattern = new Regex(@"CREATE TABLE `([^`]+)`", RegexOptions.IgnoreCase);
        Regex insertPattern = new Regex(@"INSERT INTO `([^`]+)`", RegexOptions.IgnoreCase);
        
        try
        {
            Console.WriteLine($"Reading SQL file: {sqlFilePath}");
            Console.WriteLine($"Output directory: {outputDirectory}");
            
            using (StreamReader reader = new StreamReader(sqlFilePath))
            {
                string line;
                int lineNumber = 0;
                
                while ((line = reader.ReadLine()) != null)
                {
                    lineNumber++;
                    
                    // Check for CREATE TABLE statement
                    Match createMatch = createTablePattern.Match(line);
                    if (createMatch.Success)
                    {
                        currentTable = createMatch.Groups[1].Value;
                        inTableDefinition = true;
                        braceCount = 0;
                        
                        Console.WriteLine($"Found table: {currentTable} at line {lineNumber}");
                        
                        if (!tableContents.ContainsKey(currentTable))
                        {
                            tableContents[currentTable] = new List<string>();
                        }
                        tableContents[currentTable].Add(line);
                        continue;
                    }
                    
                    // Check for INSERT statement
                    Match insertMatch = insertPattern.Match(line);
                    if (insertMatch.Success)
                    {
                        string tableName = insertMatch.Groups[1].Value;
                        
                        if (!tableContents.ContainsKey(tableName))
                        {
                            tableContents[tableName] = new List<string>();
                        }
                        tableContents[tableName].Add(line);
                        continue;
                    }
                    
                    // Handle table definition closing
                    if (inTableDefinition && currentTable != null)
                    {
                        // Count braces to detect end of table definition
                        braceCount += CountChar(line, '(');
                        braceCount -= CountChar(line, ')');
                        
                        tableContents[currentTable].Add(line);
                        
                        // If we've closed all braces, we're done with the table definition
                        if (braceCount <= 0)
                        {
                            inTableDefinition = false;
                            currentTable = null;
                        }
                        continue;
                    }
                    
                    // If we're currently processing a table, add the line to it
                    if (currentTable != null && tableContents.ContainsKey(currentTable))
                    {
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
        }
    }
    
    static int CountChar(string text, char character)
    {
        int count = 0;
        foreach (char c in text)
        {
            if (c == character) count++;
        }
        return count;
    }
} 