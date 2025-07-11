# Step 8: Access Your Site
# This script opens the browser to access your WordPress site

Write-Host "Step 8: Opening WordPress site in browser..." -ForegroundColor Green

# Get WSL IP address
Write-Host "Getting WSL IP address..." -ForegroundColor Yellow
$wslIP = wsl -d Alpine hostname -I | ForEach-Object { $_.Trim() }

Write-Host "WSL IP Address: $wslIP" -ForegroundColor Cyan

# Try to open the site in browser
Write-Host "Opening WordPress site..." -ForegroundColor Yellow
try {
    Start-Process "http://localhost"
    Write-Host "Opened http://localhost in your default browser." -ForegroundColor Green
} catch {
    Write-Host "Could not automatically open browser. Please manually navigate to:" -ForegroundColor Yellow
    Write-Host "http://localhost" -ForegroundColor Cyan
}

Write-Host "Step 8 completed!" -ForegroundColor Green
Write-Host "WordPress restoration is complete!" -ForegroundColor Green
Write-Host "Alternative URLs to try:" -ForegroundColor Cyan
Write-Host "  - http://localhost" -ForegroundColor White
Write-Host "  - http://$wslIP" -ForegroundColor White
Write-Host "  - http://127.0.0.1" -ForegroundColor White 