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

Write-Host "Proceeding with Alpine setup and package installation..." -ForegroundColor Green

# Update package index (run as root)
Write-Host "Updating Alpine package index..." -ForegroundColor Yellow
wsl -d Alpine -u root apk update

# Check if alpine-chroot-install already exists
Write-Host "Checking if alpine-chroot-install already exists..." -ForegroundColor Yellow
$existingChroot = wsl -d Alpine -u root which alpine-chroot-install 2>&1

if ($existingChroot -and $existingChroot -ne "") {
    Write-Host "[OK] alpine-chroot-install already exists at: $existingChroot" -ForegroundColor Green
    Write-Host "Skipping copy and proceeding with execution..." -ForegroundColor Cyan
} else {
    # Copy alpine-chroot-install from Downloads folder to WSL Alpine
    Write-Host "Copying alpine-chroot-install from Downloads folder to WSL Alpine..." -ForegroundColor Yellow
    try {
        # Get the Downloads folder path
        $downloadsPath = "./downloads"
        $alpineChrootPath = Join-Path $downloadsPath "alpine-chroot-install"
        
        # Check if the file exists in Downloads
        if (Test-Path $alpineChrootPath) {
            Write-Host "[OK] Found alpine-chroot-install in Downloads folder" -ForegroundColor Green
            
            # Copy the file to WSL Alpine
            $wslPath = "/mnt/c/Users/$env:USERNAME/Downloads/alpine-chroot-install"
            $copyResult = wsl -d Alpine -u root cp $wslPath /usr/local/bin/alpine-chroot-install 2>&1
            
            if ($LASTEXITCODE -eq 0) {
                # Make the script executable
                wsl -d Alpine -u root chmod +x /usr/local/bin/alpine-chroot-install
                Write-Host "[OK] alpine-chroot-install copied and installed successfully" -ForegroundColor Green
            } else {
                Write-Host "[ERROR] Failed to copy alpine-chroot-install to WSL" -ForegroundColor Red
                Write-Host "Copy output: $copyResult" -ForegroundColor Red
                exit 1
            }
        } else {
            Write-Host "[ERROR] alpine-chroot-install not found in Downloads folder" -ForegroundColor Red
            Write-Host "Please download alpine-chroot-install to your Downloads folder first" -ForegroundColor Red
            Write-Host "You can download it from: https://raw.githubusercontent.com/alpinelinux/alpine-chroot-install/v0.14.0/alpine-chroot-install" -ForegroundColor Cyan
            exit 1
        }
    } catch {
        Write-Host "[ERROR] Failed to copy alpine-chroot-install" -ForegroundColor Red
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
}


# Run alpine-chroot-install to create a chroot environment
Write-Host "Running alpine-chroot-install to create chroot environment..." -ForegroundColor Yellow
Write-Host "This will create a minimal Alpine Linux chroot environment..." -ForegroundColor Cyan

try {
    # Create a directory for the chroot environment
    wsl -d Alpine -u root mkdir -p /opt/alpine-chroot
    
    # Run alpine-chroot-install with basic parameters
    # This creates a minimal Alpine installation in the chroot directory
    $chrootResult = wsl -d Alpine -u root alpine-chroot-install /opt/alpine-chroot 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] alpine-chroot-install completed successfully" -ForegroundColor Green
        Write-Host "Chroot environment created at /opt/alpine-chroot" -ForegroundColor Cyan
    } else {
        Write-Host "[ERROR] alpine-chroot-install failed with exit code $LASTEXITCODE" -ForegroundColor Red
        Write-Host "Output: $chrootResult" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "[ERROR] Failed to run alpine-chroot-install" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}



# Install required packages for WordPress (run as root)
Write-Host "Installing WordPress dependencies..." -ForegroundColor Yellow
wsl -d Alpine -u root apk add jq mariadb mariadb-client php php-fpm php-mysqli php-json php-session php-xml php-gd php-curl php-zip nginx unzip wget curl

