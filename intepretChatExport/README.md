# Chat Export Parser

A C# console application that parses GitHub Copilot chat export JSON files and extracts user questions and AI responses.

## Features

- Parse GitHub Copilot chat export JSON files
- Extract user questions and AI responses
- Display conversations in various formats
- Search through questions and responses
- Export conversations to text files
- **Export conversations to beautifully formatted HTML files**
- Interactive menu-driven interface

## Usage

### Building the Application

```powershell
dotnet build
```

### Running the Application

#### Using the default file (fridayLinks1.json)
```powershell
dotnet run
```

#### Using a custom JSON file
```powershell
dotnet run "path\to\your\chat_export.json"
```

### Interactive Menu Options

1. **Display all conversations** - Shows all user questions and AI responses
2. **Display conversations with index numbers** - Same as above but with numbered conversations
3. **Search for specific text in questions** - Find conversations where the user question contains specific text
4. **Search for specific text in responses** - Find conversations where the AI response contains specific text
5. **Export conversations to text file** - Save all conversations to a timestamped text file
6. **Export conversations to HTML file** - Generate a beautiful, searchable HTML document with modern styling
7. **Exit** - Close the application

### Example Output

```
Chat Export Parser
==================

Using default file: d:\eu\GitHub\variousTests\fridayLinks1.json
You can also specify a different file as a command line argument.

Parsing file: d:\eu\GitHub\variousTests\fridayLinks1.json

Found 2 conversation exchanges
Between: ignatandrei and GitHub Copilot

Choose an option:
1. Display all conversations
2. Display conversations with index numbers
3. Search for specific text in questions
4. Search for specific text in responses
5. Export conversations to text file
6. Export conversations to HTML file
7. Exit
Enter your choice (1-7):
```

## JSON Structure

The application expects a JSON file with the following structure:

```json
{
  "requesterUsername": "username",
  "responderUsername": "AI Assistant",
  "requests": [
    {
      "requestId": "unique_id",
      "message": {
        "text": "User question text",
        "parts": [...]
      },
      "response": [
        {
          "value": "AI response text",
          "kind": "response_type"
        }
      ],
      "timestamp": 1234567890
    }
  ]
}
```

## HTML Export Features

The HTML export functionality creates a beautiful, responsive web page with:

- **Modern design** with gradient headers and clean typography
- **Responsive layout** that works on desktop and mobile devices
- **Live search functionality** to filter conversations in real-time
- **Conversation statistics** showing total conversations, export date, and user questions count
- **Syntax highlighting** for code blocks and inline code
- **Avatar system** with user initials and AI robot emoji
- **Smooth animations** and professional styling
- **Timestamped conversations** with clear conversation numbering
- **Automatic file opening** option after export

The generated HTML file is completely self-contained and can be:
- Opened in any modern web browser
- Shared with others without dependencies
- Printed with proper page breaks
- Archived for long-term storage

## Dependencies

- .NET 8.0
- System.Text.Json (included in .NET 8.0)

## Notes

- The application filters out tool invocation messages to show only the actual conversation content
- Timestamps are converted from Unix milliseconds to readable DateTime format
- The application handles malformed JSON gracefully with error messages
- Empty or whitespace-only messages are filtered out
