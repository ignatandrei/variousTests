# Step 2: Set Up MariaDB and Create Database/User
# This script initializes MariaDB and creates the WordPress database and user

Write-Host "Step 2: Setting up MariaDB and creating database..." -ForegroundColor Green

# Initialize MariaDB (only if not already initialized)
Write-Host "Initializing MariaDB..." -ForegroundColor Yellow
wsl -d Alpine -u root mysql_install_db --user=mysql --datadir=/var/lib/mysql

# Start MariaDB service with custom socket (run in background)
Write-Host "Starting MariaDB service..." -ForegroundColor Yellow
Start-Process wsl -ArgumentList '-d','Alpine','-u','root','mariadbd','--user=mysql','--datadir=/var/lib/mysql','--socket=/tmp/mysql.sock'

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

# Create database and user using a here-string piped into mysql with correct socket
Write-Host "Creating WordPress database and user..." -ForegroundColor Yellow
$sql = @"
CREATE DATABASE IF NOT EXISTS wordpress;
CREATE USER IF NOT EXISTS 'wpuser'@'localhost' IDENTIFIED BY 'yourpassword';
GRANT ALL PRIVILEGES ON wordpress.* TO 'wpuser'@'localhost';
FLUSH PRIVILEGES;
"@

$tempSql = Join-Path $env:TEMP 'wp_create.sql'

try {
    $sql | Out-File -FilePath $tempSql -Encoding UTF8
    $winUser = $env:USERNAME
    $wslCmd = 'cat /mnt/c/Users/' + $winUser + '/AppData/Local/Temp/wp_create.sql | mysql -u root -S /tmp/mysql.sock'
    wsl -d Alpine -u root sh -c $wslCmd
    Remove-Item $tempSql -ErrorAction SilentlyContinue
    Write-Host "[OK] Database and user created successfully!" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Failed to create database and user." -ForegroundColor Red
    Write-Host "MariaDB might not be running properly." -ForegroundColor Red
    exit 1
}

# Verify database creation
$dbs = wsl -d Alpine -u root sh -c "mysql -u root -S /tmp/mysql.sock -e 'SHOW DATABASES;'"
if ($dbs -match "wordpress") {
    Write-Host "[OK] wordpress database exists." -ForegroundColor Green
} else {
    Write-Host "[ERROR] wordpress database was not created." -ForegroundColor Red
    exit 1
}

# Verify user creation
$userSql = 'SELECT User,Host FROM mysql.user;'
$userSqlFile = Join-Path $env:TEMP 'wp_check_user.sql'
$userSql | Out-File -FilePath $userSqlFile -Encoding UTF8
$winUser = $env:USERNAME
$userCheckCmd = 'cat /mnt/c/Users/' + $winUser + '/AppData/Local/Temp/wp_check_user.sql | mysql -u root -S /tmp/mysql.sock'
$users = wsl -d Alpine -u root sh -c $userCheckCmd
Remove-Item $userSqlFile -ErrorAction SilentlyContinue
Write-Host "User query output:" -ForegroundColor Yellow
Write-Host $users
if ($users -match "wpuser") {
    Write-Host "[OK] wpuser exists." -ForegroundColor Green
} else {
    Write-Host "[ERROR] wpuser was not created." -ForegroundColor Red
    exit 1
}

Write-Host "Step 2 completed successfully!" -ForegroundColor Green
Write-Host "MariaDB is running and WordPress database/user have been created." -ForegroundColor Cyan
Write-Host "IMPORTANT: Remember to change 'yourpassword' to a secure password!" -ForegroundColor Red 