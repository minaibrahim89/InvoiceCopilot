$PATH = Split-Path -Parent $MyInvocation.MyCommand.Path
docker run -d --rm --name invoice-copilot-structurizr -p 8080:8080 -v "${PATH}:/usr/local/structurizr" structurizr/lite

$maxRetries = 30
$retryCount = 0
while ($retryCount -lt $maxRetries) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8080" -TimeoutSec 2 -ErrorAction Stop
        if ($response.StatusCode -eq 200) {
            Write-Host "Port 8080 is ready!"
            break
        }
    } catch {
        $retryCount++
        if ($retryCount -lt $maxRetries) {
            Write-Host "Waiting for port 8080... ($retryCount/$maxRetries)"
            Start-Sleep -Seconds 1
        }
    }
}

Start-Process "http://localhost:8080"
