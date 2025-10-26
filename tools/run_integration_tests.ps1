param(
  [string]$DeviceId = ""
)

$ErrorActionPreference = "Stop"

Write-Host "Checking Flutter..." -ForegroundColor Cyan
flutter --version | Out-Host

Write-Host "Fetching packages..." -ForegroundColor Cyan
flutter pub get | Out-Host

Write-Host "Detecting devices..." -ForegroundColor Cyan
$devices = flutter devices --machine | ConvertFrom-Json
if (-not $devices -or $devices.Count -eq 0) {
  Write-Error "No devices found. Please start an Android emulator or connect a device."
  exit 1
}

if (-not $DeviceId -and $devices.Count -gt 0) {
  $DeviceId = $devices[0].id
}

Write-Host "Running integration tests on device: $DeviceId" -ForegroundColor Cyan
flutter test integration_test -d $DeviceId -r expanded | Tee-Object -FilePath build/integration_test/test_output.log

# Collect screenshots
$screensRoot = Join-Path (Get-Location) "build/integration_test"
$screens = Get-ChildItem -Path $screensRoot -Recurse -Include screenshots -Directory -ErrorAction SilentlyContinue

if ($screens) {
  $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
  $artifactDir = Join-Path (Get-Location) "artifacts"
  New-Item -ItemType Directory -Force -Path $artifactDir | Out-Null
  $zipPath = Join-Path $artifactDir "integration_screenshots_$timestamp.zip"

  Add-Type -AssemblyName System.IO.Compression.FileSystem
  $tempDir = Join-Path $artifactDir "screens_temp_$timestamp"
  New-Item -ItemType Directory -Force -Path $tempDir | Out-Null

  foreach ($dir in $screens) {
    Copy-Item -Recurse -Force -Path $dir.FullName -Destination (Join-Path $tempDir $dir.Name)
  }

  [System.IO.Compression.ZipFile]::CreateFromDirectory($tempDir, $zipPath)
  Remove-Item -Recurse -Force $tempDir
  Write-Host "Screenshots archived to: $zipPath" -ForegroundColor Green
} else {
  Write-Warning "No screenshots directory found under build/integration_test." 
}

Write-Host "Done." -ForegroundColor Green
