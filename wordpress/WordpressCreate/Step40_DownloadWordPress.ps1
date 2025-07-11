# Step 40: Download WordPress Locally
# This script downloads the latest WordPress version to the local Windows system

Write-Host "Step 40: Downloading WordPress Locally..." -ForegroundColor Green

# Create downloads directory if it doesn't exist
$downloadDir = ".\downloads"
if (-not (Test-Path $downloadDir)) {
    New-Item -ItemType Directory -Path $downloadDir -Force | Out-Null
    Write-Host "Created downloads directory: $downloadDir" -ForegroundColor Cyan
}

# Get the latest WordPress version
Write-Host "Getting latest WordPress version..." -ForegroundColor Yellow
try {
    $wpApiResponse = Invoke-RestMethod -Uri "https://api.wordpress.org/core/version-check/1.7/" -Method Get
    $wpVersion = $wpApiResponse.offers[0].version
    Write-Host "Latest WordPress version: $wpVersion" -ForegroundColor Cyan
} catch {
    Write-Host "[ERROR] Failed to get WordPress version from API" -ForegroundColor Red
    Write-Host "Using fallback version: 6.8.1" -ForegroundColor Yellow
    $wpVersion = "6.8.1"
}

# Define local file path
$localFilePath = Join-Path $downloadDir "wordpress-$wpVersion.tar.gz"

# Check if file already exists
if (Test-Path $localFilePath) {
    Write-Host "WordPress $wpVersion already exists locally: $localFilePath" -ForegroundColor Green
    $fileSize = (Get-Item $localFilePath).Length
    Write-Host "File size: $([math]::Round($fileSize / 1MB, 2)) MB" -ForegroundColor Cyan
} else {
    # Download WordPress
    Write-Host "Downloading WordPress $wpVersion to local system..." -ForegroundColor Yellow
    $downloadUrl = "https://wordpress.org/wordpress-$wpVersion.tar.gz"
    
    try {
        Invoke-WebRequest -Uri $downloadUrl -OutFile $localFilePath -UseBasicParsing
        $fileSize = (Get-Item $localFilePath).Length
        Write-Host "[OK] WordPress downloaded successfully" -ForegroundColor Green
        Write-Host "File saved to: $localFilePath" -ForegroundColor Cyan
        Write-Host "File size: $([math]::Round($fileSize / 1MB, 2)) MB" -ForegroundColor Cyan
    } catch {
        Write-Host "[ERROR] Failed to download WordPress" -ForegroundColor Red
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
}

# Verify the downloaded file
Write-Host "Verifying downloaded file..." -ForegroundColor Yellow
if (Test-Path $localFilePath) {
    $fileInfo = Get-Item $localFilePath
    if ($fileInfo.Length -gt 1MB) {  # WordPress files are typically > 1MB
        Write-Host "[OK] File verification passed" -ForegroundColor Green
        Write-Host "File: $($fileInfo.Name)" -ForegroundColor Cyan
        Write-Host "Size: $([math]::Round($fileInfo.Length / 1MB, 2)) MB" -ForegroundColor Cyan
        Write-Host "Modified: $($fileInfo.LastWriteTime)" -ForegroundColor Cyan
    } else {
        Write-Host "[ERROR] Downloaded file appears to be too small" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "[ERROR] Downloaded file not found" -ForegroundColor Red
    exit 1
}

Write-Host "`nStep 40 completed successfully!" -ForegroundColor Green
Write-Host "WordPress $wpVersion is ready for transfer to Alpine Linux" -ForegroundColor Cyan
Write-Host "Local file: $localFilePath" -ForegroundColor White
Write-Host "`nYou can now proceed to Step 45: Transfer and Install WordPress" -ForegroundColor Cyan 