# /bootstrap

Purpose: Initialize dev environment, fetch deps, validate config.

## Steps (PowerShell)
```powershell
# Verify tooling
flutter --version
dart --version

# Install dependencies
flutter pub get

# Format (in-place) and analyze
dart format .
flutter analyze

# Prepare .env
if (Test-Path .env -PathType Leaf) {
  Write-Host ".env already exists"
} elseif (Test-Path .env.example -PathType Leaf) {
  Copy-Item .env.example .env
  Write-Host "Created .env from .env.example"
} else {
  "GEMINI_API_KEY=","OPENAI_API_KEY=","VERTEX_AI_PROJECT_ID=orion-d1229","VERTEX_AI_LOCATION=us-central1","DEBUG_MODE=true","TTS_PROVIDER=system","TTS_SAMPLE_RATE=24000","TTS_VOICE=default","KITTEN_BRIDGE_URL=http://127.0.0.1:8000" | Out-File -FilePath .env -Encoding utf8
  Write-Host "Created minimal .env"
}
```

## Notes
- Edit `.env` and set real API keys. `.env` should be gitignored.
- Run the app once to print config summary from `AppConfig.printConfigSummary()`.
