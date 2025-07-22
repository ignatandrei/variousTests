using System.Xml.Linq;
using System.Runtime.InteropServices;
using System.Text;

namespace OpenLiveWriterPostCreator;

// COM Structured Storage interop declarations
[ComImport]
[Guid("0000000b-0000-0000-C000-000000000046")]
[InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
internal interface IStorage
{
    void CreateStream(string pwcsName, uint grfMode, uint reserved1, uint reserved2, out IStream ppstm);
    void OpenStream(string pwcsName, IntPtr reserved1, uint grfMode, uint reserved2, out IStream ppstm);
    void CreateStorage(string pwcsName, uint grfMode, uint reserved1, uint reserved2, out IStorage ppstg);
    void OpenStorage(string pwcsName, IStorage? pstgPriority, uint grfMode, IntPtr snbExclude, uint reserved, out IStorage ppstg);
    void CopyTo(uint ciidExclude, Guid[] rgiidExclude, IntPtr snbExclude, IStorage pstgDest);
    void MoveElementTo(string pwcsName, IStorage pstgDest, string pwcsNewName, uint grfFlags);
    void Commit(uint grfCommitFlags);
    void Revert();
    void EnumElements(uint reserved1, IntPtr reserved2, uint reserved3, out IEnumSTATSTG ppenum);
    void DestroyElement(string pwcsName);
    void RenameElement(string pwcsOldName, string pwcsNewName);
    void SetElementTimes(string pwcsName, System.Runtime.InteropServices.ComTypes.FILETIME pctime, System.Runtime.InteropServices.ComTypes.FILETIME patime, System.Runtime.InteropServices.ComTypes.FILETIME pmtime);
    void SetClass(ref Guid clsid);
    void SetStateBits(uint grfStateBits, uint grfMask);
    void Stat(out System.Runtime.InteropServices.ComTypes.STATSTG pstatstg, uint grfStatFlag);
}

[ComImport]
[Guid("0000000c-0000-0000-C000-000000000046")]
[InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
internal interface IStream
{
    void Read(byte[] pv, uint cb, out uint pcbRead);
    void Write(byte[] pv, uint cb, out uint pcbWritten);
    void Seek(long dlibMove, uint dwOrigin, out long plibNewPosition);
    void SetSize(long libNewSize);
    void CopyTo(IStream pstm, long cb, out long pcbRead, out long pcbWritten);
    void Commit(uint grfCommitFlags);
    void Revert();
    void LockRegion(long libOffset, long cb, uint dwLockType);
    void UnlockRegion(long libOffset, long cb, uint dwLockType);
    void Stat(out System.Runtime.InteropServices.ComTypes.STATSTG pstatstg, uint grfStatFlag);
    void Clone(out IStream ppstm);
}

[ComImport]
[Guid("0000000d-0000-0000-C000-000000000046")]
[InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
internal interface IEnumSTATSTG
{
    void Next(uint celt, out System.Runtime.InteropServices.ComTypes.STATSTG rgelt, out uint pceltFetched);
    void Skip(uint celt);
    void Reset();
    void Clone(out IEnumSTATSTG ppenum);
}

internal static class Ole32
{
    [DllImport("ole32.dll")]
    public static extern int StgCreateDocfile(
        [MarshalAs(UnmanagedType.LPWStr)] string pwcsName,
        uint grfMode,
        uint reserved,
        out IStorage ppstgOpen);

    [DllImport("ole32.dll")]
    public static extern int StgOpenStorage(
        [MarshalAs(UnmanagedType.LPWStr)] string pwcsName,
        IStorage pstgPriority,
        uint grfMode,
        IntPtr snbExclude,
        uint reserved,
        out IStorage ppstgOpen);

    public const uint STGM_CREATE = 0x00001000;
    public const uint STGM_READ = 0x00000000;
    public const uint STGM_WRITE = 0x00000001;
    public const uint STGM_READWRITE = 0x00000002;
    public const uint STGM_SHARE_EXCLUSIVE = 0x00000010;
    public const uint STGM_SHARE_DENY_WRITE = 0x00000020;
    public const uint STGM_TRANSACTED = 0x00010000;
    public const uint STGC_DEFAULT = 0;
}

public class BlogPost
{
    public string Title { get; set; } = string.Empty;
    public string Content { get; set; } = string.Empty;
    public DateTime CreatedDate { get; set; } = DateTime.Now;
    public List<string> Tags { get; set; } = new();
    public List<string> Categories { get; set; } = new();
    public string BlogId { get; set; } = Guid.NewGuid().ToString("D");
    public string PostId { get; set; } = Guid.NewGuid().ToString("D");
    public bool IsDraft { get; set; } = true;
    public string Author { get; set; } = Environment.UserName;
    public string BlogName { get; set; } = "My Blog";
    public string Excerpt { get; set; } = string.Empty;
}

public class OpenLiveWriterPostGenerator
{
    public static string CreatePostXml(BlogPost post)
    {
        var document = new XDocument(
            new XDeclaration("1.0", "utf-8", null),
            new XElement("post",
                new XAttribute("blog-id", post.BlogId),
                new XAttribute("post-id", post.PostId),
                new XAttribute("date-created", post.CreatedDate.ToString("yyyy-MM-ddTHH:mm:ss")),
                new XAttribute("date-modified", DateTime.Now.ToString("yyyy-MM-ddTHH:mm:ss")),
                new XAttribute("is-draft", post.IsDraft.ToString().ToLower()),
                
                new XElement("title", post.Title),
                new XElement("content", new XCData(post.Content)),
                new XElement("excerpt", new XCData(post.Excerpt)),
                new XElement("author", post.Author),
                new XElement("blog-name", post.BlogName),
                
                new XElement("categories",
                    post.Categories.Select(cat => new XElement("category", cat))
                ),
                
                new XElement("tags",
                    post.Tags.Select(tag => new XElement("tag", tag))
                ),
                
                new XElement("custom-fields"),
                
                new XElement("post-format", "standard"),
                new XElement("status", post.IsDraft ? "draft" : "publish")
            )
        );

        return document.ToString();
    }

    public static void SavePost(BlogPost post, string filePath)
    {
        SavePostAsStructuredStorage(post, filePath);
    }

    private static void SavePostAsStructuredStorage(BlogPost post, string filePath)
    {
        IStorage? rootStorage = null;
        
        try
        {
            // Create the compound document storage
            int hr = Ole32.StgCreateDocfile(
                filePath,
                Ole32.STGM_CREATE | Ole32.STGM_READWRITE | Ole32.STGM_SHARE_EXCLUSIVE | Ole32.STGM_TRANSACTED,
                0,
                out rootStorage);

            if (hr != 0)
            {
                Marshal.ThrowExceptionForHR(hr);
            }

            // Write each piece of data to its own stream (like OpenLive Writer does)
            // Ensure BlogId is a valid GUID format with proper formatting
            var blogId = string.IsNullOrEmpty(post.BlogId?.Trim()) ? 
                Guid.NewGuid().ToString("D") : 
                (Guid.TryParse(post.BlogId.Trim(), out var parsedGuid) ? 
                    parsedGuid.ToString("D") : 
                    Guid.NewGuid().ToString("D"));
            
            WriteStringToStream(rootStorage, "DestinationBlogId", blogId);
            
            // Ensure PostId is also properly formatted
            var postId = string.IsNullOrEmpty(post.PostId?.Trim()) ?
                Guid.NewGuid().ToString("D") :
                (Guid.TryParse(post.PostId.Trim(), out var parsedPostGuid) ?
                    parsedPostGuid.ToString("D") :
                    Guid.NewGuid().ToString("D"));
            
            WriteStringToStream(rootStorage, "Id", postId);
            WriteStringToStream(rootStorage, "Title", post.Title);
            WriteStringToStream(rootStorage, "Contents", post.Content);
            WriteStringToStream(rootStorage, "Exerpt", post.Excerpt); // Note: OpenLive Writer uses "Exerpt" (typo)
            WriteStringToStream(rootStorage, "AuthorName", post.Author);
            WriteStringToStream(rootStorage, "BlogName", post.BlogName);
            
            // Write boolean values
            WriteBooleanToStream(rootStorage, "IsPage", false);
            WriteBooleanToStream(rootStorage, "IsDraft", post.IsDraft);
            
            // Write date
            WriteStringToStream(rootStorage, "DatePublished", post.CreatedDate.ToString("yyyy-MM-ddTHH:mm:ss"));
            
            // Write categories as XML in a stream (this is how OpenLive Writer does it)
            var categoriesXml = CreateCategoriesXml(post.Categories);
            WriteStringToStream(rootStorage, "Categories", categoriesXml);
            
            // Write keywords/tags
            WriteStringToStream(rootStorage, "Keywords", string.Join(",", post.Tags));
            
            // Create SupportingFiles substorage (required by format)
            IStorage supportingFilesStorage;
            rootStorage.CreateStorage("SupportingFiles", 
                Ole32.STGM_CREATE | Ole32.STGM_READWRITE | Ole32.STGM_SHARE_EXCLUSIVE, 
                0, 0, out supportingFilesStorage);
            
            if (OperatingSystem.IsWindows())
            {
                Marshal.ReleaseComObject(supportingFilesStorage);
            }
            
            // Commit the transaction
            rootStorage.Commit(Ole32.STGC_DEFAULT);
        }
        finally
        {
            if (rootStorage != null && OperatingSystem.IsWindows())
            {
                Marshal.ReleaseComObject(rootStorage);
            }
        }
    }

    private static void WriteStringToStream(IStorage storage, string streamName, string data)
    {
        IStream? stream = null;
        try
        {
            // Create the stream
            storage.CreateStream(streamName, 
                Ole32.STGM_CREATE | Ole32.STGM_WRITE | Ole32.STGM_SHARE_EXCLUSIVE, 
                0, 0, out stream);

            // Convert string to UTF-8 bytes (OpenLive Writer uses UTF-8)
            byte[] bytes = Encoding.UTF8.GetBytes(data ?? string.Empty);
            
            // Write the data
            stream.Write(bytes, (uint)bytes.Length, out uint bytesWritten);
            stream.Commit(Ole32.STGC_DEFAULT);
        }
        finally
        {
            if (stream != null && OperatingSystem.IsWindows())
            {
                Marshal.ReleaseComObject(stream);
            }
        }
    }

    private static void WriteBooleanToStream(IStorage storage, string streamName, bool value)
    {
        WriteStringToStream(storage, streamName, value ? "True" : "False");
    }

    private static string CreateCategoriesXml(List<string> categories)
    {
        if (categories == null || categories.Count == 0)
        {
            return "<Categories></Categories>";
        }

        var xml = new StringBuilder();
        xml.AppendLine("<Categories>");
        
        foreach (var category in categories)
        {
            xml.AppendLine($"  <Category Name=\"{System.Security.SecurityElement.Escape(category)}\" />");
        }
        
        xml.AppendLine("</Categories>");
        return xml.ToString();
    }

    private static BlogPost LoadPostFromStructuredStorage(string filePath)
    {
        IStorage? rootStorage = null;
        
        try
        {
            // Open the compound document storage
            int hr = Ole32.StgOpenStorage(
                filePath,
                null!,
                Ole32.STGM_READ | Ole32.STGM_SHARE_DENY_WRITE | Ole32.STGM_TRANSACTED,
                IntPtr.Zero,
                0,
                out rootStorage);

            if (hr != 0)
            {
                Marshal.ThrowExceptionForHR(hr);
            }

            var post = new BlogPost();
            
            // Read each piece of data from its stream
            post.BlogId = ReadStringFromStream(rootStorage!, "DestinationBlogId");
            post.PostId = ReadStringFromStream(rootStorage!, "Id");
            post.Title = ReadStringFromStream(rootStorage!, "Title");
            post.Content = ReadStringFromStream(rootStorage!, "Contents");
            post.Excerpt = ReadStringFromStream(rootStorage!, "Exerpt");
            post.Author = ReadStringFromStream(rootStorage!, "AuthorName");
            post.BlogName = ReadStringFromStream(rootStorage!, "BlogName");
            
            // Read boolean values
            var isDraftStr = ReadStringFromStream(rootStorage!, "IsDraft");
            post.IsDraft = bool.TryParse(isDraftStr, out bool isDraft) && isDraft;
            
            // Read date
            var dateStr = ReadStringFromStream(rootStorage!, "DatePublished");
            if (DateTime.TryParse(dateStr, out DateTime publishedDate))
            {
                post.CreatedDate = publishedDate;
            }
            
            // Read categories (they're stored as XML)
            var categoriesXml = ReadStringFromStream(rootStorage!, "Categories");
            post.Categories = ParseCategoriesXml(categoriesXml);
            
            // Read keywords/tags
            var keywordsStr = ReadStringFromStream(rootStorage!, "Keywords");
            if (!string.IsNullOrEmpty(keywordsStr))
            {
                post.Tags = keywordsStr.Split(',', StringSplitOptions.RemoveEmptyEntries).ToList();
            }

            return post;
        }
        finally
        {
            if (rootStorage != null && OperatingSystem.IsWindows())
            {
                Marshal.ReleaseComObject(rootStorage);
            }
        }
    }

    private static string ReadStringFromStream(IStorage storage, string streamName)
    {
        IStream? stream = null;
        try
        {
            // Open the stream
            storage.OpenStream(streamName, 
                IntPtr.Zero,
                Ole32.STGM_READ | Ole32.STGM_SHARE_EXCLUSIVE, 
                0, 
                out stream);

            // Get stream size
            stream.Stat(out System.Runtime.InteropServices.ComTypes.STATSTG stat, 1);
            uint size = (uint)stat.cbSize;

            // Read the data
            byte[] bytes = new byte[size];
            stream.Read(bytes, size, out uint bytesRead);
            
            return Encoding.UTF8.GetString(bytes, 0, (int)bytesRead);
        }
        catch
        {
            // If stream doesn't exist, return empty string
            return string.Empty;
        }
        finally
        {
            if (stream != null && OperatingSystem.IsWindows())
            {
                Marshal.ReleaseComObject(stream);
            }
        }
    }

    private static List<string> ParseCategoriesXml(string categoriesXml)
    {
        var categories = new List<string>();
        
        if (string.IsNullOrEmpty(categoriesXml))
            return categories;

        try
        {
            // Simple XML parsing - look for Category Name attributes
            var matches = System.Text.RegularExpressions.Regex.Matches(
                categoriesXml, 
                @"<Category\s+Name=""([^""]*)""\s*/?>", 
                System.Text.RegularExpressions.RegexOptions.IgnoreCase);
            
            foreach (System.Text.RegularExpressions.Match match in matches)
            {
                if (match.Groups.Count > 1)
                {
                    categories.Add(System.Net.WebUtility.HtmlDecode(match.Groups[1].Value));
                }
            }
        }
        catch
        {
            // If XML parsing fails, return empty list
        }

        return categories;
    }

    public static BlogPost LoadPost(string filePath)
    {
        // Try to determine the file format and load accordingly
        var extension = Path.GetExtension(filePath).ToLower();
        
        if (extension == ".wpost")
        {
            return LoadPostFromStructuredStorage(filePath);
        }
        else
        {
            // Legacy XML format support
            return LoadPostFromXml(filePath);
        }
    }
    
    private static BlogPost LoadPostFromBinaryFormat(string filePath)
    {
        // Fallback for the old binary format we created earlier
        using var fileStream = new FileStream(filePath, FileMode.Open, FileAccess.Read);
        using var reader = new BinaryReader(fileStream);
        
        try
        {
            // Read and verify header
            var signature = reader.ReadBytes(5);
            if (!signature.SequenceEqual(new byte[] { 0x57, 0x50, 0x4F, 0x53, 0x54 }))
            {
                throw new InvalidDataException("Invalid .wpost file format");
            }
            
            var version = reader.ReadByte();
            var reserved = reader.ReadInt16();
            
            var post = new BlogPost
            {
                Title = ReadString(reader),
                Content = ReadString(reader),
                Excerpt = ReadString(reader),
                Author = ReadString(reader),
                BlogName = ReadString(reader),
                BlogId = ReadString(reader),
                PostId = ReadString(reader),
                CreatedDate = DateTime.FromBinary(reader.ReadInt64()),
                IsDraft = reader.ReadBoolean()
            };
            
            // Skip modified date
            reader.ReadInt64();
            
            // Read categories
            var categoryCount = reader.ReadInt32();
            for (int i = 0; i < categoryCount; i++)
            {
                post.Categories.Add(ReadString(reader));
            }
            
            // Read tags
            var tagCount = reader.ReadInt32();
            for (int i = 0; i < tagCount; i++)
            {
                post.Tags.Add(ReadString(reader));
            }
            
            return post;
        }
        catch
        {
            throw new InvalidDataException("Unable to read .wpost file - unsupported format");
        }
    }
    
    private static BlogPost LoadPostFromXml(string filePath)
    {
        var xml = File.ReadAllText(filePath);
        var document = XDocument.Parse(xml);
        var root = document.Root!;

        var post = new BlogPost
        {
            BlogId = root.Attribute("blog-id")?.Value ?? string.Empty,
            PostId = root.Attribute("post-id")?.Value ?? Guid.NewGuid().ToString(),
            CreatedDate = DateTime.Parse(root.Attribute("date-created")?.Value ?? DateTime.Now.ToString()),
            IsDraft = bool.Parse(root.Attribute("is-draft")?.Value ?? "true"),
            
            Title = root.Element("title")?.Value ?? string.Empty,
            Content = root.Element("content")?.Value ?? string.Empty,
            Excerpt = root.Element("excerpt")?.Value ?? string.Empty,
            Author = root.Element("author")?.Value ?? Environment.UserName,
            BlogName = root.Element("blog-name")?.Value ?? "My Blog"
        };

        var categoriesElement = root.Element("categories");
        if (categoriesElement != null)
        {
            post.Categories.AddRange(
                categoriesElement.Elements("category").Select(c => c.Value)
            );
        }

        var tagsElement = root.Element("tags");
        if (tagsElement != null)
        {
            post.Tags.AddRange(
                tagsElement.Elements("tag").Select(t => t.Value)
            );
        }

        return post;
    }
    
    private static string ReadString(BinaryReader reader)
    {
        var length = reader.ReadInt32();
        var bytes = reader.ReadBytes(length);
        return System.Text.Encoding.UTF8.GetString(bytes);
    }
}
