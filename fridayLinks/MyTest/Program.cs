using MarkdownToHtmlLib;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace MyTest
{
    internal static class Program
    {
        /// <summary>
        /// The main entry point for the application.
        /// </summary>
        [STAThread]
        static void Main()
        {
            GeneratePostFromMD(@"D:\eu\GitHub\Filters.wiki");
            //NewProgram.GenerateFromBookmarks();
            return;
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            Application.Run(new Form1());
        }

        private static void GeneratePostFromMD(string folder)
        {
            DirectoryInfo di = new DirectoryInfo(folder);
            var files = di.GetFiles("*.md", SearchOption.AllDirectories);
            foreach (var file in files)
            {
                //switch(file.Name)
                //{
                //    case "Home.md":
                //    case "Csharp01.md":
                //    case "Csharp02.md":
                //    case "Csharp03.md":
                //    case "Csharp04.md":
                //    case "Csharp05.md":
                //    case "Csharp06.md":
                //    case "Csharp07.md":
                //    case "Csharp08.md":
                //        continue;
                //    default:
                //        break;
                //}
                var html = MarkdownConverter.ToHtml(File.ReadAllText(file.FullName));
                //html = html.Replace("<pre><code class=\"language-csharp\">", "[code lang='csharp']");
                //html = html.Replace("</code></pre>", "[/code]");

                var outFile = Path.Combine(file.DirectoryName, file.Name.Replace(".md", ".html"));
                File.WriteAllText(outFile, html);
                NewProgram.GeneratePostFromHtml(outFile,html);
            }
        }

        
    }
}
