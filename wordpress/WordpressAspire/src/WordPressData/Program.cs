using Projects;

var builder = DistributedApplication.CreateBuilder(args);

//// Add MariaDB container
//var db = builder.AddContainer("mariadb", "mariadb","10.6")
//    .WithEnvironment("MYSQL_ROOT_PASSWORD", "wordpress_root_password")
//    .WithEnvironment("MYSQL_DATABASE", "wordpress")
//    .WithEnvironment("MYSQL_USER", "wordpress_user")
//    .WithEnvironment("MYSQL_PASSWORD", "wordpress_password")
//    .WithVolume("mariadb_data", "/var/lib/mysql")
//    .WithEndpoint(3306, 3306);

var server = builder.AddMySql("mysql")
                    .WithPhpMyAdmin()
                   .WithLifetime(ContainerLifetime.Persistent);

var mysqldb = server.AddDatabase("mysqldb");
//// Add phpMyAdmin container for MariaDB management
//var phpmyadmin = builder.AddContainer("phpmyadmin", "phpmyadmin")
//    .WithEnvironment("PMA_HOST", db.Resource.Name)
//    .WithEnvironment("PMA_USER", "root")
//    .WithEnvironment("PMA_PASSWORD", db.Resource.PasswordParameter.Value)
//    .WithReference(db)
//    .WithHttpEndpoint(8081, 80);

// Add WordPress container
var wordpress = builder.AddContainer("wordpress", "wordpress")
    .WithEnvironment("WORDPRESS_DB_HOST", server.Resource.Name)
    .WithEnvironment("WORDPRESS_DB_NAME", mysqldb.Resource.Name)
    .WithEnvironment("WORDPRESS_DB_USER", "root")
    .WithEnvironment("WORDPRESS_DB_PASSWORD", server.Resource.PasswordParameter.Value)
    .WithEnvironment("WORDPRESS_DB_PORT", "3306")
    .WithVolume("wordpress_data", "/var/www/html")
    .WithHttpEndpoint(8080, 80);


builder.AddProject<SqlTableSeparator>("DoRestore")
    .WithReference(mysqldb)
    .WithExplicitStart();


builder.Build().Run();
