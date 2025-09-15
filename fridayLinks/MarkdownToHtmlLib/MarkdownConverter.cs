using System;
using Markdig;

namespace MarkdownToHtmlLib
{
    public static class MarkdownConverter
    {
        /// <summary>
        /// Converts markdown text to HTML.
        /// </summary>
        /// <param name="markdown">The markdown string to convert.</param>
        /// <returns>The HTML string.</returns>
        public static string ToHtml(string markdown)
        {
            if (string.IsNullOrEmpty(markdown))
                return string.Empty;
            return Markdown.ToHtml(markdown);
        }
    }
}
