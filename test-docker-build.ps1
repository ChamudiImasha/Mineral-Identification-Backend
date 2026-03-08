# Test Docker Build Locally

Write-Host "Testing Docker build for Railway deployment..." -ForegroundColor Cyan
Write-Host ""

# Check if Docker is available
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: Docker is not installed or not in PATH" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Docker found" -ForegroundColor Green

# Check required files
$requiredFiles = @(
    "Dockerfile",
    "requirements-railway.txt",
    "backend/app/api_server.py"
)

foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "✓ Found: $file" -ForegroundColor Green
    } else {
        Write-Host "✗ Missing: $file" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "Building Docker image..." -ForegroundColor Cyan
Write-Host "This may take 3-5 minutes..." -ForegroundColor Yellow
Write-Host ""

# Build the image
docker build -t mineral-api-test .

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✓ Build successful!" -ForegroundColor Green
    Write-Host ""
    Write-Host "To test locally, run:" -ForegroundColor Cyan
    Write-Host "  docker run -p 8000:8000 -e PORT=8000 mineral-api-test" -ForegroundColor White
    Write-Host ""
    Write-Host "Then visit: http://localhost:8000/docs" -ForegroundColor Cyan
} else {
    Write-Host ""
    Write-Host "✗ Build failed!" -ForegroundColor Red
    Write-Host "Check the error messages above." -ForegroundColor Yellow
    exit 1
}
