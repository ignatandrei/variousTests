using System.Text.Json;
using System.Text.Json.Serialization;

namespace ChatExportParser;

public class ChatExport
{
    [JsonPropertyName("requesterUsername")]
    public string RequesterUsername { get; set; } = string.Empty;
    
    [JsonPropertyName("responderUsername")]
    public string ResponderUsername { get; set; } = string.Empty;
    
    [JsonPropertyName("requests")]
    public List<Request> Requests { get; set; } = new();
}

public class Request
{
    [JsonPropertyName("requestId")]
    public string RequestId { get; set; } = string.Empty;
    
    [JsonPropertyName("message")]
    public Message Message { get; set; } = new();
    
    [JsonPropertyName("response")]
    public List<ResponseItem> Response { get; set; } = new();
    
    [JsonPropertyName("timestamp")]
    public long Timestamp { get; set; }
}

public class Message
{
    [JsonPropertyName("text")]
    public string Text { get; set; } = string.Empty;
    
    [JsonPropertyName("parts")]
    public List<MessagePart> Parts { get; set; } = new();
}

public class MessagePart
{
    [JsonPropertyName("text")]
    public string Text { get; set; } = string.Empty;
    
    [JsonPropertyName("kind")]
    public string Kind { get; set; } = string.Empty;
}

public class ResponseItem
{
    [JsonPropertyName("value")]
    public string? Value { get; set; }
    
    [JsonPropertyName("kind")]
    public string? Kind { get; set; }
}

public class ConversationItem
{
    public string UserQuestion { get; set; } = string.Empty;
    public string AiResponse { get; set; } = string.Empty;
    public DateTime Timestamp { get; set; }
    public string RequestId { get; set; } = string.Empty;
}
