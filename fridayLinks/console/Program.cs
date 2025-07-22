using OpenLiveWriterPostCreator;

class Program
{
    static void Main(string[] args)
    {
        Console.WriteLine("OpenLive Writer Post Creator");
        Console.WriteLine("=============================");
        
        // Create a hardcoded blog post
        var post = new BlogPost
        {
            Title = "My Awesome Blog Post",
            BlogName = "Tech Adventures",
            Author = "John Developer",
            Content = @"<h2>Welcome to My Blog</h2>
<p>This is a sample blog post created programmatically using C#.</p>

<h3>Key Features</h3>
<ul>
<li><strong>Easy to use</strong> - Simple console application</li>
<li><strong>OpenLive Writer compatible</strong> - Saves in the correct format</li>
<li><strong>Rich content support</strong> - Full HTML formatting</li>
</ul>

<h3>Code Example</h3>
<pre><code>
public class BlogPost
{
    public string Title { get; set; }
    public string Content { get; set; }
    // More properties...
}
</code></pre>

<p>This post demonstrates how easy it is to create blog content programmatically!</p>

<blockquote>
<p>""Programming is not about what you know; it's about what you can figure out."" - Chris Pine</p>
</blockquote>

<p>Happy coding! 🚀</p>",
            Excerpt = "A sample blog post demonstrating programmatic content creation with C# and OpenLive Writer integration.",
            Categories = { "Programming", "C#", "Blogging" },
            Tags = { "csharp", "openlivewriter", "blogging", "programming", "tutorial" },
            IsDraft = false,
            CreatedDate = DateTime.Now
        };
        
        // Save the post
        var fileName = $"{SanitizeFileName(post.Title)}_{DateTime.Now:yyyyMMdd_HHmmss}.wpost";
        var draftsFolder = GetOpenLiveWriterDraftsFolder();
        var filePath = Path.Combine(draftsFolder, fileName);
        
        Console.WriteLine("Creating hardcoded blog post...");
        OpenLiveWriterPostGenerator.SavePost(post, filePath);
        
        Console.WriteLine($"\nBlog post saved successfully!");
        
        Console.WriteLine($"File: {filePath}");
        Console.WriteLine($"Post ID: {post.PostId}");
        Console.WriteLine($"Blog ID: {post.BlogId}");
        
        // Verify GUID formats
        Console.WriteLine($"Blog ID format check: {(post.BlogId.Length == 36 && post.BlogId.Count(c => c == '-') == 4 ? "✓ Valid" : "✗ Invalid")}");
        Console.WriteLine($"Post ID format check: {(post.PostId.Length == 36 && post.PostId.Count(c => c == '-') == 4 ? "✓ Valid" : "✗ Invalid")}");
        
        // Verify that the saved file is a valid compound document
        Console.WriteLine("\nVerifying saved file...");
        try
        {
            var fileBytes = File.ReadAllBytes(filePath);
            var signature = fileBytes.Take(8).ToArray();
            var expectedSignature = new byte[] { 0xD0, 0xCF, 0x11, 0xE0, 0xA1, 0xB1, 0x1A, 0xE1 };
            
            if (signature.SequenceEqual(expectedSignature))
            {
                Console.WriteLine("✓ File is a valid COM Structured Storage document");
                Console.WriteLine($"✓ File size: {fileBytes.Length} bytes");
                
                // Check if BlogId is a valid GUID
                if (Guid.TryParse(post.BlogId, out Guid blogGuid))
                {
                    Console.WriteLine($"✓ BlogId is a valid GUID: {blogGuid}");
                }
                else
                {
                    Console.WriteLine("✗ BlogId is NOT a valid GUID format");
                }
            }
            else
            {
                Console.WriteLine("✗ File does NOT have the correct compound document signature");
                Console.WriteLine($"Expected: {string.Join(" ", expectedSignature.Select(b => $"{b:X2}"))}");
                Console.WriteLine($"Actual:   {string.Join(" ", signature.Select(b => $"{b:X2}"))}");
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"✗ Error verifying file: {ex.Message}");
        }       
    }


    static string SanitizeFileName(string fileName)
    {
        var invalidChars = Path.GetInvalidFileNameChars();
        var sanitized = new string(fileName.Where(c => !invalidChars.Contains(c)).ToArray());
        return string.IsNullOrWhiteSpace(sanitized) ? "untitled" : sanitized;
    }

    static string GetOpenLiveWriterDraftsFolder()
    {
        // OpenLive Writer drafts are typically stored in:
        // %USERPROFILE%\Documents\My Weblog Posts\Drafts
        // or
        // %LOCALAPPDATA%\OpenLiveWriter\Drafts
        
        var userProfile = Environment.GetFolderPath(Environment.SpecialFolder.UserProfile);
        var documentsPath = Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments);
        var localAppData = Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData);
        
        // Try different possible locations for OpenLive Writer drafts
        var possiblePaths = new[]
        {
            Path.Combine(documentsPath, "My Weblog Posts", "Drafts"),
            Path.Combine(localAppData, "OpenLiveWriter", "Drafts"),
            Path.Combine(userProfile, "Documents", "My Weblog Posts", "Drafts"),
            Path.Combine(localAppData, "Open Live Writer", "Drafts")
        };
        
        foreach (var path in possiblePaths)
        {
            if (Directory.Exists(path))
            {
                Console.WriteLine($"Using existing OpenLive Writer drafts folder: {path}");
                return path;
            }
        }
        
        // If none exist, create the default one
        var defaultPath = Path.Combine(documentsPath, "My Weblog Posts", "Drafts");
        Console.WriteLine($"Creating OpenLive Writer drafts folder: {defaultPath}");
        Directory.CreateDirectory(defaultPath);
        return defaultPath;
    }
}
