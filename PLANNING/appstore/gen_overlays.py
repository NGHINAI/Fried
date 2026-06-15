from PIL import Image, ImageDraw, ImageFont
import os
W, H = 1320, 2868
OUT = os.path.expanduser("~/Desktop/Fried/PLANNING/appstore/video/overlays")
os.makedirs(OUT, exist_ok=True)
font = ImageFont.truetype("/System/Library/Fonts/SFNSRounded.ttf", 78)

caps = {
    "splash":  "How fried is your brain?",
    "reveal":  "Your score in 60 seconds",
    "today":   "An AI read + a plan for you",
    "trends":  "Watch your focus come back",
    "paywall": "Unlock once. No subscription.",
}

for name, text in caps.items():
    img = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    tw = d.textlength(text, font=font)
    x = (W - tw) / 2
    y = 215
    tb = d.textbbox((x, y), text, font=font)
    pad = 32
    d.rounded_rectangle([tb[0] - pad, tb[1] - pad, tb[2] + pad, tb[3] + pad], 28, fill=(0, 0, 0, 140))
    d.text((x + 2, y + 2), text, font=font, fill=(0, 0, 0, 130))
    d.text((x, y), text, font=font, fill=(242, 237, 233, 255))
    img.save(f"{OUT}/{name}.png")
    print("overlay", name)
