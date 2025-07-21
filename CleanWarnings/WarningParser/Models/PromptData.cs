using System.Collections.Generic;

namespace WarningParser.Models
{
    public class PromptData
    {
        public int Id { get; set; }
        public string Content { get; set; } = string.Empty;
        public List<string> Intermezzos { get; set; } = new List<string>();
        public int LineNumber { get; set; }
        
        public override string ToString()
        {
            return $"Prompt {Id} (Line {LineNumber}): {Content.Substring(0, Math.Min(100, Content.Length))}...";
        }
    }
} 