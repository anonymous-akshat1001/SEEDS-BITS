"""Optional campus-only bounded English speech worker; no transcript/audio logging."""

import asyncio
import io
import os
import secrets
from contextlib import asynccontextmanager
from pathlib import Path

from fastapi import FastAPI, Header, HTTPException, Request

_model = None
_busy = asyncio.Lock()


@asynccontextmanager
async def lifespan(app):
    global _model
    from faster_whisper import WhisperModel
    directory = os.getenv("WHISPER_MODEL_DIRECTORY", "")
    if not directory or not Path(directory).is_dir() or not os.getenv("SPEECH_WORKER_KEY"):
        raise RuntimeError("Provision a local Whisper model directory and worker key before startup")
    _model = WhisperModel(directory, device="cpu", compute_type="int8",
                          local_files_only=True, cpu_threads=2, num_workers=1)
    yield
    _model = None


app = FastAPI(lifespan=lifespan, docs_url=None, redoc_url=None)


def decode_and_transcribe(data):
    import av
    import numpy as np
    chunks = []
    length = 0
    # Stop while decoding, rather than allocating an arbitrarily long audio file first.
    with av.open(io.BytesIO(data), mode="r") as container:
        resampler = av.AudioResampler(format="s16", layout="mono", rate=16000)
        for frame in container.decode(audio=0):
            for output in resampler.resample(frame):
                length += output.samples
                if length > 60 * 16000:
                    raise HTTPException(422, "Decoded recording exceeds 60 seconds.")
                chunks.append(output.to_ndarray().reshape(-1))
        for output in resampler.resample(None):
            length += output.samples
            if length > 60 * 16000:
                raise HTTPException(422, "Decoded recording exceeds 60 seconds.")
            chunks.append(output.to_ndarray().reshape(-1))
    if not length:
        raise HTTPException(422, "Decoded recording exceeds 60 seconds or is empty.")
    samples = np.concatenate(chunks).astype(np.float32) / 32768.0
    segments, _ = _model.transcribe(samples, language="en", beam_size=1, vad_filter=True)
    text = " ".join(segment.text.strip() for segment in segments).strip()
    if not 1 <= len(text) <= 2000:
        raise HTTPException(422, "No usable bounded English transcript.")
    return {"text": text}


@app.post("/transcribe")
async def transcribe(request: Request, x_worker_key: str = Header(default="")):
    key = os.getenv("SPEECH_WORKER_KEY", "")
    if not key or not secrets.compare_digest(key, x_worker_key):
        raise HTTPException(401, "Worker authentication required.")
    if _busy.locked():
        raise HTTPException(429, "Transcription worker busy.")
    async with _busy:
        data = bytearray()
        async for part in request.stream():
            data.extend(part)
            if len(data) > 10 * 1024 * 1024:
                raise HTTPException(413, "Recording exceeds size limit.")
        try:
            return await asyncio.to_thread(decode_and_transcribe, bytes(data))
        except (ValueError, RuntimeError, EOFError):
            raise HTTPException(422, "Recording could not be decoded.") from None
        finally:
            data.clear()
