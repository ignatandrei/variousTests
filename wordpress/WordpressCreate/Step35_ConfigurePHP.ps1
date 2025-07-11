# Step 35: Configure PHP under Nginx
# This script installs and configures PHP-FPM to work with Nginx

Write-Host "Step 35: Configuring PHP under Nginx..." -ForegroundColor Green

# Install PHP and PHP-FPM
Write-Host "Installing PHP and PHP-FPM..." -ForegroundColor Yellow
wsl -d Alpine -u root apk add --no-cache php81 php81-fpm php81-mysqli php81-mbstring php81-xml php81-curl

# Create PHP-FPM configuration
Write-Host "Configuring PHP-FPM..." -ForegroundColor Yellow
wsl -d Alpine -u root sh -c 'cat <<EOF > /etc/php81/php-fpm.d/www.conf
listen = 127.0.0.1:9000
user = nginx
group = nginx
pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
EOF'

# Create test.php file (use printf for compatibility)
Write-Host "Creating test.php file..." -ForegroundColor Yellow
wsl -d Alpine -u root sh -c 'printf "%s" "<?php phpinfo(); ?>" > /var/www/html/test.php'

# Update Nginx configuration to handle PHP (PowerShell here-string approach)
Write-Host "Updating Nginx configuration for PHP..." -ForegroundColor Yellow
$nginxConfig = @'
server {
    listen 80;
    root /var/www/html;
    index index.php index.html;

    location ~ \.php$ {
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location / {
        try_files $uri $uri/ =404;
    }
}
'@

$nginxConfig | wsl -d Alpine -u root tee /etc/nginx/http.d/default.conf

# Display the content of the configuration file
Write-Host "Nginx configuration file content:" -ForegroundColor Cyan
wsl -d Alpine -u root sh -c "cat /etc/nginx/http.d/default.conf"

# Set proper permissions
Write-Host "Setting permissions..." -ForegroundColor Yellow
wsl -d Alpine -u root chown -R nginx:nginx /var/www/html
wsl -d Alpine -u root chmod -R 755 /var/www/html

# Stop PHP-FPM if running, then start cleanly
Write-Host "Restarting PHP-FPM..." -ForegroundColor Yellow
wsl -d Alpine -u root pkill php-fpm81
Start-Sleep -Seconds 1
wsl -d Alpine -u root php-fpm81

# Wait a moment for PHP-FPM to start
Start-Sleep -Seconds 2

# Test PHP-FPM configuration
Write-Host "Testing PHP-FPM..." -ForegroundColor Yellow
$phpFpmStatus = wsl -d Alpine -u root netstat -tlnp 2>&1 | Select-String ":9000"
if ($phpFpmStatus) {
    Write-Host "[OK] PHP-FPM is listening on port 9000" -ForegroundColor Green
} else {
    Write-Host "[ERROR] PHP-FPM is not listening on port 9000" -ForegroundColor Red
}

# Reload Nginx with new configuration
Write-Host "Reloading Nginx..." -ForegroundColor Yellow
wsl -d Alpine -u root nginx -s reload

# Wait a moment
Start-Sleep -Seconds 3

# Test PHP with curl (run inside WSL)
Write-Host "Testing PHP with curl..." -ForegroundColor Yellow
try {
    $response = wsl -d Alpine -u root curl -s http://localhost:80/test.php
    if ($response -and $response -match "phpinfo") {
        Write-Host "[OK] PHP is working correctly" -ForegroundColor Green
    } else {
        Write-Host "[ERROR] PHP is not working correctly" -ForegroundColor Red
        Write-Host "Response: $response" -ForegroundColor Red
    }
} catch {
    Write-Host "[ERROR] Failed to access PHP test page" -ForegroundColor Red
}

# Test that HTML still works (run inside WSL)
Write-Host "Testing HTML still works..." -ForegroundColor Yellow
try {
    $response = wsl -d Alpine -u root curl -s http://localhost:80/test.html
    if ($response -and $response -match "Nginx is working") {
        Write-Host "[OK] HTML pages still work" -ForegroundColor Green
    } else {
        Write-Host "[ERROR] HTML pages are not working" -ForegroundColor Red
    }
} catch {
    Write-Host "[ERROR] Failed to access HTML test page" -ForegroundColor Red
}

Write-Host "`nStep 35 completed!" -ForegroundColor Green
Write-Host "PHP test page should be available at: http://localhost:80/test.php" -ForegroundColor Cyan
Write-Host "HTML test page should be available at: http://localhost:80/test.html" -ForegroundColor Cyan 