using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Text.Encodings.Web;
using WarningParser.Models;

namespace WarningParser.Services
{
    public class OutputGenerator
    {
        public void GenerateConsoleOutput(List<PromptData> prompts)
        {
            Console.WriteLine("=== WARNING PARSER RESULTS ===\n");
            
            foreach (var prompt in prompts)
            {
                Console.WriteLine($"Prompt #{prompt.Id} (Line {prompt.LineNumber})");
                Console.WriteLine("=".PadRight(50, '='));
                Console.WriteLine(prompt.Content);
                Console.WriteLine();
                
                if (prompt.Intermezzos.Any())
                {
                    Console.WriteLine($"Associated Intermezzos ({prompt.Intermezzos.Count}):");
                    Console.WriteLine("-".PadRight(30, '-'));
                    
                    for (int i = 0; i < prompt.Intermezzos.Count; i++)
                    {
                        Console.WriteLine($"Intermezzo {i + 1}:");
                        Console.WriteLine(prompt.Intermezzos[i]);
                        Console.WriteLine();
                    }
                }
                else
                {
                    Console.WriteLine("No associated intermezzos.");
                }
                
                Console.WriteLine(new string('=', 60));
                Console.WriteLine();
            }
            
            Console.WriteLine($"Total Prompts: {prompts.Count}");
            Console.WriteLine($"Total Intermezzos: {prompts.Sum(p => p.Intermezzos.Count)}");
        }
        
        public void GenerateHtmlOutput(List<PromptData> prompts, string outputPath)
        {
            
            var html = new StringBuilder();
            
            html.AppendLine("<!DOCTYPE html>");
            html.AppendLine("<html lang=\"en\">");
            html.AppendLine("<head>");
            html.AppendLine("    <meta charset=\"UTF-8\">");
            html.AppendLine("    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">");
            html.AppendLine("    <title>Warning Parser Results</title>");
            html.AppendLine("    <style>");
            html.AppendLine("        body { font-family: Arial, sans-serif; margin: 20px; background-color: #f5f5f5; }");
            html.AppendLine("        .container { max-width: 1200px; margin: 0 auto; background-color: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }");
            html.AppendLine("        .prompt { margin-bottom: 30px; border: 1px solid #ddd; border-radius: 5px; padding: 15px; }");
            html.AppendLine("        .prompt-header { background-color: #007acc; color: white; padding: 10px; margin: -15px -15px 15px -15px; border-radius: 5px 5px 0 0; }");
            html.AppendLine("        .prompt-content { background-color: #f9f9f9; padding: 10px; border-radius: 3px; margin-bottom: 15px; white-space: pre-wrap; }");
            html.AppendLine("        .intermezzo { background-color: #fff3cd; border: 1px solid #ffeaa7; border-radius: 3px; padding: 10px; margin: 10px 0; }");
            html.AppendLine("        .intermezzo-header { font-weight: bold; color: #856404; margin-bottom: 5px; }");
            html.AppendLine("        .summary { background-color: #d4edda; border: 1px solid #c3e6cb; border-radius: 5px; padding: 15px; margin-top: 20px; }");
            html.AppendLine("        .no-intermezzo { color: #6c757d; font-style: italic; }");
            html.AppendLine("    </style>");
            html.AppendLine("</head>");
            html.AppendLine("<body>");
            html.AppendLine("    <div class=\"container\">");
            html.AppendLine("        <h1>Warning Parser Results</h1>");
            
            foreach (var prompt in prompts)
            {
                html.AppendLine("        <div class=\"prompt\">");
                html.AppendLine($"            <div class=\"prompt-header\">Prompt #{prompt.Id} (Line {prompt.LineNumber})</div>");
                html.AppendLine("            <div class=\"prompt-content\">");
                html.AppendLine(HtmlEncoder.Default.Encode(prompt.Content));
                html.AppendLine("            </div>");
                
                if (prompt.Intermezzos.Any())
                {
                    html.AppendLine($"            <div class=\"intermezzo-header\">Associated Intermezzos ({prompt.Intermezzos.Count}):</div>");
                    
                    for (int i = 0; i < prompt.Intermezzos.Count; i++)
                    {
                        html.AppendLine("            <div class=\"intermezzo\">");
                        html.AppendLine($"                <strong>Intermezzo {i + 1}:</strong><br>");
                        html.AppendLine(HtmlEncoder.Default.Encode(prompt.Intermezzos[i]).Replace("\n", "<br>"));
                        html.AppendLine("            </div>");
                    }
                }
                else
                {
                    html.AppendLine("            <div class=\"no-intermezzo\">No associated intermezzos.</div>");
                }
                
                html.AppendLine("        </div>");
            }
            
            html.AppendLine("        <div class=\"summary\">");
            html.AppendLine($"            <strong>Summary:</strong><br>");
            html.AppendLine($"            Total Prompts: {prompts.Count}<br>");
            html.AppendLine($"            Total Intermezzos: {prompts.Sum(p => p.Intermezzos.Count)}<br>");
            html.AppendLine($"            Prompts with Intermezzos: {prompts.Count(p => p.Intermezzos.Any())}<br>");
            html.AppendLine($"            Prompts without Intermezzos: {prompts.Count(p => !p.Intermezzos.Any())}");
            html.AppendLine("        </div>");
            
            html.AppendLine("    </div>");
            html.AppendLine("</body>");
            html.AppendLine("</html>");
            var template = new blog(prompts);
            
            File.WriteAllText(outputPath, template.Render());
        }
        
        public void GenerateJsonOutput(List<PromptData> prompts, string outputPath)
        {
            var json = System.Text.Json.JsonSerializer.Serialize(prompts, new System.Text.Json.JsonSerializerOptions
            {
                WriteIndented = true
            });
            
            File.WriteAllText(outputPath, json);
        }
    }
} 