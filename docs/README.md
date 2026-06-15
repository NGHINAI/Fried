# Fried — website (Privacy / Terms / Support)

These three files live in **`/docs`** so GitHub Pages can serve them straight from this repo (Pages publishes from repo root or `/docs` only). Links are relative, so they work under `…github.io/Fried/`.

## Host on GitHub Pages (from this repo)
1. Push this repo to GitHub (already done if you're reading this on github.com).
2. Repo → **Settings → Pages**.
3. **Source:** Deploy from a branch → Branch: **main** → Folder: **/docs** → **Save**.
4. Wait ~1 minute. Your live URLs:
   - Landing / Support: `https://nghinai.github.io/Fried/`
   - **Privacy:** `https://nghinai.github.io/Fried/privacy.html`
   - **Terms:** `https://nghinai.github.io/Fried/terms.html`

## Use those URLs in App Store Connect
- **Privacy Policy URL** → `https://nghinai.github.io/Fried/privacy.html`
- **Support URL** → `https://nghinai.github.io/Fried/`

## Alternatives (also free, also accepted by Apple)
- **Vercel:** drag this `docs/` folder into the Vercel dashboard, or `vercel --prod` from inside it.
- **Netlify / Cloudflare Pages:** drag-and-drop `docs/`.

## Before you ship
- Replace `hello@fried.app` in all 3 files with a real email you can receive at.
- Update the App Store download link (`href="#"`) in `index.html` once the app is live.
- Optional: add a custom domain (e.g. `fried.app`) under Settings → Pages.
