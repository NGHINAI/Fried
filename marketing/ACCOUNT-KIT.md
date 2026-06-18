# Fried — Account Kit (stand up the portfolio)

Everything needed to launch the TikTok account portfolio. Config: faceless · pre-launch · $0 · lean-in-hard. Pairs with `PLANNING/GROWTH-OS.md`.

> **Handles below are the proposed canonical set — check availability and grab them today.** If a name is taken, use the alternates. Keep the brand token (`getfried`) consistent across TikTok / IG / the domain.

---

## The portfolio (4 accounts)

| Handle | Type | Vibe | Alternates if taken |
|---|---|---|---|
| **@getfried** | TikTok **Business** | The brand hub. Cleanest score-reveal POVs. Holds the bio link. | @friedapp · @friedtheapp · @getfriedapp |
| **@howfriedru** | Creator | "reveal / reaction" edits | @howfriedareu · @howfriedisyourbrain |
| **@brainrotchecks** | Creator | aura-points + listicles | @brainrotcheck · @brainrotscore |
| **@areyoucooked** | Creator | relatable POV / confession | @areyoucookedfr · @cookedcheck |

**Why a portfolio:** reach isn't gated by followers — each video is judged fresh — so 4 accounts = 4 lottery tickets per template. Post the same winner across all four with **varied first frame, sound, and caption** (never identical re-uploads — those get suppressed).

**Set @getfried to a Business account** (Settings → Account → Switch to Business). Business = a clickable bio link (personal accounts can't link the App Store and throttle bio links under 1k followers). The other three route traffic to "@getfried in bio" + the pinned comment.

---

## Bios

**@getfried** (brand, has the link)
```
🍳 how fried is your brain?
the 60-sec brain rot test · drops soon
↓ get early access
[ getfried.app ]
```

**@howfriedru**
```
🍳 your brain age is going to scare you
new score reveals daily
app → @getfried
```

**@brainrotchecks**
```
🧠🔥 adding up everyone's brain rot
aura math · screen-time damage
take the test → @getfried
```

**@areyoucooked**
```
😮‍💨 we're all so cooked
proof in the comments
the test → @getfried
```

---

## Link-in-bio (the funnel's catch point)

- **@getfried bio link → `getfried.app`** (the landing page in `docs/`, now a **waitlist**). Pre-launch it captures emails; at launch, flip the page CTA to the App Store link.
- Optional: a free **Linktree / Beacons** with two buttons — "Get early access" (→ waitlist) and "Follow the chaos" (→ the theme accounts). Use it if you want multiple destinations; otherwise link the landing page directly (fewer taps = more signups).
- **One manual step to go live:** create a free **Formspree** form and paste its ID into `docs/index.html` (`REPLACE_WITH_FORM_ID`). Until then the email box won't store anything.

---

## Profile visuals (faceless, on-brand)

- **PFP:** the 🍳 egg mark on the dark `#0A0807` background (pull a frame from the Remotion `Egg`, or the app icon). Same on all 4 for brand recall.
- **No face anywhere** — consistent with the faceless strategy.
- Palette: amber `#F5A524` → ember `#E2602A` on near-black. (Matches app + landing + ads.)

---

## Warm-up protocol (do NOT post from a cold account)

For each new handle, **24–48h before its first post:**
1. Finish the profile (pfp, bio, link) so it doesn't look like a bot.
2. Scroll the For You page 10–15 min/day; like 10–20 posts in the niche (#brainrot, #aurapoints, screen-time, study-tok).
3. Follow 15–30 accounts in the niche.
4. Leave 3–5 genuine comments on niche videos.
5. *Then* start posting (2–3/day, ramping).

This makes the account read human and seeds the algorithm with your niche before you ask it to rank you.

---

## Posting ops

- **Cadence:** 3–5 posts/account/day, spaced 2–4h, weighted to evening peak windows.
- **Export:** clean, no watermark (don't export with the TikTok/CapCut stamp — re-uploaded watermarked content is down-ranked). Upload natively per platform.
- **First 60 min:** reply to every comment, pin the funniest, bait more ("comment your guess before you take it"). Early engagement velocity is a ranking signal.
- **Caption = hook restated + 3–4 tags** (see the bank in `SCRIPTS-AND-HOOKS.md`).
- **Pinned comment, every post:** "it's not out yet — early access 👉 @getfried (link in bio)".
- **Scheduler (optional, free tier):** Metricool / Later / Post Planner can queue the rendered files across accounts so you're not posting manually 16×/day. This is the cleanest way to let me hand off a ready pack and have it auto-post.

---

## Repurpose (same files, more surfaces)

Every TikTok exports 1:1 to **Instagram Reels** and **YouTube Shorts** (9:16, no watermark). Mirror the brand account on IG (`@getfried`) and YT. Reels rewards faceless + sound-off even harder. ~2× the reach for ~0 extra production.

---

## Day-0 checklist
- [ ] Grab @getfried (+ IG, YT, `getfried.app`) and the 3 theme handles
- [ ] Switch @getfried to Business; set bio link → getfried.app
- [ ] Create Formspree form → paste ID into `docs/index.html`
- [ ] Set all 4 pfps to the egg mark + paste bios
- [ ] Start the 24–48h warm-up on all 4
- [ ] Render scripts 1–3 (`SCRIPTS-AND-HOOKS.md`) for the first posts
- [ ] (Optional) connect a scheduler for hands-off posting
