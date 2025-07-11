namespace SqlTableSeparator;

public class WordPressPost
{
    public int ID { get; set; }
    public int PostAuthor { get; set; }
    public DateTime PostDate { get; set; }
    public DateTime PostDateGmt { get; set; }
    public string PostContent { get; set; } = string.Empty;
    public string PostTitle { get; set; } = string.Empty;
    public int PostCategory { get; set; }
    public string PostExcerpt { get; set; } = string.Empty;
    public string PostStatus { get; set; } = string.Empty;
    public string CommentStatus { get; set; } = string.Empty;
    public string PingStatus { get; set; } = string.Empty;
    public string PostPassword { get; set; } = string.Empty;
    public string PostName { get; set; } = string.Empty;
    public string ToPing { get; set; } = string.Empty;
    public string Pinged { get; set; } = string.Empty;
    public DateTime PostModified { get; set; }
    public DateTime PostModifiedGmt { get; set; }
    public string PostContentFiltered { get; set; } = string.Empty;
    public int PostParent { get; set; }
    public string Guid { get; set; } = string.Empty;
    public int MenuOrder { get; set; }
    public string PostType { get; set; } = string.Empty;
    public string PostMimeType { get; set; } = string.Empty;
    public int CommentCount { get; set; }
}
