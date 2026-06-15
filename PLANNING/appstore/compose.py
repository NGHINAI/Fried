from PIL import Image, ImageDraw, ImageFont, ImageFilter
import os

BASE = os.path.dirname(os.path.abspath(__file__))
RAW = os.path.join(BASE, "raw")
OUT = os.path.join(BASE, "screenshots")
os.makedirs(OUT, exist_ok=True)
W, H = 1320, 2868

def font(size):
    for p in ["/System/Library/Fonts/SFNSRounded.ttf", "/System/Library/Fonts/SFNS.ttf",
              "/System/Library/Fonts/Helvetica.ttc"]:
        try: return ImageFont.truetype(p, size)
        except Exception: continue
    return ImageFont.load_default()

CAP = font(116)

def background():
    img = Image.new("RGB", (W, H), (16, 11, 9))
    glow = Image.new("RGB", (W, H), (16, 11, 9))
    gd = ImageDraw.Draw(glow)
    gd.ellipse([W * 0.08, -H * 0.06, W * 0.92, H * 0.34], fill=(255, 150, 56))
    glow = glow.filter(ImageFilter.GaussianBlur(170))
    return Image.blend(img, glow, 0.5).convert("RGBA")

def rounded(im, rad):
    mask = Image.new("L", im.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, im.size[0], im.size[1]], rad, fill=255)
    out = im.copy()
    out.putalpha(mask)
    return out

SHOTS = [
    ("s1_splash",  ["How fried is", "your brain?"]),
    ("s2_reveal",  ["Your score in", "60 seconds"]),
    ("s3_today",   ["An AI read +", "a plan for you"]),
    ("s4_trends",  ["Watch your", "focus come back"]),
    ("s5_paywall", ["Unlock once.", "No subscription."]),
]

for name, lines in SHOTS:
    canvas = background()
    draw = ImageDraw.Draw(canvas)
    y = 210
    for line in lines:
        w = draw.textlength(line, font=CAP)
        # subtle shadow then text
        draw.text(((W - w) / 2 + 3, y + 3), line, font=CAP, fill=(0, 0, 0, 120))
        draw.text(((W - w) / 2, y), line, font=CAP, fill=(245, 237, 233))
        y += 138

    shot = Image.open(os.path.join(RAW, f"{name}.png")).convert("RGBA")
    sw = 1015
    sh = int(shot.size[1] * sw / shot.size[0])
    shot = rounded(shot.resize((sw, sh), Image.LANCZOS), 60)
    sx, sy = (W - sw) // 2, 580

    shadow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    ImageDraw.Draw(shadow).rounded_rectangle([sx, sy + 14, sx + sw, sy + sh + 14], 60, fill=(0, 0, 0, 150))
    shadow = shadow.filter(ImageFilter.GaussianBlur(45))
    canvas = Image.alpha_composite(canvas, shadow)
    canvas.alpha_composite(shot, (sx, sy))
    canvas.convert("RGB").save(os.path.join(OUT, f"{name}.png"), "PNG")
    print("wrote", name, canvas.size)
