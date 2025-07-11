# Step 20: Setup MariaDB
# This script sets up MariaDB in Alpine

Write-Host "Step 20: Setting up MariaDB..." -ForegroundColor Green

# Create required directories
Write-Host "Creating MariaDB directories..." -ForegroundColor Yellow
wsl -d Alpine -u root mkdir -p /run/mysqld
wsl -d Alpine -u root chown mysql:mysql /run/mysqld

# Initialize MariaDB only if not already initialized
Write-Host "Checking if MariaDB is already initialized..." -ForegroundColor Yellow
$dbExists = wsl -d Alpine -u root test -d /var/lib/mysql/mysql; if ($LASTEXITCODE -ne 0) {
    Write-Host "Initializing MariaDB..." -ForegroundColor Yellow
    wsl -d Alpine -u root mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
} else {
    Write-Host "MariaDB already initialized, skipping mysql_install_db." -ForegroundColor Cyan
}

# Start-Process wsl -ArgumentList '-d','Alpine','-u','root','mariadbd','--user=mysql','--datadir=/var/lib/mysql','--socket=/tmp/mysql.sock','--port=3306','--bind-address=127.0.0.1'
Start-Process wsl -ArgumentList '-d','Alpine','-u','root','rc-service','mariadb','start'
# Wait a moment for MariaDB to fully start
Write-Host "Waiting for MariaDB to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 8

# Check if MariaDB is running
Write-Host "Checking MariaDB status..." -ForegroundColor Yellow
$mariadbRunning = wsl -d Alpine -u root pgrep mariadb
if ($mariadbRunning) {
    Write-Host "[OK] MariaDB is running!" -ForegroundColor Green
} else {
    Write-Host "ERROR: MariaDB is not running." -ForegroundColor Red
    exit 1
}

# Check if MariaDB is listening on port 3306
Write-Host "Checking if MariaDB is listening on port 3306..." -ForegroundColor Yellow
Start-Sleep -Seconds 2
$portCheck = wsl -d Alpine -u root netstat -tlnp | wsl -d Alpine -u root grep 3306
if ($portCheck) {
    Write-Host "[OK] MariaDB is listening on port 3306!" -ForegroundColor Green
} else {
    Write-Host "[WARNING] MariaDB is not listening on port 3306 (socket connection only)" -ForegroundColor Yellow
}

Write-Host "`nStep 20 completed!" -ForegroundColor Green 