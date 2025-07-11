# Step 7: Configure and Start Nginx/PHP-FPM with Localhost Verification
Write-Host "Step 7: Configuring Nginx and starting web services..."

# 1. Create Nginx config for WordPress
$nginxConf = @"
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name localhost;
    root /var/www/wordpress;
    index index.php index.html;
    location / {
        try_files $uri $uri/ /index.php?$args;
    }
    location ~ \.php$ {
        fastcgi_pass   127.0.0.1:9000;
        fastcgi_index  index.php;
        fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
        include        fastcgi_params;
    }
    location ~ /\.ht {
        deny all;
    }
}
"@

$tempConf = "$env:TEMP\wordpress.conf"
Set-Content -Path $tempConf -Value @'
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name localhost;
    root /var/www/wordpress;
    index index.php index.html;
    location / {
        try_files $uri $uri/ /index.php?$args;
    }
    location ~ \.php$ {
        fastcgi_pass   127.0.0.1:9000;
        fastcgi_index  index.php;
        fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
        include        fastcgi_params;
    }
    location ~ /\.ht {
        deny all;
    }
}
'@ -Encoding ASCII

# Copy the configuration directly to Alpine
$winUser = $env:USERNAME
wsl -d Alpine -u root cp /etc/nginx/http.d/default.conf /etc/nginx/http.d/default.conf.bak
wsl -d Alpine -u root sh -c "cat /mnt/c/Users/$winUser/AppData/Local/Temp/wordpress.conf > /etc/nginx/http.d/default.conf"

# 2. Test Nginx configuration
Write-Host "Testing Nginx configuration..."
$nginxTest = wsl -d Alpine -u root nginx -t 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "Nginx configuration is valid."
} else {
    Write-Host "Nginx configuration has errors:"
    Write-Host $nginxTest
    exit 1
}

# 3. Ensure PHP-FPM is running
Write-Host "Checking PHP-FPM status..."
$phpFpmRunning = wsl -d Alpine -u root pgrep php-fpm
if (-not $phpFpmRunning) {
    Write-Host "Starting PHP-FPM..."
    Start-Process wsl -ArgumentList '-d','Alpine','-u','root','/usr/sbin/php-fpm81','-F' -WindowStyle Hidden
    Start-Sleep -Seconds 5
    $phpFpmRunning = wsl -d Alpine -u root pgrep php-fpm
    if (-not $phpFpmRunning) {
        Write-Host "Failed to start PHP-FPM."
        exit 1
    }
}

# 4. Ensure Nginx is running
Write-Host "Checking Nginx status..."
$nginxRunning = wsl -d Alpine -u root pgrep nginx
if ($nginxRunning) {
    Write-Host "Reloading Nginx with new configuration..."
    wsl -d Alpine -u root nginx -s reload
} else {
    Write-Host "Starting Nginx..."
    wsl -d Alpine -u root nginx
    Start-Sleep -Seconds 3
    $nginxRunning = wsl -d Alpine -u root pgrep nginx
    if (-not $nginxRunning) {
        Write-Host "Failed to start Nginx."
        exit 1
    }
}

# 5. Final status checks
Write-Host "\n=== FINAL SERVICE STATUS ==="
$nginxRunning = wsl -d Alpine -u root pgrep nginx
$phpFpmRunning = wsl -d Alpine -u root pgrep php-fpm
$mariadbRunning = wsl -d Alpine -u root pgrep mariadb
if ($nginxRunning) { Write-Host "Nginx is running (PIDs: $nginxRunning)" } else { Write-Host "Nginx is not running" }
if ($phpFpmRunning) { Write-Host "PHP-FPM is running (PIDs: $phpFpmRunning)" } else { Write-Host "PHP-FPM is not running" }
if ($mariadbRunning) { Write-Host "MariaDB is running (PIDs: $mariadbRunning)" } else { Write-Host "MariaDB is not running" }

# 6. Localhost verification
Write-Host "\n=== VERIFYING LOCALHOST ACCESS ==="
Write-Host "Testing localhost connectivity..."
try {
    $response = Invoke-WebRequest -Uri "http://localhost" -TimeoutSec 10 -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        Write-Host "localhost is accessible (HTTP 200)"
    } else {
        Write-Host "localhost responded with status: $($response.StatusCode)"
    }
} catch {
    Write-Host "Failed to connect to localhost: $($_.Exception.Message)"
}

Write-Host "\nStep 7 completed successfully!"
Write-Host "Nginx and PHP-FPM are now running with WordPress configuration."
Write-Host "Your WordPress site should be accessible at: http://localhost" 