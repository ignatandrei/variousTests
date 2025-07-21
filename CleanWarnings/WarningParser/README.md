# Warning Parser

A C# console application that parses the `cleanWarnings.txt` file to extract prompts and their associated intermezzos.

## Features

- Parses prompts marked with `--prompt`
- Associates intermezzos marked with `---intermezzo` with their preceding prompt
- Generates multiple output formats:
  - Console output with formatted display
  - HTML file with styled presentation
  - JSON file for programmatic access
- Automatically opens the HTML result in the default browser

## Project Structure

```
WarningParser/
├── Models/
│   └── PromptData.cs          # Data model for prompts and intermezzos
├── Services/
│   ├── FileParser.cs          # Parsing logic for the input file
│   └── OutputGenerator.cs     # Output generation in various formats
├── Program.cs                 # Main application entry point
├── WarningParser.csproj       # Project file
└── README.md                  # This file
```

## How to Use

1. **Prerequisites**: Ensure `cleanWarnings.txt` is in the parent directory of the WarningParser folder
2. **Build the project**: `dotnet build`
3. **Run the application**: `dotnet run`

## Input File Format

The parser expects a file with the following structure:

```
--prompt
[prompt content here]

---intermezzo
[intermezzo content here]

--prompt
[another prompt content]

---intermezzo
[another intermezzo content]
```

## Output Files

- `parsed_results.html` - Formatted HTML report with prompts and intermezzos
- `parsed_results.json` - JSON data for programmatic processing

## Data Model

The `PromptData` class contains:
- `Id` - Sequential prompt number
- `Content` - The full prompt text
- `Intermezzos` - List of associated intermezzo texts
- `LineNumber` - Line number where the prompt starts in the source file

## Example Usage

```csharp
var parser = new FileParser();
var prompts = parser.ParseFile("cleanWarnings.txt");

var outputGenerator = new OutputGenerator();
outputGenerator.GenerateConsoleOutput(prompts);
outputGenerator.GenerateHtmlOutput(prompts, "output.html");
outputGenerator.GenerateJsonOutput(prompts, "output.json");
```

## Requirements

- .NET 8.0 or later
- System.Web reference (for HTML encoding) 