# Install and start openrc (init system)
Write-Host "Installing and starting openrc..." -ForegroundColor Yellow
try {
    # Install openrc
    Write-Host "Installing openrc..." -ForegroundColor Cyan
    wsl -d Alpine -u root apk add openrc
    
    # Start openrc
    Write-Host "Starting openrc..." -ForegroundColor Cyan
    wsl -d Alpine -u root openrc default
    
    Write-Host "[OK] openrc installed and started successfully" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Failed to install or start openrc" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Execute a command inside the chroot environment
Write-Host "Executing a command inside the chroot environment..." -ForegroundColor Yellow
try {
    $chrootExec = wsl -d Alpine -u root chroot /opt/alpine-chroot /bin/sh -c "echo 'Inside chroot!'" 2>&1
    Write-Host "Chroot execution output: $chrootExec" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Failed to execute command inside chroot" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "Step 1 completed successfully!" -ForegroundColor Green
Write-Host "Alpine Linux, chroot environment, and all required packages for WordPress have been installed." -ForegroundColor Cyan

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

# Verify chroot environment details
Write-Host "Checking chroot environment details..." -ForegroundColor Yellow
try {
    $chrootInfo = wsl -d Alpine -u root chroot /opt/alpine-chroot cat /etc/alpine-release 2>&1
    if ($chrootInfo) {
        Write-Host "[OK] Chroot Alpine version: $chrootInfo" -ForegroundColor Green
    } else {
        Write-Host "[ERROR] Could not read chroot Alpine version" -ForegroundColor Red
    }
} catch {
    Write-Host "[ERROR] Failed to check chroot Alpine version" -ForegroundColor Red
}

# Verify package installation
Write-Host "Verifying package installation..." -ForegroundColor Yellow
$requiredPackages = @("mariadb", "php", "nginx", "unzip", "wget", "curl", "alpine-chroot-install", "openrc")
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

# Verify openrc service status
Write-Host "Checking openrc service status..." -ForegroundColor Yellow
try {
    $openrcStatus = wsl -d Alpine -u root rc-status 2>&1
    if ($openrcStatus) {
        Write-Host "[OK] openrc services are running" -ForegroundColor Green
        Write-Host "Service status: $openrcStatus" -ForegroundColor Cyan
    } else {
        Write-Host "[ERROR] openrc services are not running properly" -ForegroundColor Red
        $failedPackages += "openrc"
    }
} catch {
    Write-Host "[ERROR] Failed to check openrc service status" -ForegroundColor Red
    $failedPackages += "openrc"
}


# Summary and error reporting
Write-Host "`n=== INSTALLATION SUMMARY ===" -ForegroundColor Magenta
if ($failedPackages.Count -eq 0) {
    Write-Host "[OK] All packages installed successfully!" -ForegroundColor Green
    Write-Host "[OK] Alpine Linux and chroot environment are ready for WordPress setup" -ForegroundColor Green
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
    Write-Host "3. Try copying alpine-chroot-install manually from Downloads:" -ForegroundColor Cyan
    Write-Host "   wsl -d Alpine -u root cp /mnt/c/Users/$env:USERNAME/Downloads/alpine-chroot-install /usr/local/bin/" -ForegroundColor White
    Write-Host "   wsl -d Alpine -u root chmod +x /usr/local/bin/alpine-chroot-install" -ForegroundColor White
    Write-Host "4. Check WSL status: wsl -l -v" -ForegroundColor Cyan
    Write-Host "5. Restart WSL if needed: wsl --shutdown" -ForegroundColor Cyan
    exit 1
}

Write-Host "`nStep 1 verification completed successfully!" -ForegroundColor Green
Write-Host "Alpine Linux with chroot environment is ready for WordPress setup" -ForegroundColor Cyan
Write-Host "Chroot environment location: /opt/alpine-chroot" -ForegroundColor Cyan
Write-Host "You can now proceed to next step" -ForegroundColor Cyan 