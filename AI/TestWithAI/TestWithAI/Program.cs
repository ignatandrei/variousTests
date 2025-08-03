using Microsoft.AI.Foundry.Local;
using OpenAI;
using OpenAI.Chat;
using System.ClientModel;
using TextCopy;

// See https://aka.ms/new-console-template for more information
Console.WriteLine("Improving blog post");
string? clipboardText= null;
while (true)
{
    Console.WriteLine("Please copy the text you want to improve to the clipboard and press Enter.");
    Console.ReadLine();
     clipboardText= await ClipboardService.GetTextAsync();
    if (string.IsNullOrWhiteSpace(clipboardText ))
    {
        Console.WriteLine("Clipboard is empty or contains non-text data.");
        continue;
    }

    Console.WriteLine("Clipboard contains text for blog");
    Console.WriteLine(clipboardText);
    Console.WriteLine("Is that right Y / N");
    var response = Console.ReadLine()?.Trim().ToUpperInvariant();
    if (response != "Y")
    {
        Console.WriteLine("Exiting without processing.");
        continue;
    }
    break;

}

// Now you can use the clipboardText variable to process the text as needed
Console.WriteLine("Processing the text...");
var blogPost = clipboardText;
using var manager = new FoundryLocalManager();
if(manager == null)
{
    Console.WriteLine("Failed to create FoundryLocalManager.");
    return;
}
await manager.StopServiceAsync();
string modelAlias="phi-4";
modelAlias = "phi-3.5-mini";
await manager.UnloadModelAsync(modelAlias);
var model = await manager.GetModelInfoAsync(modelAlias);

if (model == null)
{
    Console.WriteLine($"Model {model} not found.");
    return;
}
var key = new ApiKeyCredential(manager.ApiKey);
var client = new OpenAIClient(key, new OpenAIClientOptions
{
    Endpoint = manager.Endpoint
});
var chatClient = client.GetChatClient(model?.ModelId);
string chat = $"""
    Please improve this blog post .Make it funny, if possible. 
    ==start blog post==
    {blogPost}
    ==end blog post==
    """;
string responseText = string.Empty;
ChatMessage chatMessage= ChatMessage.CreateUserMessage(chat);
var data = await chatClient.CompleteChatAsync(chat);
responseText = string.Join(" ", data.Value.Content.Select(it => it.Text));
//CollectionResult<StreamingChatCompletionUpdate> completionUpdates = chatClient.CompleteChatStreaming(chat);

//Console.Write($"[ASSISTANT]: ");
//foreach (StreamingChatCompletionUpdate completionUpdate in completionUpdates)
//{
//    if (completionUpdate.ContentUpdate.Count > 0)
//    {
//        responseText+=string.Join(" ",completionUpdate.ContentUpdate.Select(it=>it.Text));
//    }
//    else
//    {
//        responseText+=completionUpdate.ContentUpdate.ToString();
//    }
//}


Console.WriteLine(responseText);
Console.WriteLine("end");