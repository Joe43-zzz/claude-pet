# Claude Pet - Install Script
# Usage: powershell -ExecutionPolicy Bypass -File install.ps1

$ErrorActionPreference = "Stop"
$installDir = $PSScriptRoot
$sourcePath = Join-Path $installDir "src\notify.source.ps1"
$outputPath = Join-Path $installDir "notify.ps1"
$settingsDir = Join-Path $env:USERPROFILE ".claude"
$settingsPath = Join-Path $settingsDir "settings.json"

Write-Host ""
Write-Host "=== Claude Pet Installer ===" -ForegroundColor Cyan
Write-Host ""

# --- Step 1: Generate notify.ps1 from source ---
Write-Host "[1/3] Generating notify.ps1 ..." -ForegroundColor Yellow

if (-not (Test-Path $sourcePath)) {
    Write-Host "ERROR: Source file not found: $sourcePath" -ForegroundColor Red
    Write-Host "Please make sure you are running this from the claude-pet directory." -ForegroundColor Red
    exit 1
}

# Read source (UTF-8 with BOM)
$content = Get-Content -Path $sourcePath -Encoding UTF8 -Raw

# Replace $PSScriptRoot\.. with the actual install directory
# This is needed because $PSScriptRoot in hooks context points to a temp dir
$escapedPattern = [regex]::Escape('$PSScriptRoot\..')
$content = $content -replace $escapedPattern, $installDir.Replace('\', '\\')

# Fix: we replaced with double backslash for safety, now normalize
$content = $content.Replace('\\', '\')

# Write as UTF-16 LE (PowerShell 5.1 compatible)
$utf16 = New-Object System.Text.UnicodeEncoding $false, $true
[System.IO.File]::WriteAllText($outputPath, $content, $utf16)

Write-Host "  -> Created: $outputPath" -ForegroundColor Green

# --- Step 2: Configure Claude Code hooks ---
Write-Host "[2/3] Configuring Claude Code hooks ..." -ForegroundColor Yellow

# Ensure .claude directory exists
if (-not (Test-Path $settingsDir)) {
    New-Item -ItemType Directory -Path $settingsDir -Force | Out-Null
    Write-Host "  -> Created directory: $settingsDir" -ForegroundColor Green
}

# Prepare the hook command (use forward slashes for Claude Code compatibility)
$notifyPathForward = $outputPath.Replace('\', '/')
$stopCommand = "powershell.exe -ExecutionPolicy Bypass -File $notifyPathForward -Type stop"
$notificationCommand = "powershell.exe -ExecutionPolicy Bypass -File $notifyPathForward -Type notification"

# Read or create settings.json
if (Test-Path $settingsPath) {
    $settingsText = Get-Content -Path $settingsPath -Raw -Encoding UTF8
    $settings = $settingsText | ConvertFrom-Json
} else {
    $settings = [PSCustomObject]@{}
}

# Helper: ensure a property exists on an object
function Ensure-Property {
    param($obj, $name, $default)
    if (-not ($obj.PSObject.Properties.Name -contains $name)) {
        $obj | Add-Member -NotePropertyName $name -NotePropertyValue $default
    }
}

Ensure-Property $settings "hooks" ([PSCustomObject]@{})

# Helper: clean old claude-pet hooks from a hook type array
function Remove-ClaudePetHooks {
    param($hookArray)
    $clean = @()
    foreach ($entry in $hookArray) {
        $keepHooks = @()
        foreach ($h in $entry.hooks) {
            if ($h.command -notlike "*notify.ps1*") {
                $keepHooks += $h
            }
        }
        if ($keepHooks.Count -gt 0) {
            $entry.hooks = $keepHooks
            $clean += $entry
        }
    }
    return ,$clean
}

# Helper: add a claude-pet hook to a hook type
function Add-ClaudePetHook {
    param($hookTypeName, $command)

    Ensure-Property $settings.hooks $hookTypeName @()

    # Get current array and clean old claude-pet entries
    $arr = @($settings.hooks.$hookTypeName)
    $arr = Remove-ClaudePetHooks $arr

    # Add new hook entry
    $newEntry = [PSCustomObject]@{
        matcher = ""
        hooks = @(
            [PSCustomObject]@{
                type = "command"
                command = $command
            }
        )
    }
    $arr += $newEntry

    $settings.hooks.$hookTypeName = $arr
}

Add-ClaudePetHook "Stop" $stopCommand
Add-ClaudePetHook "Notification" $notificationCommand

# Write settings back (preserve formatting)
$json = $settings | ConvertTo-Json -Depth 10
[System.IO.File]::WriteAllText($settingsPath, $json, [System.Text.UTF8Encoding]::new($false))

Write-Host "  -> Updated: $settingsPath" -ForegroundColor Green

# --- Step 3: Test notification ---
Write-Host "[3/3] Testing notification ..." -ForegroundColor Yellow
Write-Host "  -> A Claude Pet popup should appear on your screen!" -ForegroundColor Green
Write-Host ""

Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -File `"$outputPath`" -Type stop" -WindowStyle Hidden

Write-Host "=== Installation Complete! ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Claude Pet will now show notifications when Claude Code:" -ForegroundColor White
Write-Host "  - Finishes a task (Stop hook)" -ForegroundColor White
Write-Host "  - Needs your attention (Notification hook)" -ForegroundColor White
Write-Host ""
Write-Host "To uninstall: powershell -ExecutionPolicy Bypass -File uninstall.ps1" -ForegroundColor Gray
Write-Host ""
