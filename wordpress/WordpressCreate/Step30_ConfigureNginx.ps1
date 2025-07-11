# Step 30: Simple Nginx Configuration for Testing
# This script creates a minimal Nginx setup with a test.html file

Write-Host "Step 30: Creating Simple Nginx Configuration..." -ForegroundColor Green

# Create web directory
Write-Host "Creating web directory..." -ForegroundColor Yellow
wsl -d Alpine -u root mkdir -p /var/www/html

# Set permissions
Write-Host "Setting permissions..." -ForegroundColor Yellow
wsl -d Alpine -u root chown -R nginx:nginx /var/www/html
wsl -d Alpine -u root chmod -R 755 /var/www/html

# Create test.html file (use printf for compatibility)
Write-Host "Creating test.html file..." -ForegroundColor Yellow
wsl -d Alpine -u root sh -c 'printf "%s" "<html><body><h1>Nginx is working!</h1><p>Test page on port 80</p></body></html>" > /var/www/html/test.html'

# Create minimal nginx.conf using heredoc
Write-Host "Creating minimal nginx.conf..." -ForegroundColor Yellow
wsl -d Alpine -u root sh -c 'cat <<EOF > /etc/nginx/nginx.conf
events { worker_connections 1024; }
http { include /etc/nginx/http.d/*.conf; }
EOF'

# Create simple server config using heredoc
Write-Host "Creating server configuration..." -ForegroundColor Yellow
wsl -d Alpine -u root sh -c "cat <<EOF > /etc/nginx/nginx.conf
events { worker_connections 1024; }
http { include /etc/nginx/http.d/*.conf; }
EOF"

Write-Host "Creating httpd default.conf..." -ForegroundColor Yellow
wsl -d Alpine -u root sh -c 'echo "server {
    listen 80;
    root /var/www/html;
    
}" > /etc/nginx/http.d/default.conf'

# Create required directories
Write-Host "Creating required directories..." -ForegroundColor Yellow
wsl -d Alpine -u root mkdir -p /var/log/nginx /var/run
wsl -d Alpine -u root chown -R nginx:nginx /var/log/nginx /var/run

# Test configuration
Write-Host "Testing Nginx configuration..." -ForegroundColor Yellow
wsl -d Alpine -u root nginx -t 2>&1

# Start Nginx
Write-Host "Starting Nginx..." -ForegroundColor Yellow
wsl -d Alpine -u root nginx

# Wait a moment
Start-Sleep -Seconds 3

# Check if Nginx is listening
Write-Host "Checking if Nginx is listening on port 80..." -ForegroundColor Yellow
$listening = wsl -d Alpine -u root netstat -tlnp 2>&1 | Select-String ":80"
if ($listening) {
    Write-Host "[OK] Nginx is listening on port 80" -ForegroundColor Green
} else {
    Write-Host "[ERROR] Nginx is not listening on port 80" -ForegroundColor Red
}

# Test with curl (run inside WSL)
Write-Host "Testing with curl inside WSL..." -ForegroundColor Yellow
try {
    $response = wsl -d Alpine -u root curl http://localhost:80/test.html
    if ($response -and $response -match "Nginx is working") {
        Write-Host "[OK] Test page is accessible" -ForegroundColor Green
    } else {
        Write-Host "[ERROR] Test page is not accessible" -ForegroundColor Red
    }
} catch {
    Write-Host "[ERROR] Failed to access test page" -ForegroundColor Red
}


Write-Host "Testing with iwr outside..." -ForegroundColor Yellow
try {
    $response = iwr http://localhost:80/test.html
    if ($response -and $response -match "Nginx is working") {
        Write-Host "[OK] Test page is accessible outside" -ForegroundColor Green
    } else {
        Write-Host "[ERROR] Test page is not accessible outside" -ForegroundColor Red
    }
} catch {
    Write-Host "[ERROR] Failed to access test page" -ForegroundColor Red
}

Write-Host "`nStep 30 completed!" -ForegroundColor Green
Write-Host "Test page should be available at: http://localhost:80/test.html" -ForegroundColor Cyan 