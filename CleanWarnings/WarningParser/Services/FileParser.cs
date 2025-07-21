using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using WarningParser.Models;

namespace WarningParser.Services
{
    public class FileParser
    {
        public List<PromptData> ParseFile(string filePath)
        {
            var prompts = new List<PromptData>();
            var lines = File.ReadAllLines(filePath);
            
            PromptData? currentPrompt = null;
            var promptId = 1;
            
            for (int i = 0; i < lines.Length; i++)
            {
                var line = lines[i].Trim();
                
                if (line.StartsWith("--prompt"))
                {
                    // Save previous prompt if exists
                    if (currentPrompt != null)
                    {
                        prompts.Add(currentPrompt);
                    }
                    
                    // Start new prompt
                    currentPrompt = new PromptData
                    {
                        Id = promptId++,
                        LineNumber = i + 1,
                        Content = string.Empty
                    };
                }
                else if (line.Contains("--intermezzo") && currentPrompt != null)
                {
                    // Start collecting intermezzo content
                    var intermezzoContent = new List<string>();
                    i++; // Move to next line
                    
                    // Collect all lines until next section
                    while (i < lines.Length)
                    {
                        var nextLine = lines[i].Trim();
                        
                        // Check if we've reached the next section
                        if (nextLine.StartsWith("--prompt") || 
                            nextLine.Contains("--intermezzo") 
                            )
                        {
                            i--; // Go back one line so the outer loop can process it
                            break;
                        }
                        
                        if (!string.IsNullOrEmpty(nextLine))
                        {
                            intermezzoContent.Add(nextLine);
                        }
                        
                        i++;
                    }
                    
                    if (intermezzoContent.Any())
                    {
                        currentPrompt.Intermezzos.Add(string.Join(Environment.NewLine, intermezzoContent));
                    }
                }
                else if (currentPrompt != null && !string.IsNullOrEmpty(line))
                {
                    // Add content to current prompt
                    if (!string.IsNullOrEmpty(currentPrompt.Content))
                    {
                        currentPrompt.Content += Environment.NewLine;
                    }
                    currentPrompt.Content += line;
                }
            }
            
            // Add the last prompt if exists
            if (currentPrompt != null)
            {
                prompts.Add(currentPrompt);
            }
            
            return prompts;
        }
    }
} 