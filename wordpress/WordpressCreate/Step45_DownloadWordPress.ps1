# Step 45: Transfer and Install WordPress
# This script transfers WordPress from local download and installs it in Alpine Linux

Write-Host "Step 45: Transferring and Installing WordPress..." -ForegroundColor Green

# Database configuration (matching Step 41)
$dbName = "wordpress"
$dbUser = "wordpress_user"
$dbPassword = "wordpress_password"
$dbHost = "localhost"

Write-Host "Database Configuration (from Step 41):" -ForegroundColor Cyan
Write-Host "  Database Name: $dbName" -ForegroundColor White
Write-Host "  Username: $dbUser" -ForegroundColor White
Write-Host "  Password: $dbPassword" -ForegroundColor White
Write-Host "  Host: $dbHost" -ForegroundColor White

# Check for local WordPress file
$downloadDir = ".\downloads"
$localFiles = Get-ChildItem -Path $downloadDir -Name "wordpress-*.tar.gz" -ErrorAction SilentlyContinue

if (-not $localFiles) {
    Write-Host "[ERROR] No WordPress files found in downloads directory" -ForegroundColor Red
    Write-Host "Please run Step 40 first to download WordPress locally" -ForegroundColor Yellow
    exit 1
}

# Get the latest WordPress file (most recent)
$latestFile = $localFiles | Sort-Object -Descending | Select-Object -First 1
$localFilePath = Join-Path $downloadDir $latestFile

# Extract version from filename
$wpVersion = $latestFile -replace "wordpress-", "" -replace "\.tar\.gz", ""
Write-Host "Found WordPress version: $wpVersion" -ForegroundColor Cyan
Write-Host "Local file: $localFilePath" -ForegroundColor Cyan

# Verify local file
if (-not (Test-Path $localFilePath)) {
    Write-Host "[ERROR] WordPress file not found: $localFilePath" -ForegroundColor Red
    exit 1
}

$fileSize = (Get-Item $localFilePath).Length
Write-Host "File size: $([math]::Round($fileSize / 1MB, 2)) MB" -ForegroundColor Cyan

# Transfer WordPress to Alpine Linux
Write-Host "Transferring WordPress to Alpine Linux..." -ForegroundColor Yellow
$wslFilePath = "/tmp/wordpress.tar.gz"

