# /kitten-bridge-run

Run the local FastAPI Kitten bridge with mock audio for end-to-end testing.

## Steps (Windows PowerShell)

```powershell
# From project root
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r tools\kitten_bridge\requirements.txt

$env:MOCK_AUDIO = '1'
python -m uvicorn tools.kitten_bridge.server:app --host 127.0.0.1 --port 8000 --reload
```

## Configuration
- .env: set `TTS_PROVIDER=kitten` and `KITTEN_BRIDGE_URL=http://127.0.0.1:8000`.
- Android emulator testing may require `KITTEN_BRIDGE_URL=http://10.0.2.2:8000` or LAN IP.

## Security
- Do not expose this server outside localhost.
- No sensitive content is logged.
