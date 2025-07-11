# Step 5: Download & Set Up WordPress Files
# This script downloads WordPress and sets up the file structure

Write-Host "Step 5: Setting up WordPress files..." -ForegroundColor Green

# Download WordPress
Write-Host "Downloading latest WordPress..." -ForegroundColor Yellow
wsl -d Alpine wget -O ~/latest.zip https://wordpress.org/latest.zip

# Extract WordPress
Write-Host "Extracting WordPress..." -ForegroundColor Yellow
wsl -d Alpine unzip -o ~/latest.zip -d ~/

# Move WordPress to web directory (using root)
Write-Host "Moving WordPress to web directory..." -ForegroundColor Yellow
wsl -d Alpine -u root mv /home/andrei/wordpress /var/www/

# Set proper permissions (using root)
Write-Host "Setting file permissions..." -ForegroundColor Yellow
wsl -d Alpine -u root chown -R nginx:nginx /var/www/wordpress
wsl -d Alpine -u root chmod -R 755 /var/www/wordpress

Write-Host "Step 5 completed successfully!" -ForegroundColor Green
Write-Host "WordPress files have been downloaded and configured." -ForegroundColor Cyan 

# === VERIFY WORDPRESS INSTALLATION ===
Write-Host "\nVerifying WordPress installation..." -ForegroundColor Magenta
wsl -d Alpine -u root test -d /var/www/wordpress
$dirExists = ($LASTEXITCODE -eq 0)
if ($dirExists) {
    $files = @("wp-config-sample.php", "wp-login.php", "index.php")
    $missingFiles = @()
    foreach ($file in $files) {
        wsl -d Alpine -u root test -f /var/www/wordpress/$file
        if ($LASTEXITCODE -ne 0) {
            $missingFiles += $file
        }
    }
    if ($missingFiles.Count -eq 0) {
        Write-Host "[OK] WordPress core files found. Installation appears successful!" -ForegroundColor Green
    } else {
        Write-Host "[ERROR] The following WordPress files are missing:" -ForegroundColor Red
        $missingFiles | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    }
} else {
    Write-Host "[ERROR] /var/www/wordpress directory does not exist. WordPress installation failed!" -ForegroundColor Red
} 