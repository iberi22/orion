# /kitten-bridge-setup

Purpose: Set up a local Python bridge for KittenTTS until a native mobile port exists. Use from Flutter via `KITTEN_BRIDGE_URL`.

## Status
- KittenTTS currently has Python SDK only. No official Flutter/mobile binaries yet.
- Follow the repository README for exact commands; steps below are a safe template for Windows PowerShell.

## Steps (PowerShell)
```powershell
# 1) Python 3.10+ recommended
python --version

# 2) Create a virtual environment
python -m venv .venv
. .\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip wheel

# 3) Obtain KittenTTS
# Prefer the official repo; adjust if README differs
git clone https://github.com/KittenML/KittenTTS.git
Set-Location KittenTTS

# 4) Install dependencies per README (placeholder, verify in repo)
# Examples (pick the correct one after checking README):
# pip install -r requirements.txt
# or
# pip install -e .

# 5) Start a simple FastAPI/Uvicorn bridge (example skeleton)
# Create server/main.py with an endpoint `/synthesize` that returns WAV bytes.
# NOTE: Keep this LAN-only. Do NOT expose publicly.
# Run (adjust path/module):
# uvicorn server.main:app --host 127.0.0.1 --port 8000 --workers 1

# 6) Set Flutter .env
# KITTEN_BRIDGE_URL=http://127.0.0.1:8000
```

## Flutter adapter (planned)
- Implement `kitten_bridge_adapter.dart` to POST text to `/synthesize` and stream/play audio.
- Configure via `AppConfig.ttsProvider=kitten`.

## Security
- Bind to 127.0.0.1 only.
- No logging of request text if sensitive.
