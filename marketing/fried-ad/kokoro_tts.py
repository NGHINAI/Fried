import re, json
import numpy as np
import soundfile as sf
from kokoro_onnx import Kokoro

VOICE = "af_heart"      # warm, natural American-female Kokoro voice
SPEED = 1.13
SR = 24000
GAP = 0.16             # seconds of silence between sentences (natural pacing)

script = open("script.txt").read().strip()
# split into sentences (keep natural prosody per sentence)
sentences = [s.strip() for s in re.split(r"(?<=[.?!])\s+", script) if s.strip()]

k = Kokoro("tts-models/kokoro-v1.0.onnx", "tts-models/voices-v1.0.bin")
gap = np.zeros(int(SR * GAP), dtype=np.float32)
audio = []
captions = []
t = 0.0  # running time in seconds

for sent in sentences:
    samples, sr = k.create(sent, voice=VOICE, speed=SPEED, lang="en-us")
    samples = samples.astype(np.float32)
    dur = len(samples) / sr
    words = sent.split()
    weights = [len(re.sub(r"[^a-z0-9]", "", w.lower())) + 1 for w in words]
    total = sum(weights)
    wt = t
    for w, wgt in zip(words, weights):
        wd = dur * wgt / total
        captions.append({
            "text": w,
            "startMs": round(wt * 1000),
            "endMs": round((wt + wd) * 1000),
            "timestampMs": round((wt + wd / 2) * 1000),
            "confidence": 1,
        })
        wt += wd
    audio.append(samples)
    audio.append(gap)
    t += dur + GAP

full = np.concatenate(audio)
sf.write("public/vo.wav", full, SR)
json.dump(captions, open("public/captions.json", "w"), indent=2)
print("DUR", round(len(full) / SR, 2), "sentences", len(sentences), "words", len(captions))
