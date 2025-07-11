# WordPress ASPIRE Solution

This ASPIRE C# solution provides a complete WordPress deployment with MariaDB database, including automatic backup restoration functionality.

## Features

- **WordPress Container**: Latest WordPress image with automatic configuration
- **MariaDB Container**: MariaDB 10.6 database for WordPress
- **Automatic Backup Restoration**: Extracts and restores WordPress backup from zip files
- **Network Configuration**: Containers are automatically configured to communicate
- **Volume Persistence**: Data is persisted across container restarts

## Prerequisites

- .NET 8.0 SDK
- Docker Desktop (with containers enabled)
- ASPIRE CLI tools

## Setup

1. **Install ASPIRE CLI** (if not already installed):
   ```bash
   dotnet tool install -g Microsoft.Tye --version 0.11.0-alpha.22111.1
   ```

2. **Build the solution**:
   ```bash
   dotnet build
   ```

3. **Run the application**:
   ```bash
   cd src/WordpressAspire.AppHost
   dotnet run
   ```

## Backup Restoration

The application automatically looks for WordPress backup files in the `backup/` directory. Currently configured to look for:
- `wordpress_20250707_ 2200.zip`

### How Backup Restoration Works

1. The application checks for the backup zip file
2. If found, it extracts the contents to a temporary directory
3. Locates the WordPress installation (by finding `wp-config.php`)
4. Copies all WordPress files to the `wordpress_data` volume mount
5. Starts the containers with the restored data

### Adding Your Own Backup

1. Place your WordPress backup zip file in the `backup/` directory
2. Update the backup filename in `src/WordpressAspire.AppHost/Program.cs` (line 30)
3. Rebuild and run the application

## Container Configuration

### MariaDB Container
- **Image**: `mariadb:10.6`
- **Port**: 3306
- **Database**: `wordpress`
- **User**: `wordpress_user`
- **Password**: `wordpress_password`
- **Root Password**: `wordpress_root_password`
- **Volume**: `mariadb_data` → `/var/lib/mysql`

### WordPress Container
- **Image**: `wordpress:latest`
- **Port**: 8080 (mapped to container port 80)
- **Database Host**: MariaDB container hostname
- **Volume**: `wordpress_data` → `/var/www/html`
- **Dependencies**: MariaDB container

## Accessing WordPress

Once the application is running:
- **WordPress Site**: http://localhost:8080
- **WordPress Admin**: http://localhost:8080/wp-admin

## Accessing Management Tools

- **WordPress Site**: http://localhost:8080
- **WordPress Admin**: http://localhost:8080/wp-admin
- **phpMyAdmin (MariaDB Management)**: http://localhost:8081
    - **Username**: wordpress_user
    - **Password**: wordpress_password

## Environment Variables

The following environment variables are automatically configured:

### MariaDB
- `MYSQL_ROOT_PASSWORD`: wordpress_root_password
- `MYSQL_DATABASE`: wordpress
- `MYSQL_USER`: wordpress_user
- `MYSQL_PASSWORD`: wordpress_password

### WordPress
- `WORDPRESS_DB_HOST`: mariadb container hostname
- `WORDPRESS_DB_NAME`: wordpress
- `WORDPRESS_DB_USER`: wordpress_user
- `WORDPRESS_DB_PASSWORD`: wordpress_password
- `WORDPRESS_DB_PORT`: 3306

## Troubleshooting

### Common Issues

1. **Port Already in Use**: If port 8080 is already in use, change the port mapping in `Program.cs`
2. **Backup Not Found**: Ensure your backup file is in the correct location and filename
3. **Database Connection Issues**: Check that MariaDB container is running and accessible
4. **Permission Issues**: Ensure Docker has proper permissions to create volumes

### Logs

Check container logs for debugging:
```bash
docker logs wordpressaspire-wordpress-1
docker logs wordpressaspire-mariadb-1
```

## Development

### Project Structure
```
WordpressAspire/
├── src/
│   ├── WordpressAspire.AppHost/     # Main application host
│   ├── WordpressAspire.WordPress/   # WordPress extensions
│   └── WordpressAspire.Database/    # Database extensions
├── backup/                          # WordPress backup files
└── README.md
```

### Adding Features

1. **Custom WordPress Configuration**: Modify `WordPressExtensions.cs`
2. **Database Customization**: Modify `MariaDBExtensions.cs`
3. **Backup Processing**: Enhance the backup restoration logic in `Program.cs`

## Security Notes

- Default passwords are used for demonstration
- In production, use strong, unique passwords
- Consider using Docker secrets for sensitive data
- Regularly update container images for security patches 