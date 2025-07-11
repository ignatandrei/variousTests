# Step 6: Configure wp-config.php
# This script configures WordPress database connection settings

Write-Host "Step 6: Configuring WordPress database settings..." -ForegroundColor Green

# Copy sample config (using root)
Write-Host "Creating wp-config.php from sample..." -ForegroundColor Yellow
wsl -d Alpine -u root cp /var/www/wordpress/wp-config-sample.php /var/www/wordpress/wp-config.php

# Update database settings in wp-config.php (using root)
Write-Host "Updating database configuration..." -ForegroundColor Yellow
wsl -d Alpine -u root sed -i "s/database_name_here/wordpress/" /var/www/wordpress/wp-config.php
wsl -d Alpine -u root sed -i "s/username_here/wpuser/" /var/www/wordpress/wp-config.php
wsl -d Alpine -u root sed -i "s/password_here/yourpassword/" /var/www/wordpress/wp-config.php

# Update DB_HOST to use custom socket - use a simpler approach
Write-Host "Setting custom socket path for MariaDB..." -ForegroundColor Yellow
wsl -d Alpine -u root sh -c "sed -i 's|define( '\''DB_HOST'\'', '\''localhost'\'' );|define( '\''DB_HOST'\'', '\''localhost:/tmp/mysql.sock'\'' );|' /var/www/wordpress/wp-config.php"

# Generate authentication keys (simplified approach)
Write-Host "Generating authentication keys..." -ForegroundColor Yellow
$authKeys = wsl -d Alpine curl -s https://api.wordpress.org/secret-key/1.1/salt/

# Replace the authentication keys section in wp-config.php
wsl -d Alpine -u root sh -c "sed -i '/define.*AUTH_KEY/,/define.*NONCE_SALT/d' /var/www/wordpress/wp-config.php"

# Write auth keys to a temp file in Windows
$tempAuthFile = Join-Path $env:TEMP 'wp_auth_keys.txt'
$authKeys | Out-File -FilePath $tempAuthFile -Encoding ASCII

# Copy the temp file to Alpine and append to wp-config.php
$winUser = $env:USERNAME
wsl -d Alpine -u root sh -c "cat /mnt/c/Users/$winUser/AppData/Local/Temp/wp_auth_keys.txt >> /var/www/wordpress/wp-config.php"
Remove-Item $tempAuthFile -ErrorAction SilentlyContinue

# Set proper permissions for wp-config.php
wsl -d Alpine -u root chown nginx:nginx /var/www/wordpress/wp-config.php
wsl -d Alpine -u root chmod 644 /var/www/wordpress/wp-config.php

Write-Host "Step 6 completed successfully!" -ForegroundColor Green
Write-Host "WordPress configuration has been updated with database settings." -ForegroundColor Cyan
Write-Host "IMPORTANT: Remember to change 'yourpassword' to your actual database password!" -ForegroundColor Red 

# === VERIFY WORDPRESS CONFIGURATION ===
Write-Host "`nVerifying WordPress configuration..." -ForegroundColor Magenta
# Check if wp-config.php exists
wsl -d Alpine -u root test -f /var/www/wordpress/wp-config.php
if ($LASTEXITCODE -eq 0) {
    # Check DB name, user, password, host
    $configContent = wsl -d Alpine -u root cat /var/www/wordpress/wp-config.php
    $dbOk = $configContent -match "define\(\s*'DB_NAME'\s*,\s*'wordpress'\s*\)" 
    $userOk = $configContent -match "define\(\s*'DB_USER'\s*,\s*'wpuser'\s*\)"
    $passOk = $configContent -match "define\(\s*'DB_PASSWORD'\s*,\s*'yourpassword'\s*\)"
    $hostOk = $configContent -match "define\(\s*'DB_HOST'\s*,\s*'localhost:/tmp/mysql.sock'\s*\)"
    $keysOk = $configContent -match "define\('AUTH_KEY'" -and $configContent -match "define\('NONCE_SALT'"
    if ($dbOk -and $userOk -and $passOk -and $hostOk -and $keysOk) {
        Write-Host "[OK] wp-config.php exists and contains correct database settings and keys." -ForegroundColor Green
    } else {
        Write-Host "[ERROR] wp-config.php is missing or has incorrect settings:" -ForegroundColor Red
        if (-not $dbOk) { Write-Host "  - DB_NAME is not set to 'wordpress'" -ForegroundColor Red }
        if (-not $userOk) { Write-Host "  - DB_USER is not set to 'wpuser'" -ForegroundColor Red }
        if (-not $passOk) { Write-Host "  - DB_PASSWORD is not set to 'yourpassword'" -ForegroundColor Red }
        if (-not $hostOk) { Write-Host "  - DB_HOST is not set to 'localhost:/tmp/mysql.sock'" -ForegroundColor Red }
        if (-not $keysOk) { Write-Host "  - Authentication keys are missing or incomplete" -ForegroundColor Red }
    }
} else {
    Write-Host "[ERROR] wp-config.php does not exist!" -ForegroundColor Red
} 