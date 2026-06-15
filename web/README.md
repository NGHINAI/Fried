# Fried — website (Privacy / Terms / Support)

Three static files, zero build, **free to host anywhere**. Apple only needs a public HTTPS URL — it doesn't care who hosts it. Pick one:

## Option A — GitHub Pages (easiest, you already have GitHub)
1. Create a public repo, e.g. `fried-web`.
2. Copy `index.html`, `privacy.html`, `terms.html` into it; push.
3. Repo → **Settings → Pages** → Source: `main` / root → Save.
4. Your URLs (live in ~1 min):
   - Privacy: `https://<you>.github.io/fried-web/privacy.html`
   - Support: `https://<you>.github.io/fried-web/`
   - (Add a custom domain later under Pages if you want `fried.app`.)

## Option B — Vercel (free, accepted by Apple)
1. `npm i -g vercel` (or use the Vercel dashboard → drag-and-drop this folder).
2. From this `web/` folder: `vercel --prod`.
3. URLs: `https://<project>.vercel.app/privacy.html`, etc.
4. Static sites are free on Vercel's Hobby plan. No server needed.

## Option C — Cloudflare Pages or Netlify (free)
- Drag this `web/` folder into the Netlify/Cloudflare Pages dashboard → instant HTTPS URL.

## Then in App Store Connect
- **Privacy Policy URL** → `https://<your-host>/privacy.html`
- **Support URL** → `https://<your-host>/`
- **Marketing URL** (optional) → `https://<your-host>/`

## Before you ship
- Replace `hello@fried.app` in all 3 files with a real email you can receive at.
- Update the App Store download link (`href="#"`) in `index.html` once the app is live.
- (Optional) Buy `fried.app` or similar and point any host's custom-domain setting at it.
