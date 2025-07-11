using System;
using System.Collections.Generic;
using System.IO;
using System.Text.RegularExpressions;

namespace SqlTableSeparator;

class Program
{
    static async Task Main(string[] args)
    {
        string sqlFilePath = @"D:\eu\GitHub\variousTests\wordpress\WordpressAspire\backup\myBackup.sql";
        string outputDirectory = @"D:\eu\GitHub\variousTests\wordpress\WordpressAspire\backup\separated_tables";
        WordPressTableSeparator wordPressTableSeparator = new();
        wordPressTableSeparator.Separate(sqlFilePath, outputDirectory);

        var cn = Environment.GetEnvironmentVariable("ConnectionStrings__mysqldb");
        MySqlDatabaseRepo mySqlDatabaseRepo = new(cn);
        await mySqlDatabaseRepo.ExecuteFromSeparateTables(outputDirectory);
        
    }
}
