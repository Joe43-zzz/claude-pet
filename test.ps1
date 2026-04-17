# Claude Pet - Smoke Test
# Usage: powershell -ExecutionPolicy Bypass -File test.ps1

$ErrorActionPreference = "Stop"
$notifyPath = Join-Path $PSScriptRoot "notify.ps1"

Write-Host ""
Write-Host "=== Claude Pet Smoke Test ===" -ForegroundColor Cyan
Write-Host ""

if (-not (Test-Path $notifyPath)) {
    Write-Host "ERROR: notify.ps1 not found. Run install.ps1 first." -ForegroundColor Red
    exit 1
}

# Clear lock file to avoid throttling between tests
$lockFile = Join-Path $env:TEMP "claude-pet.lock"

# --- Test 1: Stop notification ---
Write-Host "[1/2] Testing STOP notification ..." -ForegroundColor Yellow
if (Test-Path $lockFile) { Remove-Item $lockFile -Force }

$p1 = Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -File `"$notifyPath`" -Type stop" -WindowStyle Hidden -PassThru
$p1.WaitForExit(15000) | Out-Null

if ($p1.ExitCode -eq 0) {
    Write-Host "  -> PASS (exit code 0)" -ForegroundColor Green
} else {
    Write-Host "  -> FAIL (exit code $($p1.ExitCode))" -ForegroundColor Red
}

# --- Test 2: Notification notification ---
Write-Host "[2/2] Testing NOTIFICATION notification ..." -ForegroundColor Yellow
if (Test-Path $lockFile) { Remove-Item $lockFile -Force }

$p2 = Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -File `"$notifyPath`" -Type notification" -WindowStyle Hidden -PassThru
$p2.WaitForExit(15000) | Out-Null

if ($p2.ExitCode -eq 0) {
    Write-Host "  -> PASS (exit code 0)" -ForegroundColor Green
} else {
    Write-Host "  -> FAIL (exit code $($p2.ExitCode))" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== Smoke Test Complete ===" -ForegroundColor Cyan
Write-Host "You should have seen two popups (green + orange)." -ForegroundColor White
Write-Host ""
