# Step 1: Install Alpine Linux from Microsoft Store and Prepare WordPress Packages
# This script opens Microsoft Store for Alpine Linux installation and then installs WordPress dependencies.
wsl --unregister Alpine

Write-Host "Step 1: Installing Alpine Linux from Microsoft Store and preparing WordPress dependencies..." -ForegroundColor Green

# Open Microsoft Store to Alpine Linux page
Write-Host "Opening Microsoft Store to Alpine Linux page..." -ForegroundColor Yellow
Start-Process "ms-windows-store://pdp/?ProductId=9P804CRF0395"

Write-Host "Please install Alpine Linux from the Microsoft Store that just opened." -ForegroundColor Cyan
Write-Host "After installation, open Alpine Linux from the Start Menu and create a user if prompted." -ForegroundColor Cyan
Write-Host "Once Alpine is installed and initialized, press Enter to continue..." -ForegroundColor Yellow
Pause

# Show available WSL distributions
Write-Host "Available WSL distributions:" -ForegroundColor Cyan
wsl -l -v

Write-Host "Proceeding with WordPress package installation on Alpine..." -ForegroundColor Green

# Update package index (run as root)
Write-Host "Updating Alpine package index..." -ForegroundColor Yellow
wsl -d Alpine -u root apk update

# Install required packages for WordPress (run as root)
Write-Host "Installing WordPress dependencies..." -ForegroundColor Yellow
wsl -d Alpine -u root apk add mariadb mariadb-client php php-fpm php-mysqli php-json php-session php-xml php-gd php-curl php-zip nginx unzip wget curl

Write-Host "Step 1 completed successfully!" -ForegroundColor Green
Write-Host "Alpine Linux and all required packages for WordPress have been installed." -ForegroundColor Cyan

# Error handling and verification section
Write-Host "`n=== VERIFYING ALPINE INSTALLATION AND PACKAGES ===" -ForegroundColor Magenta

