using Mysqlx.Crud;
using SqlTableSeparator;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace SqlTableSeparator;



public class WordPressTableSeparator
{

    public PostCategoryInfo RewriteWpPostSql(string line)
    {
        if(string.IsNullOrWhiteSpace(line))
            throw new ArgumentException("Insert statement cannot be null or empty", nameof(line));
        var pci=new PostCategoryInfo();
        var post = pci.ParseInsertStatement(line);
        var insert = "INSERT INTO `wp_posts`(";
        insert += "`ID`, `post_author`, `post_date`, `post_date_gmt`, " +
            "`post_content`, `post_title`, `post_excerpt`," +
            " `post_status`, `comment_status`, `ping_status`, `post_password`, " +
            "`post_name`, `to_ping`, `pinged`, `post_modified`," +
            " `post_modified_gmt`, `post_content_filtered`, `post_parent`, " +
            "`guid`, `menu_order`, `post_type`, `post_mime_type`, `comment_count`) ";
        insert+="VALUES (";
        insert += $"{post.ID}, {post.PostAuthor}, '{post.PostDate.ToString("yyyy-MM-dd HH:mm:ss")}', '{post.PostDateGmt.ToString("yyyy-MM-dd HH:mm:ss")}', ";
        insert += $"'{post.PostContent.Replace("'", "\'")}', '{post.PostTitle.Replace("'", "\'")}', '{post.PostExcerpt.Replace("'", "\'")}', ";
        insert += $"'{post.PostStatus}', '{post.CommentStatus}', '{post.PingStatus}', '{post.PostPassword}', ";
        insert += $"'{post.PostName}', '{post.ToPing}', '{post.Pinged}', '{post.PostModified.ToString("yyyy-MM-dd HH:mm:ss")}', ";
        insert += $"'{post.PostModifiedGmt.ToString("yyyy-MM-dd HH:mm:ss")}', '{post.PostContentFiltered.Replace("'", "\'")}', {post.PostParent}, ";
        insert += $"'{post.Guid}', {post.MenuOrder}, '{post.PostType}', '{post.PostMimeType}', {post.CommentCount}";
        insert +=")";
        return new PostCategoryInfo
        {
            NewInsert = insert,
            PostId = post.ID.ToString(),
            PostCategory = post.PostCategory.ToString()
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
