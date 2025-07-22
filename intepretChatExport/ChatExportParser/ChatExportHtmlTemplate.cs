namespace ChatExportParser;

public class HtmlTemplateData
{
    public string RequesterUsername { get; set; } = string.Empty;
    public string ResponderUsername { get; set; } = string.Empty;
    public List<ConversationItem> Conversations { get; set; } = new();
    public DateTime ExportDate { get; set; } = DateTime.Now;
}

public static class ChatExportHtmlTemplate
{
    public static string Render(HtmlTemplateData data)
    {
        return $@"<!DOCTYPE html>
<html lang=""en"">
<head>
    <meta charset=""UTF-8"">
    <meta name=""viewport"" content=""width=device-width, initial-scale=1.0"">
    <title>Chat Export - {data.RequesterUsername} and {data.ResponderUsername}</title>
    {GetStyles()}
</head>
<body>
    {GetHeader(data)}
    {GetStats(data)}
    {GetSearchBox()}
    {GetConversations(data)}
    {GetFooter(data)}
    {GetJavaScript()}
</body>
</html>";
    }

    private static string GetStyles()
    {
        return @"<style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            line-height: 1.6;
            color: #333;
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 2rem;
            border-radius: 10px;
            margin-bottom: 2rem;
            text-align: center;
        }
        .header h1 {
            margin: 0 0 0.5rem 0;
            font-size: 2.5rem;
        }
        .header .subtitle {
            opacity: 0.9;
            font-size: 1.1rem;
        }
        .stats {
            background: white;
            padding: 1.5rem;
            border-radius: 8px;
            margin-bottom: 2rem;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1rem;
        }
        .stat-item {
            text-align: center;
            padding: 1rem;
            border-radius: 6px;
            background: #f8f9fa;
        }
        .stat-number {
            font-size: 2rem;
            font-weight: bold;
            color: #667eea;
        }
        .stat-label {
            color: #666;
            font-size: 0.9rem;
        }
        .conversation {
            background: white;
            margin-bottom: 2rem;
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 2px 15px rgba(0,0,0,0.1);
        }
        .conversation-header {
            background: #f8f9fa;
            padding: 1rem 1.5rem;
            border-bottom: 1px solid #e9ecef;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .conversation-number {
            font-weight: bold;
            color: #667eea;
            font-size: 1.1rem;
        }
        .conversation-date {
            color: #666;
            font-size: 0.9rem;
        }
        .message {
            padding: 1.5rem;
        }
        .message:not(:last-child) {
            border-bottom: 1px solid #f0f0f0;
        }
        .message-header {
            display: flex;
            align-items: center;
            margin-bottom: 1rem;
        }
        .avatar {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            margin-right: 1rem;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
            color: white;
            font-size: 1.2rem;
        }
        .user-avatar {
            background: #28a745;
        }
        .ai-avatar {
            background: #667eea;
        }
        .username {
            font-weight: bold;
            color: #333;
        }
        .message-content {
            margin-left: 56px;
            line-height: 1.7;
        }
        .message-content pre {
            background: #f8f9fa;
            padding: 1rem;
            border-radius: 6px;
            overflow-x: auto;
            border-left: 4px solid #667eea;
        }
        .message-content code {
            background: #f8f9fa;
            padding: 0.2rem 0.4rem;
            border-radius: 3px;
            font-size: 0.9rem;
        }
        .search-box {
            background: white;
            padding: 1.5rem;
            border-radius: 8px;
            margin-bottom: 2rem;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .search-input {
            width: 100%;
            padding: 0.75rem;
            border: 2px solid #e9ecef;
            border-radius: 6px;
            font-size: 1rem;
            transition: border-color 0.3s;
            box-sizing: border-box;
        }
        .search-input:focus {
            outline: none;
            border-color: #667eea;
        }
        .footer {
            text-align: center;
            padding: 2rem;
            color: #666;
            font-size: 0.9rem;
            margin-top: 3rem;
        }
        @media (max-width: 768px) {
            body {
                padding: 10px;
            }
            .header h1 {
                font-size: 2rem;
            }
            .message-content {
                margin-left: 0;
            }
            .message-header {
                flex-direction: column;
                align-items: flex-start;
                gap: 0.5rem;
            }
        }
    </style>";
    }

    private static string GetHeader(HtmlTemplateData data)
    {
        return $@"<div class=""header"">
        <h1>💬 Chat Export</h1>
        <div class=""subtitle"">Conversation between {data.RequesterUsername} and {data.ResponderUsername}</div>
    </div>";
    }

