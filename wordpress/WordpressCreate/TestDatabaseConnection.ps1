# Test Database Connection Script
# This script tests the database connection by accessing mydbTest.php via curl

Write-Host "Testing Database Connection..." -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green

# Check if the web server is running
Write-Host "Checking if web server is running..." -ForegroundColor Yellow
$webServerRunning = wsl -d Alpine -u root netstat -tlnp 2>&1 | Select-String ":80"
if ($webServerRunning) {
    Write-Host "[OK] Web server is running on port 80" -ForegroundColor Green
} else {
    Write-Host "[ERROR] Web server is not running on port 80" -ForegroundColor Red
    Write-Host "Please ensure Nginx and PHP-FPM are running" -ForegroundColor Red
    exit 1
}

# Check if PHP-FPM is running
Write-Host "Checking if PHP-FPM is running..." -ForegroundColor Yellow
$phpFpmRunning = wsl -d Alpine -u root netstat -tlnp 2>&1 | Select-String ":9000"
if ($phpFpmRunning) {
    Write-Host "[OK] PHP-FPM is running on port 9000" -ForegroundColor Green
} else {
    Write-Host "[ERROR] PHP-FPM is not running on port 9000" -ForegroundColor Red
    Write-Host "Please ensure PHP-FPM is running" -ForegroundColor Red
    exit 1
}

# Check if MariaDB is running
Write-Host "Checking if MariaDB is running..." -ForegroundColor Yellow
$mariadbRunning = wsl -d Alpine -u root pgrep mariadb
if ($mariadbRunning) {
    Write-Host "[OK] MariaDB is running" -ForegroundColor Green
} else {
    Write-Host "[ERROR] MariaDB is not running" -ForegroundColor Red
    Write-Host "Please ensure MariaDB is running" -ForegroundColor Red
    exit 1
}

Write-Host "`nTesting database connection via HTTP..." -ForegroundColor Yellow
Write-Host "URL: http://localhost/mydbTest.php" -ForegroundColor Cyan

# Test the database connection using curl
try {
    $response = wsl -d Alpine -u root curl -s http://localhost/mydbTest.php
    $exitCode = $LASTEXITCODE
    
    if ($exitCode -eq 0) {
        Write-Host "[OK] HTTP request successful" -ForegroundColor Green
        
        # Check for success indicators in the response
        if ($response -match "✅ SUCCESS: Successfully connected to database") {
            Write-Host "[SUCCESS] Database connection test PASSED!" -ForegroundColor Green
            Write-Host "Database is accessible and working correctly" -ForegroundColor Green
            
            # Extract additional information
            if ($response -match "Database Version: ([^<]+)") {
                $version = $matches[1]
                Write-Host "Database Version: $version" -ForegroundColor Cyan
            }
            
            if ($response -match "Server Info: ([^<]+)") {
                $serverInfo = $matches[1]
                Write-Host "Server Info: $serverInfo" -ForegroundColor Cyan
            }
            
        } elseif ($response -match "❌ ERROR:") {
            Write-Host "[FAILURE] Database connection test FAILED!" -ForegroundColor Red
            Write-Host "Database connection error detected" -ForegroundColor Red
            
            # Extract error details
            if ($response -match "❌ ERROR: ([^<]+)") {
                $errorMsg = $matches[1]
                Write-Host "Error: $errorMsg" -ForegroundColor Red
            }
            
        } else {
            Write-Host "[WARNING] Unexpected response format" -ForegroundColor Yellow
            Write-Host "Response preview: $($response.Substring(0, [Math]::Min(200, $response.Length)))..." -ForegroundColor Yellow
        }
        
    } else {
        Write-Host "[ERROR] HTTP request failed with exit code: $exitCode" -ForegroundColor Red
    }
    
} catch {
    Write-Host "[ERROR] Exception occurred during curl request: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`nFull Response:" -ForegroundColor Yellow
Write-Host "=============" -ForegroundColor Yellow
Write-Host $response -ForegroundColor White

Write-Host "`nTest completed!" -ForegroundColor Green 