import subprocess, time, os, signal
MAX = "E9F23117-21D2-47D4-B36C-55E78FBCCC3B"  # iPhone 17 Pro Max
OUT = os.path.expanduser("~/Desktop/Fried/PLANNING/appstore/video/clips")
os.makedirs(OUT, exist_ok=True)

def sh(*a): subprocess.run(a, capture_output=True)

clips = [
    ("splash",  {"FRIED_PREVIEW_SCREEN": "splash"}, 4.5),
    ("reveal",  {"FRIED_PREVIEW_SCREEN": "reveal"}, 5.2),
    ("today",   {"FRIED_PREVIEW_SCREEN": "home", "FRIED_PREVIEW_UNLOCK": "1"}, 5.2),
    ("trends",  {"FRIED_PREVIEW_SCREEN": "home", "FRIED_PREVIEW_TAB": "trends", "FRIED_PREVIEW_UNLOCK": "1"}, 4.6),
    ("paywall", {"FRIED_PREVIEW_SCREEN": "paywall"}, 5.0),
]

for name, env, dur in clips:
    sh("xcrun", "simctl", "terminate", MAX, "com.nghinai.fried")
    out = f"{OUT}/{name}.mp4"
    if os.path.exists(out):
        os.remove(out)
    rec = subprocess.Popen(["xcrun", "simctl", "io", MAX, "recordVideo", "--codec", "h264", "--force", out],
                           stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    time.sleep(0.6)
    childenv = {f"SIMCTL_CHILD_{k}": v for k, v in env.items()}
    subprocess.run(["xcrun", "simctl", "launch", MAX, "com.nghinai.fried"],
                   env={**os.environ, **childenv}, capture_output=True)
    time.sleep(dur)
    rec.send_signal(signal.SIGINT)
    try: rec.wait(timeout=20)
    except Exception: rec.kill()
    print("recorded", name, os.path.exists(out))
