namespace SqlTableSeparator;

public class PostCategoryInfo
{
    public string NewInsert { get; set; } = string.Empty;
    public string PostId { get; set; } = string.Empty;
    public string PostCategory { get; set; } = string.Empty;

    private static readonly string[] ColumnOrder = {
        "ID", "post_author", "post_date", "post_date_gmt", "post_content", "post_title",
        "post_category", "post_excerpt", "post_status", "comment_status", "ping_status",
        "post_password", "post_name", "to_ping", "pinged", "post_modified", "post_modified_gmt",
        "post_content_filtered", "post_parent", "guid", "menu_order", "post_type",
        "post_mime_type", "comment_count"
    };

    public WordPressPost ParseInsertStatement(string insertStatement)
    {
        if (string.IsNullOrWhiteSpace(insertStatement))
            throw new ArgumentException("Insert statement cannot be null or empty", nameof(insertStatement));

        // Find the VALUES clause
        var valuesIndex = insertStatement.IndexOf("VALUES", StringComparison.OrdinalIgnoreCase);
        if (valuesIndex == -1)
            throw new ArgumentException("Invalid INSERT statement: VALUES clause not found");

        // Extract the values part - find the opening parenthesis after VALUES
        var openParenIndex = insertStatement.IndexOf('(', valuesIndex);
        if (openParenIndex == -1)
            throw new ArgumentException("Invalid INSERT statement: Opening parenthesis not found after VALUES");

        // Find the matching closing parenthesis (last one in the statement)
        var closeParenIndex = insertStatement.LastIndexOf(')');
        if (closeParenIndex == -1 || closeParenIndex <= openParenIndex)
            throw new ArgumentException("Invalid INSERT statement: Closing parenthesis not found");

        // Extract values string
        var valuesString = insertStatement.Substring(openParenIndex + 1, closeParenIndex - openParenIndex - 1);

        // Parse the values
        var values = ParseSqlValues(valuesString);
        if (values.Count != ColumnOrder.Length)
            throw new ArgumentException($"Expected {ColumnOrder.Length} values, but got {values.Count}");

        // Create and populate the WordPressPost object
        var post = new WordPressPost();

        for (int i = 0; i < values.Count; i++)
        {
            var value = values[i].Trim('\'');

            switch (ColumnOrder[i])
            {
                case "ID":
                    post.ID = int.Parse(value);
                    break;
                case "post_author":
                    post.PostAuthor = int.Parse(value);
                    break;
                case "post_date":
                    post.PostDate = DateTime.Parse(value);
                    break;
                case "post_date_gmt":
                    post.PostDateGmt = DateTime.Parse(value);
                    break;
                case "post_content":
                    post.PostContent = value;
                    break;
                case "post_title":
                    post.PostTitle = value;
                    break;
                case "post_category":
                    post.PostCategory = int.Parse(value);
                    break;
                case "post_excerpt":
                    post.PostExcerpt = value;
                    break;
                case "post_status":
                    post.PostStatus = value;
                    break;
                case "comment_status":
                    post.CommentStatus = value;
                    break;
                case "ping_status":
                    post.PingStatus = value;
                    break;
                case "post_password":
                    post.PostPassword = value;
                    break;
                case "post_name":
                    post.PostName = value;
                    break;
                case "to_ping":
                    post.ToPing = value;
                    break;
                case "pinged":
                    post.Pinged = value;
                    break;
                case "post_modified":
                    post.PostModified = DateTime.Parse(value);
                    break;
                case "post_modified_gmt":
                    post.PostModifiedGmt = DateTime.Parse(value);
                    break;
                case "post_content_filtered":
                    post.PostContentFiltered = value;
                    break;
                case "post_parent":
                    post.PostParent = int.Parse(value);
                    break;
                case "guid":
                    post.Guid = value;
                    break;
                case "menu_order":
                    post.MenuOrder = int.Parse(value);
                    break;
                case "post_type":
                    post.PostType = value;
                    break;
                case "post_mime_type":
                    post.PostMimeType = value;
                    break;
                case "comment_count":
                    post.CommentCount = int.Parse(value);
                    break;
            }
        }

        return post;
    }

    private static List<string> ParseSqlValues(string valuesString)
    {
        List<string>  ret = new ();
        var values = valuesString.Split(',',StringSplitOptions.RemoveEmptyEntries);
        var currentValue = new System.Text.StringBuilder();
        var inQuotes = false;
        for(var i = 0; i < values.Length; i++)
        {
            var value = values[i].Trim();
            if (value.StartsWith("'") )
            {
                inQuotes = true;
            }
            if (value.EndsWith("'") && !value.EndsWith("\\'"))
            {
                inQuotes = false;
            }
            if (inQuotes)
            {
                currentValue.Append(value);
                if (i < values.Length - 1)
                {
                    currentValue.Append(",");
                }
            }
            else
            {
                currentValue.Append(value);
                ret.Add(currentValue.ToString());
                currentValue.Clear();
            }
        }
        return ret;
    }

    public static string[] GetColumnOrder()
    {
        return (string[])ColumnOrder.Clone();
    }
}
