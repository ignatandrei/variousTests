# Step 41: Setup WordPress Database
# This script creates the WordPress database and user in MariaDB

Write-Host "Step 41: Setting up WordPress Database..." -ForegroundColor Green

# Database configuration
$dbName = "wordpress"
$dbUser = "wordpress_user"
$dbPassword = "wordpress_password"
$dbHost = "localhost"

Write-Host "Database Configuration:" -ForegroundColor Cyan
Write-Host "  Database Name: $dbName" -ForegroundColor White
Write-Host "  Username: $dbUser" -ForegroundColor White
Write-Host "  Password: $dbPassword" -ForegroundColor White
Write-Host "  Host: $dbHost" -ForegroundColor White

# Check if MariaDB is running
Write-Host "`nChecking MariaDB status..." -ForegroundColor Yellow
$mariadbRunning = wsl -d Alpine -u root pgrep mariadb
if (-not $mariadbRunning) {
    Write-Host "[ERROR] MariaDB is not running. Please run Step 20 first." -ForegroundColor Red
    exit 1
}
Write-Host "[OK] MariaDB is running" -ForegroundColor Green

# Test MariaDB connection
Write-Host "Testing MariaDB connection..." -ForegroundColor Yellow
$connectionTest = wsl -d Alpine -u root mysql -u root --socket=/tmp/mysql.sock -e "SELECT 1;" 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] MariaDB connection successful" -ForegroundColor Green
} else {
    Write-Host "[ERROR] Cannot connect to MariaDB" -ForegroundColor Red
    Write-Host "Error: $connectionTest" -ForegroundColor Red
    exit 1
}

# Check if database already exists
Write-Host "Checking if WordPress database exists..." -ForegroundColor Yellow
$dbExists = wsl -d Alpine -u root mysql -u root --socket=/tmp/mysql.sock -e "SHOW DATABASES LIKE '$dbName';" 2>&1
if ($dbExists -like "*$dbName*") {
    Write-Host "[INFO] WordPress database already exists" -ForegroundColor Cyan
} else {
    # Create WordPress database
    Write-Host "Creating WordPress database..." -ForegroundColor Yellow
    $createDbResult = wsl -d Alpine -u root mysql -u root --socket=/tmp/mysql.sock -e "CREATE DATABASE IF NOT EXISTS $dbName CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] WordPress database created successfully" -ForegroundColor Green
    } else {
        Write-Host "[ERROR] Failed to create WordPress database" -ForegroundColor Red
        Write-Host "Error: $createDbResult" -ForegroundColor Red
        exit 1
    }
}

# Check if user already exists
Write-Host "Checking if WordPress user exists..." -ForegroundColor Yellow
$userExists = wsl -d Alpine -u root mysql -u root --socket=/tmp/mysql.sock -e "SELECT User FROM mysql.user WHERE User='$dbUser';" 2>&1
if ($userExists -like "*$dbUser*") {
    Write-Host "[INFO] WordPress user already exists" -ForegroundColor Cyan
} else {
    # Create WordPress user for both localhost and 127.0.0.1
    Write-Host "Creating WordPress user..." -ForegroundColor Yellow
    $createUserResult = wsl -d Alpine -u root mysql -u root --socket=/tmp/mysql.sock -e "CREATE USER IF NOT EXISTS '$dbUser'@'localhost' IDENTIFIED BY '$dbPassword';" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] WordPress user created for localhost" -ForegroundColor Green
    } else {
        Write-Host "[ERROR] Failed to create WordPress user for localhost" -ForegroundColor Red
        Write-Host "Error: $createUserResult" -ForegroundColor Red
        exit 1
    }
    
    $createUserResult2 = wsl -d Alpine -u root mysql -u root --socket=/tmp/mysql.sock -e "CREATE USER IF NOT EXISTS '$dbUser'@'127.0.0.1' IDENTIFIED BY '$dbPassword';" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] WordPress user created for 127.0.0.1" -ForegroundColor Green
    } else {
        Write-Host "[ERROR] Failed to create WordPress user for 127.0.0.1" -ForegroundColor Red
        Write-Host "Error: $createUserResult2" -ForegroundColor Red
        exit 1
    }
}

