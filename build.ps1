Write-Host "Building IPLive project..." -ForegroundColor Green
mvn clean install
Write-Host "Build complete!" -ForegroundColor Green
Read-Host "Press Enter to exit"