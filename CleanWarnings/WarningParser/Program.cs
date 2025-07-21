using WarningParser.Services;
using WarningParser.Models;

namespace WarningParser
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("Warning Parser - Parsing cleanWarnings.txt file");
            Console.WriteLine("=".PadRight(50, '='));
            
            try
            {
                // Initialize services
                var parser = new FileParser();
                var outputGenerator = new OutputGenerator();
                
                // Define file paths
                var inputFile = Path.Combine("..", "cleanWarnings.txt");
                var htmlOutput = "parsed_results.html";
                var jsonOutput = "parsed_results.json";
                
                // Check if input file exists
                if (!File.Exists(inputFile))
                {
                    Console.WriteLine($"Error: Input file '{inputFile}' not found.");
                    Console.WriteLine("Please ensure cleanWarnings.txt is in the parent directory.");
                    return;
                }
                
                Console.WriteLine($"Reading file: {inputFile}");
                
                // Parse the file
                var prompts = parser.ParseFile(inputFile);
                
                Console.WriteLine($"Parsed {prompts.Count} prompts successfully.");
                
                // Generate console output
                outputGenerator.GenerateConsoleOutput(prompts);
                
                // Generate HTML output
                outputGenerator.GenerateHtmlOutput(prompts, htmlOutput);
                Console.WriteLine($"\nHTML output generated: {htmlOutput}");
                
                // Generate JSON output
                outputGenerator.GenerateJsonOutput(prompts, jsonOutput);
                Console.WriteLine($"JSON output generated: {jsonOutput}");
                
                // Try to open HTML file in browser
                try
                {
                    var htmlPath = Path.GetFullPath(htmlOutput);
                    Console.WriteLine($"\nOpening HTML file in browser: {htmlPath}");
                    System.Diagnostics.Process.Start(new System.Diagnostics.ProcessStartInfo
                    {
                        FileName = htmlPath,
                        UseShellExecute = true
                    });
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"Could not open browser automatically: {ex.Message}");
                    Console.WriteLine($"Please open {htmlOutput} manually in your browser.");
                }
                
                Console.WriteLine("\nParsing completed successfully!");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error: {ex.Message}");
                Console.WriteLine($"Stack trace: {ex.StackTrace}");
            }
            
            //Console.WriteLine("\nPress any key to exit...");
            //Console.ReadKey();
        }
    }
}