# Grant privileges to WordPress user for both hosts
Write-Host "Granting privileges to WordPress user..." -ForegroundColor Yellow
$grantResult = wsl -d Alpine -u root mysql -u root --socket=/tmp/mysql.sock -e "GRANT ALL PRIVILEGES ON $dbName.* TO '$dbUser'@'localhost';" 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] Privileges granted for localhost" -ForegroundColor Green
} else {
    Write-Host "[ERROR] Failed to grant privileges for localhost" -ForegroundColor Red
    Write-Host "Error: $grantResult" -ForegroundColor Red
    exit 1
}

$grantResult2 = wsl -d Alpine -u root mysql -u root --socket=/tmp/mysql.sock -e "GRANT ALL PRIVILEGES ON $dbName.* TO '$dbUser'@'127.0.0.1';" 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] Privileges granted for 127.0.0.1" -ForegroundColor Green
} else {
    Write-Host "[ERROR] Failed to grant privileges for 127.0.0.1" -ForegroundColor Red
    Write-Host "Error: $grantResult2" -ForegroundColor Red
    exit 1
}

# Flush privileges
Write-Host "Flushing privileges..." -ForegroundColor Yellow
$flushResult = wsl -d Alpine -u root mysql -u root --socket=/tmp/mysql.sock -e "FLUSH PRIVILEGES;" 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] Privileges flushed successfully" -ForegroundColor Green
} else {
    Write-Host "[ERROR] Failed to flush privileges" -ForegroundColor Red
    Write-Host "Error: $flushResult" -ForegroundColor Red
    exit 1
}

# Test WordPress user connection
Write-Host "Testing WordPress user connection..." -ForegroundColor Yellow
$mysqlConfig = "[client]`nuser=$dbUser`npassword=$dbPassword`nsocket=/tmp/mysql.sock"
$mysqlConfig | wsl -d Alpine -u root tee /tmp/mysql.cnf > /dev/null
$testConnection = wsl -d Alpine -u root mysql --defaults-file=/tmp/mysql.cnf -e "USE $dbName; SELECT 'Connection successful' as status;" 2>&1
wsl -d Alpine -u root rm -f /tmp/mysql.cnf

if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] WordPress user can connect to database" -ForegroundColor Green
} else {
    Write-Host "[ERROR] WordPress user cannot connect to database" -ForegroundColor Red
    Write-Host "Error: $testConnection" -ForegroundColor Red
    exit 1
}

# Show database information
Write-Host "`n=== DATABASE SETUP SUMMARY ===" -ForegroundColor Cyan
Write-Host "Database Name: $dbName" -ForegroundColor White
Write-Host "Username: $dbUser" -ForegroundColor White
Write-Host "Host: $dbHost" -ForegroundColor White
Write-Host "Status: Ready for WordPress installation" -ForegroundColor Green

# Show databases
Write-Host "`nAvailable databases:" -ForegroundColor Yellow
wsl -d Alpine -u root mysql -u root --socket=/tmp/mysql.sock -e "SHOW DATABASES;"

# Show users
Write-Host "`nDatabase users:" -ForegroundColor Yellow
wsl -d Alpine -u root mysql -u root --socket=/tmp/mysql.sock -e "SELECT User, Host FROM mysql.user WHERE User LIKE '%wordpress%';"

Write-Host "`nStep 41 completed successfully!" -ForegroundColor Green
Write-Host "WordPress database is ready for installation" -ForegroundColor Cyan
Write-Host "`nYou can now proceed to Step 45: Transfer and Install WordPress" -ForegroundColor Cyan 