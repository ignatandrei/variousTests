using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;

public class Bookmark
{
    public string Url { get; set; } = string.Empty;
    public string Title { get; set; } = string.Empty;
    public string Target { get; set; } = string.Empty;
}

public class BookmarkCollection
{
    public List<Bookmark> Bookmarks { get; set; } = new List<Bookmark>();
    public int ListIndex { get; set; }
}

public class BookmarkParser
{
    public static List<BookmarkCollection> ParseBookmarksFromFile(string filePath)
    {
        var content = File.ReadAllText(filePath);
        return ParseBookmarks(content);
    }

    public static List<BookmarkCollection> ParseBookmarks(string htmlContent)
    {
        var collections = new List<BookmarkCollection>();
        
        // Pattern to match OL blocks
        var olPattern = @"<OL>(.*?)</OL>";
        var olMatches = Regex.Matches(htmlContent, olPattern, RegexOptions.Singleline | RegexOptions.IgnoreCase);
        
        for (int i = 0; i < olMatches.Count; i++)
        {
            var olContent = olMatches[i].Groups[1].Value;
            var bookmarks = ParseListItems(olContent);
            
            collections.Add(new BookmarkCollection
            {
                Bookmarks = bookmarks,
                ListIndex = i + 1
            });
        }
        
        return collections;
    }

    private static List<Bookmark> ParseListItems(string olContent)
    {
        var bookmarks = new List<Bookmark>();
        
        // Pattern to match LI elements with anchor tags
        var liPattern = @"<li><a\s+href=""([^""]*)""\s*(?:target=""([^""]*)"")?\s*>([^<]*)</a></li>";
        var liMatches = Regex.Matches(olContent, liPattern, RegexOptions.IgnoreCase);
        
        foreach (Match match in liMatches)
        {
            var bookmark = new Bookmark
            {
                Url = match.Groups[1].Value.Trim(),
                Target = match.Groups[2].Value.Trim(),
                Title = match.Groups[3].Value.Trim()
            };
            
            bookmarks.Add(bookmark);
        }
        
        return bookmarks;
    }

    public static void PrintBookmarks(List<BookmarkCollection> collections)
    {
        foreach (var collection in collections)
        {
            Console.WriteLine($"\n=== Bookmark List {collection.ListIndex} ({collection.Bookmarks.Count} items) ===");
            
            for (int i = 0; i < collection.Bookmarks.Count; i++)
            {
                var bookmark = collection.Bookmarks[i];
                Console.WriteLine($"{i + 1}. {bookmark.Title}");
                Console.WriteLine($"   URL: {bookmark.Url}");
                if (!string.IsNullOrEmpty(bookmark.Target))
                {
                    Console.WriteLine($"   Target: {bookmark.Target}");
                }
                Console.WriteLine();
            }
        }
    }


}