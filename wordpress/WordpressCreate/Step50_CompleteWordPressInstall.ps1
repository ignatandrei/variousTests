# Step 50: Complete WordPress Installation and Final Setup
# This script completes the WordPress installation and provides final configuration

Write-Host "Step 50: Completing WordPress Installation and Final Setup..." -ForegroundColor Green

# Install jq for JSON parsing (needed for WordPress version check)
Write-Host "Installing jq for JSON parsing..." -ForegroundColor Yellow
wsl -d Alpine -u root apk add jq

# Set proper permissions for WordPress uploads and cache
Write-Host "Setting proper permissions for WordPress..." -ForegroundColor Yellow
wsl -d Alpine -u root mkdir -p /var/www/html/wp-content/uploads
wsl -d Alpine -u root mkdir -p /var/www/html/wp-content/cache
wsl -d Alpine -u root chown -R nginx:nginx /var/www/html/wp-content
wsl -d Alpine -u root chmod -R 755 /var/www/html/wp-content

# Create .htaccess file for WordPress
Write-Host "Creating .htaccess file for WordPress..." -ForegroundColor Yellow
$htaccess = @"
# BEGIN WordPress
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteBase /
RewriteRule ^index\.php$ - [L]
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /index.php [L]
</IfModule>
# END WordPress
"@

$htaccess | wsl -d Alpine -u root tee /var/www/html/.htaccess > /dev/null
wsl -d Alpine -u root chown nginx:nginx /var/www/html/.htaccess
wsl -d Alpine -u root chmod 644 /var/www/html/.htaccess

# Test database connection
Write-Host "Testing database connection..." -ForegroundColor Yellow
$dbTest = wsl -d Alpine -u root mysql -u wordpress_user -pwordpress_password -e "USE wordpress; SELECT 1;" 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] Database connection successful" -ForegroundColor Green
} else {
    Write-Host "[ERROR] Database connection failed" -ForegroundColor Red
    Write-Host "Database test output: $dbTest" -ForegroundColor Red
    Write-Host "Please check MariaDB configuration in Step 20" -ForegroundColor Yellow
    exit 1
}

# Test web server accessibility
Write-Host "Testing web server accessibility..." -ForegroundColor Yellow
$webTest = wsl -d Alpine -u root curl -s -o /dev/null -w "%{http_code}" http://localhost/
if ($webTest -eq "200") {
    Write-Host "[OK] Web server is accessible" -ForegroundColor Green
} else {
    Write-Host "[WARNING] Web server returned status code: $webTest" -ForegroundColor Yellow
    Write-Host "This might be normal if WordPress is not fully installed yet" -ForegroundColor Yellow
}

# Test PHP functionality
Write-Host "Testing PHP functionality..." -ForegroundColor Yellow
$phpTest = wsl -d Alpine -u root curl -s http://localhost/test.php | Select-String "PHP Version"
if ($phpTest) {
    Write-Host "[OK] PHP is working correctly" -ForegroundColor Green
} else {
    Write-Host "[ERROR] PHP test failed" -ForegroundColor Red
    exit 1
}

