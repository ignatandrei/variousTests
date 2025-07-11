# WordPress ASPIRE Runner Script
# This script builds and runs the WordPress ASPIRE solution

Write-Host "WordPress ASPIRE Solution" -ForegroundColor Green
Write-Host "=========================" -ForegroundColor Green

# Check if .NET 8.0 is installed
Write-Host "Checking .NET 8.0 installation..." -ForegroundColor Yellow
try {
    $dotnetVersion = dotnet --version
    if ($dotnetVersion -like "8.*") {
        Write-Host "✓ .NET 8.0 found: $dotnetVersion" -ForegroundColor Green
    } else {
        Write-Host "✗ .NET 8.0 not found. Current version: $dotnetVersion" -ForegroundColor Red
        Write-Host "Please install .NET 8.0 SDK from https://dotnet.microsoft.com/download" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "✗ .NET not found. Please install .NET 8.0 SDK" -ForegroundColor Red
    exit 1
}

# Check if Docker is running
Write-Host "Checking Docker..." -ForegroundColor Yellow
try {
    docker version | Out-Null
    Write-Host "✓ Docker is running" -ForegroundColor Green
} catch {
    Write-Host "✗ Docker is not running. Please start Docker Desktop" -ForegroundColor Red
    exit 1
}

# Check if backup file exists
$backupPath = "backup\wordpress_20250707_ 2200.zip"
if (Test-Path $backupPath) {
    Write-Host "✓ Backup file found: $backupPath" -ForegroundColor Green
} else {
    Write-Host "⚠ Backup file not found: $backupPath" -ForegroundColor Yellow
    Write-Host "   The application will proceed with a fresh WordPress installation" -ForegroundColor Yellow
}

# Build the solution
Write-Host "Building solution..." -ForegroundColor Yellow
try {
    dotnet build
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Solution built successfully" -ForegroundColor Green
    } else {
        Write-Host "✗ Build failed" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "✗ Build failed with error: $_" -ForegroundColor Red
    exit 1
}

# Run the application
Write-Host "Starting WordPress ASPIRE application..." -ForegroundColor Yellow
Write-Host "This will start MariaDB and WordPress containers" -ForegroundColor Yellow
Write-Host "WordPress will be available at: http://localhost:8080" -ForegroundColor Cyan
Write-Host "Press Ctrl+C to stop the application" -ForegroundColor Yellow
Write-Host ""

try {
    Set-Location "src\WordpressAspire.AppHost"
    dotnet run
} catch {
    Write-Host "✗ Application failed to start: $_" -ForegroundColor Red
    exit 1
} finally {
    Set-Location "..\.."
} 