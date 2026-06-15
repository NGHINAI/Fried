import subprocess, time, glob, os
UDID = "B919E77F-180D-4738-A314-DFE5C35171A8"  # iPhone 17 Pro

def sh(*a): return subprocess.run(a, capture_output=True, text=True)

apps = glob.glob(os.path.expanduser(
    "~/Library/Developer/Xcode/DerivedData/Fried-*/Build/Products/Debug-iphonesimulator/Fried.app"))
app = sorted(apps, key=os.path.getmtime)[-1]

sh("xcrun", "simctl", "boot", UDID)
subprocess.run(["xcrun", "simctl", "bootstatus", UDID, "-b"], capture_output=True, text=True)
sh("xcrun", "simctl", "install", UDID, app)

outdir = os.path.expanduser("~/Desktop/Fried/PLANNING/screenshots")
os.makedirs(outdir, exist_ok=True)

screens = ["splash", "onboarding", "calculating", "reveal", "reveal_low", "paywall"]
for s in screens:
    sh("xcrun", "simctl", "terminate", UDID, "com.fried.app")
    env = dict(os.environ, SIMCTL_CHILD_FRIED_PREVIEW_SCREEN=s)
    subprocess.run(["xcrun", "simctl", "launch", UDID, "com.fried.app"],
                   env=env, capture_output=True, text=True)
    time.sleep(3.4)
    sh("xcrun", "simctl", "io", UDID, "screenshot", f"{outdir}/{s}.png")

print("APP:", app)
print("SHOTS:", sorted(os.listdir(outdir)))
