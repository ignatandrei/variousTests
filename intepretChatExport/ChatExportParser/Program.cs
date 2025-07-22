using ChatExportParser;

class Program
{
    static void Main(string[] args)
    {
        // Default to the fridayLinks1.json file in the parent directory
        string[] jsonChats = [
            @"d:\eu\GitHub\variousTests\fridayLinks1.json",
            @"d:\eu\GitHub\variousTests\fridayLinks2.json",
            @"d:\eu\GitHub\variousTests\fridayLinks3.json",
            @"d:\eu\GitHub\variousTests\fridayLinks4.json",
            @"d:\eu\GitHub\variousTests\intepretChatExport.json",



];


        foreach (var file in jsonChats)
        {
            var nameFileExport  = file.Replace(".json",".html");
            var chatExport = ChatParser.ParseChatExport(file);
            var conversations = ChatParser.ExtractConversations(chatExport);
            var template = new DisplayChat(chatExport);
            var result = template.Render();
            File.WriteAllText(nameFileExport, result);
            Console.WriteLine($"Exported chat to {nameFileExport}");
        }

        // Extract conversations


        static void ExportToHtmlFile(List<ConversationItem> conversations, ChatExport chatExport)
        {
            var fileName = $"chat_export_{DateTime.Now:yyyyMMdd_HHmmss}.html";
            var filePath = Path.Combine(Directory.GetCurrentDirectory(), fileName);

            try
            {
                var templateData = new HtmlTemplateData
                {
                    RequesterUsername = chatExport.RequesterUsername,
                    ResponderUsername = chatExport.ResponderUsername,
                    Conversations = conversations,
                    ExportDate = DateTime.Now
                };

                var html = ChatExportHtmlTemplate.Render(templateData);
                File.WriteAllText(filePath, html);

                Console.WriteLine($"Successfully exported to HTML: {filePath}");
                Console.WriteLine("You can open this file in any web browser to view the formatted conversations.");

                // Ask if user wants to open the file
                Console.Write("Would you like to open the HTML file now? (y/n): ");
                var response = Console.ReadLine();
                if (response?.ToLower() == "y" || response?.ToLower() == "yes")
                {
                    try
                    {
                        System.Diagnostics.Process.Start(new System.Diagnostics.ProcessStartInfo
                        {
                            FileName = filePath,
                            UseShellExecute = true
                        });
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine($"Could not open file automatically: {ex.Message}");
                        Console.WriteLine($"Please manually open: {filePath}");
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error exporting to HTML file: {ex.Message}");
            }
        }
    }
}