    private static string GetStats(HtmlTemplateData data)
    {
        var userQuestionCount = data.Conversations.Count(c => !string.IsNullOrWhiteSpace(c.UserQuestion));
        
        return $@"<div class=""stats"">
        <div class=""stat-item"">
            <div class=""stat-number"">{data.Conversations.Count}</div>
            <div class=""stat-label"">Total Conversations</div>
        </div>
        <div class=""stat-item"">
            <div class=""stat-number"">{data.ExportDate:MMM dd, yyyy}</div>
            <div class=""stat-label"">Export Date</div>
        </div>
        <div class=""stat-item"">
            <div class=""stat-number"">{userQuestionCount}</div>
            <div class=""stat-label"">User Questions</div>
        </div>
    </div>";
    }

    private static string GetSearchBox()
    {
        return @"<div class=""search-box"">
        <input type=""text"" class=""search-input"" placeholder=""🔍 Search conversations..."" id=""searchInput"">
    </div>";
    }

    private static string GetConversations(HtmlTemplateData data)
    {
        var conversationsHtml = string.Join("\n", data.Conversations.Select((conv, index) => GetSingleConversation(conv, index + 1, data)));
        
        return $@"<div id=""conversations"">
{conversationsHtml}
    </div>";
    }

    private static string GetSingleConversation(ConversationItem conversation, int number, HtmlTemplateData data)
    {
        var messagesHtml = string.Empty;
        
        // Add user message if exists
        if (!string.IsNullOrWhiteSpace(conversation.UserQuestion))
        {
            var userInitial = data.RequesterUsername.Length > 0 ? data.RequesterUsername.Substring(0, 1).ToUpper() : "U";
            messagesHtml += $@"
            <div class=""message"">
                <div class=""message-header"">
                    <div class=""avatar user-avatar"">{userInitial}</div>
                    <span class=""username"">{data.RequesterUsername}</span>
                </div>
                <div class=""message-content"">{FormatMessageContent(conversation.UserQuestion)}</div>
            </div>";
        }
        
        // Add AI message if exists
        if (!string.IsNullOrWhiteSpace(conversation.AiResponse))
        {
            messagesHtml += $@"
            <div class=""message"">
                <div class=""message-header"">
                    <div class=""avatar ai-avatar"">🤖</div>
                    <span class=""username"">{data.ResponderUsername}</span>
                </div>
                <div class=""message-content"">{FormatMessageContent(conversation.AiResponse)}</div>
            </div>";
        }
        
        return $@"        <div class=""conversation"" data-conversation=""{number}"">
            <div class=""conversation-header"">
                <span class=""conversation-number"">#{number}</span>
                <span class=""conversation-date"">{conversation.Timestamp:yyyy-MM-dd HH:mm:ss}</span>
            </div>{messagesHtml}
        </div>";
    }

    private static string GetFooter(HtmlTemplateData data)
    {
        return $@"<div class=""footer"">
        <p>Generated on {data.ExportDate:yyyy-MM-dd HH:mm:ss} by Chat Export Parser</p>
        <p>Total of {data.Conversations.Count} conversations exported</p>
    </div>";
    }

    private static string GetJavaScript()
    {
        return @"<script>
        document.getElementById('searchInput').addEventListener('input', function(e) {
            const searchTerm = e.target.value.toLowerCase();
            const conversations = document.querySelectorAll('.conversation');
            
            conversations.forEach(conversation => {
                const text = conversation.textContent.toLowerCase();
                if (text.includes(searchTerm) || searchTerm === '') {
                    conversation.style.display = 'block';
                } else {
                    conversation.style.display = 'none';
                }
            });
        });

        // Smooth scrolling for better UX
        document.addEventListener('DOMContentLoaded', function() {
            const conversations = document.querySelectorAll('.conversation');
            conversations.forEach((conv, index) => {
                conv.style.animationDelay = `${index * 0.1}s`;
            });
        });
    </script>";
    }

    private static string FormatMessageContent(string content)
    {
        if (string.IsNullOrWhiteSpace(content))
            return string.Empty;

        // Basic HTML encoding and formatting
        var formatted = System.Net.WebUtility.HtmlEncode(content);
        
        // Convert line breaks to HTML
        formatted = formatted.Replace("\n", "<br>");
        
        // Simple code block detection (content between ``` markers)
        formatted = System.Text.RegularExpressions.Regex.Replace(
            formatted, 
            @"```([^`]*)```", 
            "<pre><code>$1</code></pre>", 
            System.Text.RegularExpressions.RegexOptions.Singleline);
        
        // Simple inline code detection (content between ` markers)
        formatted = System.Text.RegularExpressions.Regex.Replace(
            formatted, 
            @"`([^`]*)`", 
            "<code>$1</code>");
        
        return formatted;
    }
}