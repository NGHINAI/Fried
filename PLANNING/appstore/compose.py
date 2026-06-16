from PIL import Image, ImageDraw, ImageFont, ImageFilter
import os

BASE = os.path.dirname(os.path.abspath(__file__))
RAW = os.path.join(BASE, "raw")
OUT = os.path.join(BASE, "screenshots")
os.makedirs(OUT, exist_ok=True)
W, H = 1320, 2868

def font(size):
    for p in ["/System/Library/Fonts/SFNS.ttf", "/System/Library/Fonts/Helvetica.ttc"]:
        try: return ImageFont.truetype(p, size)
        except Exception: continue
    return ImageFont.load_default()

CAP = font(112)

def background():
    # neutral near-black gradient + a faint copper glow up top (Reticla-style)
    img = Image.new("RGB", (W, H), (16, 16, 18))
    top, bot = (26, 22, 24), (9, 9, 11)
    px = img.load()
    for y in range(H):
        t = y / H
        c = tuple(int(top[i] * (1 - t) + bot[i] * t) for i in range(3))
        for x in range(W): px[x, y] = c
    glow = Image.new("RGB", (W, H), (0, 0, 0))
    ImageDraw.Draw(glow).ellipse([W * 0.18, -H * 0.06, W * 0.82, H * 0.30], fill=(217, 140, 92))
    glow = glow.filter(ImageFilter.GaussianBlur(180))
    return Image.blend(img, glow, 0.22).convert("RGBA")

def rounded(im, rad):
    mask = Image.new("L", im.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, im.size[0], im.size[1]], rad, fill=255)
    out = im.copy(); out.putalpha(mask)
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
    y = 215
    for line in lines:
        w = draw.textlength(line, font=CAP)
        draw.text(((W - w) / 2, y), line, font=CAP, fill=(237, 237, 241))
        y += 132

    shot = Image.open(os.path.join(RAW, f"{name}.png")).convert("RGBA")
    sw = 1015
    sh = int(shot.size[1] * sw / shot.size[0])
    shot = rounded(shot.resize((sw, sh), Image.LANCZOS), 62)
    sx, sy = (W - sw) // 2, 600

    shadow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    ImageDraw.Draw(shadow).rounded_rectangle([sx, sy + 16, sx + sw, sy + sh + 16], 62, fill=(0, 0, 0, 140))
    shadow = shadow.filter(ImageFilter.GaussianBlur(48))
    canvas = Image.alpha_composite(canvas, shadow)
    canvas.alpha_composite(shot, (sx, sy))
    canvas.convert("RGB").save(os.path.join(OUT, f"{name}.png"), "PNG")
    print("wrote", name)
