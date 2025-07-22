using System.Text.Json;

namespace ChatExportParser;

public class ChatParser
{
    public static ChatExport? ParseChatExport(string jsonFilePath)
    {
        try
        {
            var jsonContent = File.ReadAllText(jsonFilePath);
            var options = new JsonSerializerOptions
            {
                PropertyNameCaseInsensitive = true,
                AllowTrailingCommas = true
            };
            
            return JsonSerializer.Deserialize<ChatExport>(jsonContent, options);
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error parsing JSON file: {ex.Message}");
            return null;
        }
    }
    
    public static List<ConversationItem> ExtractConversations(ChatExport chatExport)
    {
        var conversations = new List<ConversationItem>();
        
        foreach (var request in chatExport.Requests)
        {
            var userQuestion = ExtractUserQuestion(request);
            var aiResponse = ExtractAiResponse(request);
            var timestamp = DateTimeOffset.FromUnixTimeMilliseconds(request.Timestamp).DateTime;
            
            if (!string.IsNullOrWhiteSpace(userQuestion) || !string.IsNullOrWhiteSpace(aiResponse))
            {
                conversations.Add(new ConversationItem
                {
                    UserQuestion = userQuestion,
                    AiResponse = aiResponse,
                    Timestamp = timestamp,
                    RequestId = request.RequestId
                });
            }
        }
        
        return conversations;
    }
    
    private static string ExtractUserQuestion(Request request)
    {
        // Try to get text from the main message first
        if (!string.IsNullOrWhiteSpace(request.Message.Text))
        {
            return request.Message.Text.Trim();
        }
        
        // If not available, try to extract from parts
        var textParts = request.Message.Parts
            .Where(p => p.Kind == "text" && !string.IsNullOrWhiteSpace(p.Text))
            .Select(p => p.Text.Trim())
            .ToList();
        
        return string.Join(" ", textParts);
    }
    
    private static string ExtractAiResponse(Request request)
    {
        var responseParts = new List<string>();
        
        foreach (var responseItem in request.Response)
        {
            // Only include response items that have actual text content
            if (!string.IsNullOrWhiteSpace(responseItem.Value) && 
                (responseItem.Kind == null || responseItem.Kind != "toolInvocationSerialized"))
            {
                responseParts.Add(responseItem.Value.Trim());
            }
        }
        
        return string.Join("\n\n", responseParts);
    }
}
