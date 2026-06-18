import re, json, sys, os
import numpy as np
import soundfile as sf
from kokoro_onnx import Kokoro

# Paths resolve relative to THIS file, so it runs from any cwd.
BASE = os.path.dirname(os.path.abspath(__file__))

VOICE = "af_heart"      # warm, natural American-female Kokoro voice
SPEED = 1.13
SR = 24000
GAP = 0.16             # seconds of silence between sentences (natural pacing)
FPS = 30

# Usage:
#   python kokoro_tts.py            -> script.txt      -> public/vo.wav     + public/captions.json (the hero)
#   python kokoro_tts.py s1         -> variants/s1.txt -> public/s1.wav     + public/s1.captions.json
vid = sys.argv[1] if len(sys.argv) > 1 else None
if vid:
    src = os.path.join(BASE, f"variants/{vid}.txt")
    wav_out = os.path.join(BASE, f"public/{vid}.wav")
    cap_out = os.path.join(BASE, f"public/{vid}.captions.json")
else:
    src = os.path.join(BASE, "script.txt")
    wav_out = os.path.join(BASE, "public/vo.wav")
    cap_out = os.path.join(BASE, "public/captions.json")

script = open(src).read().strip()
# split into sentences (keep natural prosody per sentence)
sentences = [s.strip() for s in re.split(r"(?<=[.?!])\s+", script) if s.strip()]

k = Kokoro(os.path.join(BASE, "tts-models/kokoro-v1.0.onnx"), os.path.join(BASE, "tts-models/voices-v1.0.bin"))
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
sf.write(wav_out, full, SR)
json.dump(captions, open(cap_out, "w"), indent=2)
total_frames = round(len(full) / SR * FPS)
print(f"DUR {round(len(full)/SR,2)}s  frames {total_frames}  sentences {len(sentences)}  words {len(captions)}")
print("MARKERS (startFrame @30fps : word)")
for c in captions:
    print(f"  {round(c['startMs']/1000*FPS):>4}  {c['text']}")