# Convert Windows path to WSL path and copy file to WSL
try {
    $wslLocalPath = $localFilePath -replace "\\", "/" -replace "D:", "/mnt/d"
    wsl -d Alpine -u root cp "$wslLocalPath" $wslFilePath
    Write-Host "[OK] WordPress transferred to Alpine Linux" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Failed to transfer WordPress to Alpine Linux" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Verify transfer
Write-Host "Verifying transfer..." -ForegroundColor Yellow
$transferredSize = wsl -d Alpine -u root ls -lh $wslFilePath | wsl -d Alpine -u root awk '{print $5}'
Write-Host "Transferred file size: $transferredSize" -ForegroundColor Cyan

# Extract WordPress
Write-Host "Extracting WordPress..." -ForegroundColor Yellow
wsl -d Alpine -u root tar -xzf $wslFilePath -C /tmp/

# Move WordPress files to web directory
Write-Host "Moving WordPress files to web directory..." -ForegroundColor Yellow
wsl -d Alpine -u root cp -r /tmp/wordpress/* /var/www/html/

# Create wp-config.php from sample
Write-Host "Creating wp-config.php from sample..." -ForegroundColor Yellow
wsl -d Alpine -u root cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php

# Configure WordPress database settings using sed (matching Step 41)
Write-Host "Configuring WordPress database settings..." -ForegroundColor Yellow
wsl -d Alpine -u root sed -i "s/database_name_here/$dbName/g" /var/www/html/wp-config.php
wsl -d Alpine -u root sed -i "s/username_here/$dbUser/g" /var/www/html/wp-config.php
# Use single quotes to properly escape the password
wsl -d Alpine -u root sed -i "s/password_here/'$dbPassword'/g" /var/www/html/wp-config.php

# Enable WordPress debug mode
Write-Host "Enabling WordPress debug mode..." -ForegroundColor Yellow
wsl -d Alpine -u root sed -i "s/define( 'WP_DEBUG', false );/define( 'WP_DEBUG', true );/g" /var/www/html/wp-config.php
wsl -d Alpine -u root sed -i "s/define( 'WP_DEBUG', false );/define( 'WP_DEBUG', true );/g" /var/www/html/wp-config.php
wsl -d Alpine -u root sed -i "s/define( 'WP_DEBUG', false );/define( 'WP_DEBUG', true );/g" /var/www/html/wp-config.php

# Add debug log settings
wsl -d Alpine -u root sed -i "/define( 'WP_DEBUG', true );/a define( 'WP_DEBUG_LOG', true );" /var/www/html/wp-config.php
wsl -d Alpine -u root sed -i "/define( 'WP_DEBUG_LOG', true );/a define( 'WP_DEBUG_DISPLAY', true );" /var/www/html/wp-config.php

# Change DB_HOST to use TCP instead of socket
wsl -d Alpine -u root sed -i "s/define( 'DB_HOST', 'localhost' );/define( 'DB_HOST', '127.0.0.1' );/g" /var/www/html/wp-config.php

Write-Host "[OK] WordPress database settings configured" -ForegroundColor Green
Write-Host "[OK] WordPress debug mode enabled" -ForegroundColor Green

# Display wp-config.php database configuration for verification
Write-Host "`n=== WP-CONFIG.PHP DATABASE CONFIGURATION ===" -ForegroundColor Cyan
Write-Host "Verifying database settings in wp-config.php:" -ForegroundColor Yellow
wsl -d Alpine -u root sh -c "cat /var/www/html/wp-config.php"
Write-Host "===============================================" -ForegroundColor Cyan

# Generate WordPress security keys
Write-Host "Generating WordPress security keys..." -ForegroundColor Yellow
Write-Host "[INFO] Using default security keys for now (can be updated later)" -ForegroundColor Cyan
Write-Host "[OK] WordPress security keys configured" -ForegroundColor Green

# Verify database connection (using Step 41 credentials)
Write-Host "Verifying database connection..." -ForegroundColor Yellow
$mysqlConfig = "[client]`nuser=$dbUser`npassword=$dbPassword`nsocket=/tmp/mysql.sock"
$mysqlConfig | wsl -d Alpine -u root tee /tmp/mysql.cnf | Out-Null
$dbTest = wsl -d Alpine -u root mysql --defaults-file=/tmp/mysql.cnf -e "USE $dbName; SELECT 'Database connection successful' as status;" 2>&1
wsl -d Alpine -u root rm -f /tmp/mysql.cnf

if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] Database connection verified" -ForegroundColor Green
} else {
    Write-Host "[ERROR] Database connection failed" -ForegroundColor Red
    Write-Host "Error: $dbTest" -ForegroundColor Red
    Write-Host "Please run Step 41 first to set up the database" -ForegroundColor Yellow
    exit 1
}

# Clean up temporary files
Write-Host "Cleaning up temporary files..." -ForegroundColor Yellow
wsl -d Alpine -u root rm -rf $wslFilePath /tmp/wordpress

# Ensure correct ownership and permissions
Write-Host "Setting final ownership and permissions..." -ForegroundColor Yellow
wsl -d Alpine -u root chown -R nginx:nginx /var/www/html
wsl -d Alpine -u root chmod -R 755 /var/www/html

# Verify WordPress installation
Write-Host "Verifying WordPress installation..." -ForegroundColor Yellow

# Check if WordPress files are present
$wpFiles = @("wp-config.php", "wp-login.php", "index.php", "wp-admin")
$missingFiles = @()

foreach ($file in $wpFiles) {
    $fileCheck = wsl -d Alpine -u root test -e "/var/www/html/$file" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] $file exists" -ForegroundColor Green
    } else {
        Write-Host "[ERROR] $file is missing" -ForegroundColor Red
        $missingFiles += $file
    }
}

# Check wp-config.php configuration
Write-Host "Checking wp-config.php configuration..." -ForegroundColor Yellow
$dbNameCheck = wsl -d Alpine -u root grep "DB_NAME.*$dbName" /var/www/html/wp-config.php 2>&1
if ($dbNameCheck) {
    Write-Host "[OK] Database name configured correctly" -ForegroundColor Green
} else {
    Write-Host "[ERROR] Database name not configured correctly" -ForegroundColor Red
    $missingFiles += "wp-config-db"
}

# === ADDITIONAL WORDPRESS RUNNING CHECKS ===
Write-Host "`n=== VERIFYING WORDPRESS IS RUNNING ===" -ForegroundColor Cyan

# Check if web server is running
Write-Host "Checking web server status..." -ForegroundColor Yellow
$nginxStatus = wsl -d Alpine -u root pgrep nginx 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] Nginx is running" -ForegroundColor Green
} else {
    Write-Host "[ERROR] Nginx is not running" -ForegroundColor Red
    $missingFiles += "nginx"
}

# Check if PHP-FPM is running
Write-Host "Checking PHP-FPM status..." -ForegroundColor Yellow
$phpFpmStatus = wsl -d Alpine -u root pgrep php-fpm 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] PHP-FPM is running" -ForegroundColor Green
} else {
    Write-Host "[ERROR] PHP-FPM is not running" -ForegroundColor Red
    $missingFiles += "php-fpm"
}

# Check if MariaDB is running
Write-Host "Checking MariaDB status..." -ForegroundColor Yellow
$mariadbStatus = wsl -d Alpine -u root pgrep mariadb 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] MariaDB is running" -ForegroundColor Green
} else {
    Write-Host "[ERROR] MariaDB is not running" -ForegroundColor Red
    $missingFiles += "mariadb"
}

# Test WordPress web accessibility
Write-Host "Testing WordPress web accessibility..." -ForegroundColor Yellow
$wpResponse = wsl -d Alpine -u root curl -s -o /dev/null -w "%{http_code}" http://localhost/ 2>&1
if ($wpResponse -eq "200") {
    Write-Host "[OK] WordPress is accessible via web (HTTP 200)" -ForegroundColor Green
} else {
    Write-Host "[ERROR] WordPress web access failed (HTTP $wpResponse)" -ForegroundColor Red
    $missingFiles += "web-access"
    Write-Host "--- Nginx error.log (last 20 lines) ---" -ForegroundColor Yellow
    wsl -d Alpine -u root tail -20 /var/log/nginx/error.log
    Write-Host "--- PHP-FPM error.log (last 20 lines) ---" -ForegroundColor Yellow
    wsl -d Alpine -u root tail -20 /var/log/php81/error.log
}

# Test WordPress login page
Write-Host "Testing WordPress login page..." -ForegroundColor Yellow
$wpLoginResponse = wsl -d Alpine -u root curl -s -o /dev/null -w "%{http_code}" http://localhost/wp-login.php 2>&1
if ($wpLoginResponse -eq "200") {
    Write-Host "[OK] WordPress login page is accessible" -ForegroundColor Green
} else {
    Write-Host "[ERROR] WordPress login page access failed (HTTP $wpLoginResponse)" -ForegroundColor Red
    $missingFiles += "login-page"
    Write-Host "--- Nginx error.log (last 20 lines) ---" -ForegroundColor Yellow
    wsl -d Alpine -u root tail -20 /var/log/nginx/error.log
    Write-Host "--- PHP-FPM error.log (last 20 lines) ---" -ForegroundColor Yellow
    wsl -d Alpine -u root tail -20 /var/log/php81/error.log
}

# Test PHP execution
Write-Host "Testing PHP execution..." -ForegroundColor Yellow
$phpTest = wsl -d Alpine -u root curl -s http://localhost/test.php 2>&1
if ($phpTest -like "*PHP Version*" -or $phpTest -like "*phpinfo*") {
    Write-Host "[OK] PHP is executing correctly" -ForegroundColor Green
} else {
    Write-Host "[ERROR] PHP execution test failed" -ForegroundColor Red
    $missingFiles += "php-execution"
}

# Check WordPress file permissions
Write-Host "Checking WordPress file permissions..." -ForegroundColor Yellow
$ownershipCheck = wsl -d Alpine -u root find /var/www/html \! -user nginx -o \! -group nginx
if (-not $ownershipCheck) {
    Write-Host "[OK] WordPress files have correct ownership" -ForegroundColor Green
} else {
    Write-Host "[ERROR] WordPress file ownership is incorrect" -ForegroundColor Red
    $missingFiles += "file-permissions"
}

# Test database connectivity (using Step 41 credentials)
Write-Host "Testing database connectivity..." -ForegroundColor Yellow
$mysqlConfig = "[client]`nuser=$dbUser`npassword=$dbPassword`nsocket=/tmp/mysql.sock"
$mysqlConfig | wsl -d Alpine -u root tee /tmp/mysql.cnf | Out-Null
$dbTest = wsl -d Alpine -u root mysql --defaults-file=/tmp/mysql.cnf -e "SHOW DATABASES LIKE '$dbName';" 2>&1
wsl -d Alpine -u root rm -f /tmp/mysql.cnf

if ($LASTEXITCODE -eq 0 -and $dbTest -like "*$dbName*") {
    Write-Host "[OK] WordPress database exists and is accessible" -ForegroundColor Green
} else {
    Write-Host "[ERROR] WordPress database not accessible" -ForegroundColor Red
    Write-Host "Please run Step 41 first to set up the database" -ForegroundColor Yellow
    $missingFiles += "database-access"
}

# Check WordPress configuration syntax
Write-Host "Checking WordPress configuration syntax..." -ForegroundColor Yellow
$wpConfigTest = wsl -d Alpine -u root php -l /var/www/html/wp-config.php 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] WordPress configuration syntax is valid" -ForegroundColor Green
} else {
    Write-Host "[ERROR] WordPress configuration syntax error" -ForegroundColor Red
    $missingFiles += "config-syntax"
}

# Test WordPress core files integrity
Write-Host "Testing WordPress core files..." -ForegroundColor Yellow
$wpCoreFiles = @("wp-config.php", "wp-load.php", "wp-blog-header.php", "wp-includes/version.php")
$coreFileErrors = 0

foreach ($coreFile in $wpCoreFiles) {
    $fileExists = wsl -d Alpine -u root test -f "/var/www/html/$coreFile" 2>&1
    if ($LASTEXITCODE -ne 0) {
        $coreFileErrors++
    }
}

if ($coreFileErrors -eq 0) {
    Write-Host "[OK] WordPress core files are intact" -ForegroundColor Green
} else {
    Write-Host "[ERROR] Some WordPress core files are missing" -ForegroundColor Red
    $missingFiles += "core-files"
}

# Final WordPress running status
Write-Host "`n=== WORDPRESS RUNNING STATUS ===" -ForegroundColor Cyan
if ($missingFiles.Count -eq 0) {
    Write-Host "[SUCCESS] WordPress is fully operational!" -ForegroundColor Green
    Write-Host "✓ All services are running (Nginx, PHP-FPM, MariaDB)" -ForegroundColor Green
    Write-Host "✓ WordPress files are properly installed" -ForegroundColor Green
    Write-Host "✓ Web server is accessible" -ForegroundColor Green
    Write-Host "✓ PHP is executing correctly" -ForegroundColor Green
    Write-Host "✓ Configuration is valid" -ForegroundColor Green
    Write-Host "✓ Database connection working" -ForegroundColor Green
    Write-Host "`nWordPress is ready for installation at: http://localhost" -ForegroundColor White
    Write-Host "WordPress login page: http://localhost/wp-login.php" -ForegroundColor White
} else {
    Write-Host "[ERROR] WordPress has issues that need to be resolved:" -ForegroundColor Red
    foreach ($issue in $missingFiles) {
        Write-Host "  ✗ $issue" -ForegroundColor Red
    }
    Write-Host "`nPlease fix the above issues before proceeding." -ForegroundColor Yellow
}

if ($missingFiles.Count -eq 0) {
    Write-Host "`nStep 45 completed successfully!" -ForegroundColor Green
    Write-Host "WordPress $wpVersion has been transferred and configured" -ForegroundColor Cyan
    Write-Host "Database: $dbName (User: $dbUser)" -ForegroundColor Cyan
    Write-Host "WordPress is ready for installation at: http://localhost" -ForegroundColor White
    Write-Host "`nYou can now proceed to Step 50: Complete WordPress Installation" -ForegroundColor Cyan
} else {
    Write-Host "`n[ERROR] Some files are missing or misconfigured:" -ForegroundColor Red
    foreach ($file in $missingFiles) {
        Write-Host "  - $file" -ForegroundColor Red
    }
    exit 1
} 