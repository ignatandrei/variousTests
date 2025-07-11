using System;
using System.Collections.Generic;
using System.IO;
using System.Text.RegularExpressions;

namespace SqlTableSeparator
{
    class Program
    {
        static void Main(string[] args)
        {
            string sqlFilePath = @"D:\eu\cursor\WordpressAspire\backup\gratiwd.sql";
            string outputDirectory = @"D:\eu\cursor\WordpressAspire\backup\separated_tables";
            WordPressTableSeparator wordPressTableSeparator = new();
            wordPressTableSeparator.Separate(sqlFilePath, outputDirectory);
        }
    }
}
