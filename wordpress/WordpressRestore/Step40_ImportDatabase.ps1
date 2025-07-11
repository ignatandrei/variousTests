# Step 4: Import SQL to MariaDB
# This script finds the SQL file and imports it into the WordPress database

Write-Host "Step 4: Importing database from SQL file..." -ForegroundColor Green

# First, check if MariaDB is already running
Write-Host "Checking MariaDB status..." -ForegroundColor Yellow
$mariadbRunning = wsl -d Alpine -u root pgrep mariadb 2>$null
if ($mariadbRunning) {
    Write-Host "[OK] MariaDB is already running (PID: $mariadbRunning)" -ForegroundColor Green
} else {
    Write-Host "Starting MariaDB..." -ForegroundColor Yellow
    Start-Process wsl -ArgumentList '-d','Alpine','-u','root','mariadbd','--user=mysql','--datadir=/var/lib/mysql','--socket=/tmp/mysql.sock' -WindowStyle Hidden
    Start-Sleep -Seconds 8
    
    # Verify MariaDB started successfully
    $mariadbRunning = wsl -d Alpine -u root pgrep mariadb 2>$null
    if ($mariadbRunning) {
        Write-Host "[OK] MariaDB started successfully (PID: $mariadbRunning)" -ForegroundColor Green
    } else {
        Write-Host "[ERROR] Failed to start MariaDB" -ForegroundColor Red
        exit 1
    }
}

# Find the SQL file name
Write-Host "Looking for SQL files in backup directory..." -ForegroundColor Yellow
$sqlFile = wsl -d Alpine sh -c "ls ~/backup/*.sql 2>/dev/null | head -n 1"

if ($sqlFile) {
    Write-Host "Found SQL file: $sqlFile" -ForegroundColor Yellow
    
    # Create the wordpress database first
    Write-Host "Creating wordpress database..." -ForegroundColor Yellow
    wsl -d Alpine -u root sh -c "mysql -u root -S /tmp/mysql.sock -e 'CREATE DATABASE IF NOT EXISTS wordpress;'"
    
    # Import SQL file using root user with custom socket
    Write-Host "Importing database..." -ForegroundColor Yellow
    wsl -d Alpine -u root sh -c "mysql -u root -S /tmp/mysql.sock wordpress < $sqlFile"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] Database imported successfully!" -ForegroundColor Green
        
        # Verify that wp_users table exists
        Write-Host "Verifying WordPress tables..." -ForegroundColor Yellow
        $checkTableCmd = "SHOW TABLES LIKE 'wp_users';"
        $tempCheckFile = Join-Path $env:TEMP 'wp_check_table.sql'
        $checkTableCmd | Out-File -FilePath $tempCheckFile -Encoding UTF8
        $winUser = $env:USERNAME
        $wslCheckCmd = 'cat /mnt/c/Users/' + $winUser + '/AppData/Local/Temp/wp_check_table.sql | mysql -u root -S /tmp/mysql.sock wordpress'
        $tableExists = wsl -d Alpine -u root sh -c $wslCheckCmd
        Remove-Item $tempCheckFile -ErrorAction SilentlyContinue
        if ($tableExists -match 'wp_users') {
            Write-Host "[OK] wp_users table found - WordPress database is valid!" -ForegroundColor Green
            
            # Now create the wpuser if it doesn't exist
            Write-Host "Creating WordPress user..." -ForegroundColor Yellow
            $createUserCmd = @"
CREATE USER IF NOT EXISTS 'wpuser'@'localhost' IDENTIFIED BY 'yourpassword';
GRANT ALL PRIVILEGES ON wordpress.* TO 'wpuser'@'localhost';
FLUSH PRIVILEGES;
"@
            $tempUserFile = Join-Path $env:TEMP 'wp_create_user.sql'
            $createUserCmd | Out-File -FilePath $tempUserFile -Encoding UTF8
            $wslUserCmd = 'cat /mnt/c/Users/' + $winUser + '/AppData/Local/Temp/wp_create_user.sql | mysql -u root -S /tmp/mysql.sock'
            wsl -d Alpine -u root sh -c $wslUserCmd
            Remove-Item $tempUserFile -ErrorAction SilentlyContinue
            
            Write-Host "Step 4 completed successfully!" -ForegroundColor Green
            Write-Host "Database has been imported and WordPress user created." -ForegroundColor Cyan
        } else {
            Write-Host "ERROR: wp_users table not found in the database!" -ForegroundColor Red
            Write-Host "The SQL file may not contain a valid WordPress database." -ForegroundColor Red
            Write-Host "Please check your backup file and try again." -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "ERROR: Failed to import database. Please check the SQL file and MariaDB status." -ForegroundColor Red
        Write-Host "MariaDB might not be running properly." -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "ERROR: No SQL file found in backup directory." -ForegroundColor Red
    Write-Host "Please ensure the backup contains a .sql file." -ForegroundColor Red
    exit 1
}

Write-Host "IMPORTANT: Remember to change 'yourpassword' to your actual database password!" -ForegroundColor Red 