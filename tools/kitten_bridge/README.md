# KittenTTS Local Bridge (FastAPI)

A minimal local HTTP bridge to unblock mobile/web development while KittenTTS SDK matures. By default it returns a short beep WAV so the Flutter app can test end-to-end audio.

- Endpoint: `POST /synthesize`
- Health: `GET /health`
- Env: `MOCK_AUDIO=1` (default) to return synthetic audio.

## Quickstart (Windows PowerShell)

```powershell
# From project root
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r tools\kitten_bridge\requirements.txt

$env:MOCK_AUDIO = '1'
python -m uvicorn tools.kitten_bridge.server:app --host 127.0.0.1 --port 8000 --reload
```

## Notes
- Keep this server bound to `127.0.0.1`. Do not expose publicly.
- For Android emulator, 127.0.0.1 maps to the emulator. Use your host LAN IP or `10.0.2.2` if needed.
- Update `KITTEN_BRIDGE_URL` in `.env` to match where the server runs.

## Enable real KittenTTS synthesis

The bridge supports real synthesis via the official KittenTTS Python wheel. By default, the bridge runs in mock mode and returns a short beep for quick E2E testing.

1) Install deps (Windows PowerShell):

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r tools\kitten_bridge\requirements.txt
```

2) Disable mock mode and run the server:

```powershell
$env:MOCK_AUDIO = '0'  # real synthesis
# optional: choose a model (defaults to KittenML/kitten-tts-nano-0.1)
# $env:KITTEN_MODEL = 'KittenML/kitten-tts-nano-0.1'

python -m uvicorn tools.kitten_bridge.server:app --host 127.0.0.1 --port 8000 --reload
```

3) App configuration:

- Set `TTS_PROVIDER=kitten` in your `.env`.
- Set `KITTEN_BRIDGE_URL=http://127.0.0.1:8000` (or your LAN IP if testing on device).
- Optional: set `TTS_VOICE` to one of the published voices (e.g. `expr-voice-2-f`).

4) Endpoint contract:

- `POST /synthesize` JSON body:
  - `text` (string, required)
  - `voice` (string, optional)
  - Returns a `audio/wav` with mono 16-bit, 24kHz audio.

Troubleshooting:

- If you receive `501 KittenTTS not installed`, re-check the wheel install step in `requirements.txt`.
- Keep the server bound to `127.0.0.1` for local development and security.