# Create a simple status page
Write-Host "Creating status page..." -ForegroundColor Yellow
$statusPage = @"
<!DOCTYPE html>
<html>
<head>
    <title>WordPress Alpine Status</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .status { padding: 10px; margin: 10px 0; border-radius: 5px; }
        .ok { background-color: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .info { background-color: #d1ecf1; color: #0c5460; border: 1px solid #bee5eb; }
        .warning { background-color: #fff3cd; color: #856404; border: 1px solid #ffeaa7; }
    </style>
</head>
<body>
    <h1>WordPress Alpine Installation Status</h1>
    <div class="status ok">
        <strong>✓ Installation Complete!</strong><br>
        WordPress has been successfully installed on Alpine Linux.
    </div>
    <div class="status info">
        <strong>Next Steps:</strong><br>
        1. Visit <a href="http://localhost">http://localhost</a> to complete WordPress setup<br>
        2. Follow the WordPress installation wizard<br>
        3. Create your admin account and configure your site
    </div>
    <div class="status info">
        <strong>Database Information:</strong><br>
        Database: wordpress<br>
        Username: wordpress_user<br>
        Password: wordpress_password<br>
        Host: localhost
    </div>
    <div class="status warning">
        <strong>Security Note:</strong><br>
        Remember to change the default database password after installation!
    </div>
</body>
</html>
"@

$statusPage | wsl -d Alpine -u root tee /var/www/html/status.html > /dev/null

# Final verification
Write-Host "`n=== FINAL VERIFICATION ===" -ForegroundColor Magenta

# Check all services
$services = @("mariadb", "nginx", "php-fpm")
$failedServices = @()

foreach ($service in $services) {
    $serviceStatus = wsl -d Alpine -u root rc-service $service status 2>&1
    if ($serviceStatus -match "started") {
        Write-Host "[OK] $service is running" -ForegroundColor Green
    } else {
        Write-Host "[ERROR] $service is not running" -ForegroundColor Red
        $failedServices += $service
    }
}

# Check WordPress files
$wpCoreFiles = @("wp-config.php", "wp-login.php", "index.php")
$missingCoreFiles = @()

foreach ($file in $wpCoreFiles) {
    $fileCheck = wsl -d Alpine -u root test -e "/var/www/html/$file" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] WordPress $file exists" -ForegroundColor Green
    } else {
        Write-Host "[ERROR] WordPress $file is missing" -ForegroundColor Red
        $missingCoreFiles += $file
    }
}

# Summary
Write-Host "`n=== INSTALLATION SUMMARY ===" -ForegroundColor Magenta

if ($failedServices.Count -eq 0 -and $missingCoreFiles.Count -eq 0) {
    Write-Host "`n🎉 CONGRATULATIONS! WordPress installation is complete!" -ForegroundColor Green
    Write-Host "`n=== ACCESS INFORMATION ===" -ForegroundColor Cyan
    Write-Host "WordPress Site: http://localhost" -ForegroundColor White
    Write-Host "Status Page: http://localhost/status.html" -ForegroundColor White
    Write-Host "PHP Info: http://localhost/test.php" -ForegroundColor White
    Write-Host "`n=== DATABASE CREDENTIALS ===" -ForegroundColor Cyan
    Write-Host "Database: wordpress" -ForegroundColor White
    Write-Host "Username: wordpress_user" -ForegroundColor White
    Write-Host "Password: wordpress_password" -ForegroundColor White
    Write-Host "Host: localhost" -ForegroundColor White
    Write-Host "`n=== NEXT STEPS ===" -ForegroundColor Cyan
    Write-Host "1. Open your browser and go to http://localhost" -ForegroundColor White
    Write-Host "2. Follow the WordPress installation wizard" -ForegroundColor White
    Write-Host "3. Create your admin account" -ForegroundColor White
    Write-Host "4. Choose a theme and start building your site" -ForegroundColor White
    Write-Host "`n=== SECURITY RECOMMENDATIONS ===" -ForegroundColor Yellow
    Write-Host "1. Change the default database password" -ForegroundColor White
    Write-Host "2. Use strong passwords for WordPress admin" -ForegroundColor White
    Write-Host "3. Keep WordPress and plugins updated" -ForegroundColor White
    Write-Host "4. Consider installing security plugins" -ForegroundColor White
    Write-Host "`n=== TROUBLESHOOTING ===" -ForegroundColor Cyan
    Write-Host "If you encounter issues:" -ForegroundColor White
    Write-Host "- Check service status: wsl -d Alpine -u root rc-service [service] status" -ForegroundColor White
    Write-Host "- View logs: wsl -d Alpine -u root tail -f /var/log/nginx/error.log" -ForegroundColor White
    Write-Host "- Restart services: wsl -d Alpine -u root rc-service [service] restart" -ForegroundColor White
} else {
    Write-Host "`n[ERROR] Installation has issues that need to be resolved:" -ForegroundColor Red
    if ($failedServices.Count -gt 0) {
        Write-Host "Failed services:" -ForegroundColor Red
        foreach ($service in $failedServices) {
            Write-Host "  - $service" -ForegroundColor Red
        }
    }
    if ($missingCoreFiles.Count -gt 0) {
        Write-Host "Missing WordPress files:" -ForegroundColor Red
        foreach ($file in $missingCoreFiles) {
            Write-Host "  - $file" -ForegroundColor Red
        }
    }
    Write-Host "`nPlease review the previous steps and resolve these issues." -ForegroundColor Yellow
    exit 1
}

Write-Host "`nStep 50 completed successfully!" -ForegroundColor Green
Write-Host "WordPress is now ready to use on Alpine Linux!" -ForegroundColor Cyan 