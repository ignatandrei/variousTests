# Step 3: Extract Database from ZIP
# This script copies the backup ZIP from Windows to Alpine and extracts it

Write-Host "Step 3: Extracting database from backup ZIP..." -ForegroundColor Green

# Define backup path (note the space in the filename)
$backupPath = "D:\eu\cursor\WordpressRestore\backup\wordpress_20250707_ 2200.zip"

Write-Host "=== CHECKING BACKUP FILES ===" -ForegroundColor Magenta

# Check if backup directory exists
$backupDir = "D:\eu\cursor\WordpressRestore\backup"
if (Test-Path $backupDir) {
    Write-Host "[OK] Backup directory exists: $backupDir" -ForegroundColor Green
} else {
    Write-Host "[ERROR] Backup directory not found: $backupDir" -ForegroundColor Red
    Write-Host "Please ensure the backup directory exists and contains your WordPress backup files." -ForegroundColor Red
    exit 1
}

# List all files in backup directory
Write-Host "`nFiles found in backup directory:" -ForegroundColor Yellow
Get-ChildItem $backupDir | ForEach-Object {
    Write-Host "  - $($_.Name) ($($_.Length) bytes)" -ForegroundColor Cyan
}

# Check if specific backup file exists
if (Test-Path $backupPath) {
    Write-Host "`n[OK] Backup file found at: $backupPath" -ForegroundColor Green
    $fileInfo = Get-Item $backupPath
    Write-Host "File size: $($fileInfo.Length) bytes" -ForegroundColor Cyan
    Write-Host "Last modified: $($fileInfo.LastWriteTime)" -ForegroundColor Cyan
} else {
    Write-Host "`n[ERROR] Specific backup file not found at: $backupPath" -ForegroundColor Red
    Write-Host "Available backup files:" -ForegroundColor Yellow
    Get-ChildItem $backupDir -Filter "*.zip" | ForEach-Object {
        Write-Host "  - $($_.Name)" -ForegroundColor Cyan
    }
    Write-Host "`nPlease ensure the backup file exists or update the path in this script." -ForegroundColor Red
    exit 1
}

# Verify ZIP file integrity
Write-Host "`n=== VERIFYING ZIP FILE INTEGRITY ===" -ForegroundColor Magenta
try {
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $zip = [System.IO.Compression.ZipFile]::OpenRead($backupPath)
    $entryCount = $zip.Entries.Count
    $zip.Dispose()
    Write-Host "[OK] ZIP file is valid and contains $entryCount entries" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] ZIP file appears to be corrupted or invalid" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "`n=== EXTRACTING BACKUP TO ALPINE ===" -ForegroundColor Magenta

# Check if Alpine is running
Write-Host "Checking Alpine WSL status..." -ForegroundColor Yellow
try {
    $alpineStatus = wsl -d Alpine -u root echo "Alpine is running" 2>&1
    if ($alpineStatus -eq "Alpine is running") {
        Write-Host "[OK] Alpine is running and accessible" -ForegroundColor Green
    } else {
        Write-Host "[ERROR] Alpine is not accessible" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "[ERROR] Cannot connect to Alpine WSL" -ForegroundColor Red
    Write-Host "Please ensure Alpine is running: wsl -d Alpine" -ForegroundColor Red
    exit 1
}

# Create backup directory in Alpine
Write-Host "Creating backup directory in Alpine..." -ForegroundColor Yellow
try {
    wsl -d Alpine mkdir -p ~/backup
    Write-Host "[OK] Backup directory created in Alpine" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Failed to create backup directory in Alpine" -ForegroundColor Red
    exit 1
}

# Copy backup ZIP from Windows to Alpine home
Write-Host "Copying backup ZIP to Alpine..." -ForegroundColor Yellow
try {
    Copy-Item $backupPath "\\wsl$\Alpine\home\$(wsl -d Alpine whoami)\backup\"
    Write-Host "[OK] Backup file copied to Alpine" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Failed to copy backup file to Alpine" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Verify file was copied successfully
Write-Host "Verifying file copy..." -ForegroundColor Yellow
try {
    $alpineFileCheck = wsl -d Alpine ls -la ~/backup/ 2>&1
    if ($alpineFileCheck -match "wordpress_20250707_ 2200.zip") {
        Write-Host "[OK] Backup file verified in Alpine" -ForegroundColor Green
    } else {
        Write-Host "[ERROR] Backup file not found in Alpine after copy" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "[ERROR] Failed to verify backup file in Alpine" -ForegroundColor Red
    exit 1
}

# Unzip in Alpine (use full path and escape spaces)
Write-Host "Extracting backup ZIP..." -ForegroundColor Yellow
try {
    $extractResult = wsl -d Alpine sh -c "cd ~/backup && unzip -o 'wordpress_20250707_ 2200.zip'" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] Backup extracted successfully" -ForegroundColor Green
    } else {
        Write-Host "[ERROR] Failed to extract backup" -ForegroundColor Red
        Write-Host "Extract output: $extractResult" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "[ERROR] Failed to extract backup file" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Verify extracted files
Write-Host "`n=== VERIFYING EXTRACTED FILES ===" -ForegroundColor Magenta
try {
    $extractedFiles = wsl -d Alpine ls -la ~/backup/ 2>&1
    Write-Host "Files extracted to Alpine backup directory:" -ForegroundColor Yellow
    Write-Host $extractedFiles -ForegroundColor Cyan
    
    # Check for common WordPress backup files
    $expectedFiles = @("*.sql", "*.zip", "wp-content", "wp-config.php")
    $foundFiles = @()
    
    foreach ($pattern in $expectedFiles) {
        $fileCheck = wsl -d Alpine sh -c "ls ~/backup/$pattern 2>/dev/null || echo 'NOT_FOUND'" 2>&1
        if ($fileCheck -ne "NOT_FOUND") {
            Write-Host "[OK] Found $pattern files" -ForegroundColor Green
            $foundFiles += $pattern
        } else {
            Write-Host "[WARNING] No $pattern files found" -ForegroundColor Yellow
        }
    }
    
    if ($foundFiles.Count -eq 0) {
        Write-Host "[WARNING] No expected WordPress files found in backup" -ForegroundColor Yellow
        Write-Host "This might be normal if the backup has a different structure" -ForegroundColor Cyan
    }
    
} catch {
    Write-Host "[ERROR] Failed to verify extracted files" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`nStep 3 completed successfully!" -ForegroundColor Green
Write-Host "Backup has been extracted to Alpine home directory." -ForegroundColor Cyan
Write-Host "You can now proceed to Step 4: Import Database" -ForegroundColor Cyan 