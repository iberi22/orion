from fastapi import FastAPI, Response, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import io
import math
import os
import wave
from typing import Optional

app = FastAPI(title="KittenTTS Bridge", version="0.1.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://127.0.0.1", "http://localhost", "*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class SynthesisRequest(BaseModel):
    text: str
    sample_rate: Optional[int] = 24000
    voice: Optional[str] = "default"
    language: Optional[str] = "es-ES"
    rate: Optional[float] = 0.5
    pitch: Optional[float] = 1.0


@app.get("/health")
async def health():
    return {"status": "ok"}


def _generate_beep_wav_bytes(sample_rate: int = 24000, duration: float = 0.9, freq: float = 440.0, volume: float = 0.2) -> bytes:
    frames = int(duration * sample_rate)
    buf = io.BytesIO()
    with wave.open(buf, "wb") as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2)  # 16-bit PCM
        wf.setframerate(sample_rate)
        for n in range(frames):
            # simple fade-in/out envelope to avoid clicks
            t = n / sample_rate
            env = min(1.0, t / 0.03, (duration - t) / 0.03)
            sample = volume * env * math.sin(2 * math.pi * freq * t)
            # Convert to 16-bit PCM
            intval = max(-1.0, min(1.0, sample))
            intval = int(intval * 32767)
            wf.writeframesraw(intval.to_bytes(2, byteorder="little", signed=True))
    return buf.getvalue()


@app.post("/synthesize")
async def synthesize(req: SynthesisRequest):
    if not req.text or not req.text.strip():
        raise HTTPException(status_code=400, detail="Text is required")

    # Mock mode by default to allow immediate testing from the app
    mock_mode = os.getenv("MOCK_AUDIO", "1") == "1"
    if mock_mode:
        # length heuristic based on text length
        duration = min(2.5, 0.5 + 0.05 * len(req.text))
        wav_bytes = _generate_beep_wav_bytes(sample_rate=req.sample_rate or 24000, duration=duration)
        return Response(content=wav_bytes, media_type="audio/wav")

    # Real KittenTTS synthesis
    try:
        import numpy as np  # type: ignore
        from kittentts import KittenTTS  # type: ignore
    except ModuleNotFoundError as e:  # pragma: no cover - import check
        raise HTTPException(status_code=501, detail="KittenTTS not installed. Enable MOCK_AUDIO=1 or install KittenTTS.") from e

    try:
        # Lazily initialize the model and cache globally
        global _kitten_model
        if '_kitten_model' not in globals() or _kitten_model is None:
            model_name = os.getenv("KITTEN_MODEL", "KittenML/kitten-tts-nano-0.1")
            _kitten_model = KittenTTS(model_name)

        sr = 24000  # KittenTTS preview returns 24kHz PCM
        voice = req.voice or "expr-voice-2-f"

        # The KittenTTS public preview API documents: generate(text, voice='...')
        audio = _kitten_model.generate(req.text, voice=voice)
        # audio is a numpy array of float samples; convert to WAV
        # Normalize/clamp just in case and convert to int16
        audio = np.asarray(audio)
        audio = np.clip(audio, -1.0, 1.0)
        int16 = (audio * 32767.0).astype(np.int16).tobytes()

        # wrap into WAV container
        buf = io.BytesIO()
        with wave.open(buf, "wb") as wf:
            wf.setnchannels(1)
            wf.setsampwidth(2)
            wf.setframerate(sr)
            wf.writeframes(int16)
        return Response(content=buf.getvalue(), media_type="audio/wav")
    except Exception as e:  # pragma: no cover
        raise HTTPException(status_code=500, detail=f"KittenTTS synthesis error: {e}") from e