# Check if Alpine distribution exists
Write-Host "Checking if Alpine distribution is available..." -ForegroundColor Yellow
try {
    # Try to run a simple command in Alpine to test if it's available
    $alpineTest = wsl -d Alpine -u root echo "Alpine is working" 2>&1
    if ($alpineTest -eq "Alpine is working") {
        Write-Host "[OK] Alpine distribution found and working" -ForegroundColor Green
    } else {
        Write-Host "[ERROR] Alpine distribution not found or not working" -ForegroundColor Red
        Write-Host "Alpine test output: $alpineTest" -ForegroundColor Red
        Write-Host "Please ensure Alpine Linux is properly installed from Microsoft Store" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "[ERROR] Failed to check Alpine distribution" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Test Alpine connectivity and basic functionality
Write-Host "Testing Alpine connectivity..." -ForegroundColor Yellow
try {
    $alpineTest = wsl -d Alpine -u root whoami 2>&1
    if ($alpineTest -eq "root") {
        Write-Host "[OK] Alpine connectivity test passed" -ForegroundColor Green
    } else {
        Write-Host "[ERROR] Alpine connectivity test failed" -ForegroundColor Red
        Write-Host "Alpine response: $alpineTest" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "[ERROR] Alpine connectivity test failed" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Verify package installation
Write-Host "Verifying package installation..." -ForegroundColor Yellow
$requiredPackages = @("mariadb", "php", "nginx", "unzip", "wget", "curl")
$failedPackages = @()

foreach ($package in $requiredPackages) {
    try {
        $packageCheck = wsl -d Alpine -u root which $package 2>&1
        if ($packageCheck -and $packageCheck -ne "") {
            Write-Host "[OK] $package is installed" -ForegroundColor Green
        } else {
            Write-Host "[ERROR] $package is NOT installed" -ForegroundColor Red
            $failedPackages += $package
        }
    } catch {
        Write-Host "[ERROR] checking $package" -ForegroundColor Red
        $failedPackages += $package
    }
}

# Check PHP version and modules
Write-Host "Checking PHP installation..." -ForegroundColor Yellow
try {
    $phpVersion = wsl -d Alpine -u root php -v 2>&1 | Select-String "PHP"
    if ($phpVersion) {
        Write-Host "[OK] PHP is installed: $phpVersion" -ForegroundColor Green
    } else {
        Write-Host "[ERROR] PHP is not properly installed" -ForegroundColor Red
        $failedPackages += "php"
    }
} catch {
    Write-Host "[ERROR] Failed to check PHP version" -ForegroundColor Red
    $failedPackages += "php"
}

# Check PHP modules
Write-Host "Checking PHP modules..." -ForegroundColor Yellow
$requiredPhpModules = @("mysqli", "json", "session", "xml", "gd", "curl", "zip")
foreach ($module in $requiredPhpModules) {
    try {
        $moduleCheck = wsl -d Alpine -u root php -m 2>&1 | Select-String $module
        if ($moduleCheck) {
            Write-Host "[OK] PHP module $module is loaded" -ForegroundColor Green
        } else {
            Write-Host "[ERROR] PHP module $module is NOT loaded" -ForegroundColor Red
            $failedPackages += "php-$module"
        }
    } catch {
        Write-Host "[ERROR] checking PHP module $module" -ForegroundColor Red
        $failedPackages += "php-$module"
    }
}

# Check MariaDB installation
Write-Host "Checking MariaDB installation..." -ForegroundColor Yellow
try {
    $mariadbCheck = wsl -d Alpine -u root mariadb --version 2>&1
    if ($mariadbCheck -and $mariadbCheck -match "MariaDB") {
        Write-Host "[OK] MariaDB is installed: $mariadbCheck" -ForegroundColor Green
    } else {
        Write-Host "[ERROR] MariaDB is not properly installed" -ForegroundColor Red
        $failedPackages += "mariadb"
    }
} catch {
    Write-Host "[ERROR] Failed to check MariaDB version" -ForegroundColor Red
    $failedPackages += "mariadb"
}

# Check Nginx installation
Write-Host "Checking Nginx installation..." -ForegroundColor Yellow
try {
    $nginxCheck = wsl -d Alpine -u root nginx -v 2>&1
    if ($nginxCheck -and $nginxCheck -match "nginx") {
        Write-Host "[OK] Nginx is installed: $nginxCheck" -ForegroundColor Green
    } else {
        Write-Host "[ERROR] Nginx is not properly installed" -ForegroundColor Red
        $failedPackages += "nginx"
    }
} catch {
    Write-Host "[ERROR] Failed to check Nginx version" -ForegroundColor Red
    $failedPackages += "nginx"
}

# Summary and error reporting
Write-Host "`n=== INSTALLATION SUMMARY ===" -ForegroundColor Magenta
if ($failedPackages.Count -eq 0) {
    Write-Host "[OK] All packages installed successfully!" -ForegroundColor Green
    Write-Host "[OK] Alpine Linux is ready for WordPress setup" -ForegroundColor Green
} else {
    Write-Host "[ERROR] ERRORS FOUND: The following packages failed to install properly:" -ForegroundColor Red
    foreach ($package in $failedPackages) {
        Write-Host "  - $package" -ForegroundColor Red
    }
    Write-Host "`nTROUBLESHOOTING STEPS:" -ForegroundColor Yellow
    Write-Host "1. Ensure Alpine Linux is properly installed from Microsoft Store" -ForegroundColor Cyan
    Write-Host "2. Try running the package installation again:" -ForegroundColor Cyan
    Write-Host "   wsl -d Alpine -u root apk update" -ForegroundColor White
    Write-Host "   wsl -d Alpine -u root apk add mariadb mariadb-client php php-fpm php-mysqli php-json php-session php-xml php-gd php-curl php-zip nginx unzip wget curl" -ForegroundColor White
    Write-Host "3. Check WSL status: wsl -l -v" -ForegroundColor Cyan
    Write-Host "4. Restart WSL if needed: wsl --shutdown" -ForegroundColor Cyan
    exit 1
}

Write-Host "`nStep 1 verification completed successfully!" -ForegroundColor Green
Write-Host "You can now proceed to Step 2: Setup MariaDB" -ForegroundColor Cyan 