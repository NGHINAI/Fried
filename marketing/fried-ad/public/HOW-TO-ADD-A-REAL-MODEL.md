# Swap in a real UGC model clip

The "FriedAdUGC" ad shows a selfie-cam reactor (the Yolkie egg) by default.
To use a REAL person reacting (the proper UGC ad):

1. Get a ~16s vertical (9:16) selfie clip of someone reacting — film it yourself,
   hire a UGC creator (Billo/Insense), or generate one with an AI-UGC tool
   (HeyGen / Arcads / Captions). The reactions should roughly hit:
   ~0–3s curious, ~3–7s shocked ("brain age WHAT"), ~7–11s worried ("so many issues").
2. Drop the file here as:  public/model.mp4
3. Render with the model wired in:

   npx remotion render FriedAdUGC out/fried-ugc-real.mp4 --props='{"modelSrc":"model.mp4"}'

   (or preview: npx remotion studio  → open FriedAdUGC → set the modelSrc prop)

The model plays in the top cam region; the reveal + captions + CTA stay the same.
