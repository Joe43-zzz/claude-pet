# Claude Pet - Uninstall Script
# Usage: powershell -ExecutionPolicy Bypass -File uninstall.ps1

$ErrorActionPreference = "Stop"
$installDir = $PSScriptRoot
$outputPath = Join-Path $installDir "notify.ps1"
$settingsDir = Join-Path $env:USERPROFILE ".claude"
$settingsPath = Join-Path $settingsDir "settings.json"

Write-Host ""
Write-Host "=== Claude Pet Uninstaller ===" -ForegroundColor Cyan
Write-Host ""

# --- Step 1: Remove hooks from settings.json ---
Write-Host "[1/2] Removing Claude Code hooks ..." -ForegroundColor Yellow

if (Test-Path $settingsPath) {
    $settingsText = Get-Content -Path $settingsPath -Raw -Encoding UTF8
    $settings = $settingsText | ConvertFrom-Json

    if ($settings.PSObject.Properties.Name -contains "hooks") {
        $hookTypes = @($settings.hooks.PSObject.Properties.Name)

        foreach ($hookType in $hookTypes) {
            $arr = @($settings.hooks.$hookType)
            $clean = @()

            foreach ($entry in $arr) {
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

            if ($clean.Count -eq 0) {
                $settings.hooks.PSObject.Properties.Remove($hookType)
            } else {
                $settings.hooks.$hookType = $clean
            }
        }

        # If hooks object is now empty, remove it
        if (@($settings.hooks.PSObject.Properties).Count -eq 0) {
            $settings.PSObject.Properties.Remove("hooks")
        }

        $json = $settings | ConvertTo-Json -Depth 10
        [System.IO.File]::WriteAllText($settingsPath, $json, [System.Text.UTF8Encoding]::new($false))
        Write-Host "  -> Cleaned: $settingsPath" -ForegroundColor Green
    } else {
        Write-Host "  -> No hooks found in settings.json" -ForegroundColor Gray
    }
} else {
    Write-Host "  -> Settings file not found, nothing to clean" -ForegroundColor Gray
}

# --- Step 2: Remove generated notify.ps1 ---
Write-Host "[2/2] Removing generated files ..." -ForegroundColor Yellow

if (Test-Path $outputPath) {
    Remove-Item $outputPath -Force
    Write-Host "  -> Deleted: $outputPath" -ForegroundColor Green
} else {
    Write-Host "  -> notify.ps1 not found, nothing to delete" -ForegroundColor Gray
}

Write-Host ""
Write-Host "=== Uninstall Complete! ===" -ForegroundColor Cyan
Write-Host "Claude Pet has been removed. Your other Claude Code settings are preserved." -ForegroundColor White
Write-Host ""
