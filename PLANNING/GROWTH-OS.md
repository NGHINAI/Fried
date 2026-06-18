# Fried — Growth Operating System (the active plan)

**Owner:** running it end-to-end. **Config (locked 2026-06-17):** faceless · pre-launch ("submitting soon") · $0 organic · lean-in-hard.

This is the **active operating plan**. It draws on the research library already in this repo:
- `PLANNING/MARKETING-TIKTOK.md` — the full GTM playbook (assumes budget + live app; we adapt it here).
- `PLANNING/WINNING-AD-FORMATS.md` — the 5 view-validated formats + the rules.
- `PLANNING/CONVERSION-STRATEGY.md` — the in-app insecurity → $4.99 mechanics (already shipped).
- `marketing/SCRIPTS-AND-HOOKS.md` — the hook library + ready-to-render scripts.
- `marketing/ACCOUNT-KIT.md` — handles, bios, link-in-bio, warm-up protocol.

---

## 0. The thesis (one line)

**The product is the ad.** Fried's result screen — *brain age, 5 critical issues, "more fried than 92% of people your age"* — is a self-diagnosis insecurity engine, the exact shape TikTok rewards because it makes people turn the camera on themselves. We don't market an app; we make Fried the thing everyone reacts to with their own number.

**The loop:** Bait (a scary number in 3s) → Curiosity gap (they don't know *theirs*) → Shareable result (built to be screenshotted/duetted) → every user becomes a distributor.

---

## 1. The pre-launch objective (what "winning" means for the next ~30 days)

We are **not live**, so the goal is **NOT installs**. It is four things, in priority order:

1. **Find the winning video template *before* launch.** Pre-launch is free R&D. The day we go live, we already know which hook/format prints — and we pour gas on a *proven* creative instead of guessing. This is the single biggest advantage of marketing before launch.
2. **Bank a waitlist** (owned emails) + a **follower base** on the brand account — so launch day is a blast to a warm audience, not a cold start.
3. **Seed the culture** — get "how fried is your brain / duet your brain age" into circulation so it's a recognized format when the app drops.
4. **Stockpile content** — build a 30–50 video swipe-bank so launch week posts 5×/day without scrambling.

### The pre-launch funnel
```
TikTok video (the scary number)
   │  caption + pinned comment + bio
   ▼
"link in bio" / "comment FRIED" / "search @getfried"
   ▼
Landing page  (getfried.app / docs/index.html)
   ├─► Email waitlist  ── launch-day install blast (owned, un-throttleable)
   └─► Follow @getfried ── launch-day organic reach
```
At launch, both arms convert at once: email + "you followed us, we're live."

---

## 2. Account architecture (multiple shots at the algorithm)

Followers don't gate reach — **every video is judged fresh** — so we run a small **portfolio**, not one precious feed. Whichever account's video the algo picks is a lottery; we buy more tickets.

| Account | Type | Role | Can link? |
|---|---|---|---|
| **@getfried** | TikTok **Business** | Brand hub. Polished score-reveal POVs. The bio link → waitlist. | ✅ clickable bio link |
| **@howfriedru** | Personal/Creator | Theme acct — "reveal" + reaction edits | drive to comment/search |
| **@brainrotchecks** | Personal/Creator | Theme acct — listicle / aura-points crossover | drive to comment/search |
| **@areyoucooked** | Personal/Creator | Theme acct — relatable POV / confession | drive to comment/search |

Rules: **1 Business account holds the link** (personal accounts can't link the App Store and throttle bio links under 1k). Theme accounts route to "@getfried in bio" or the pinned comment. Post the *same winning template* across all four with varied first frames, sounds, and captions — never identical uploads. Exact handles, bios, and the warm-up protocol: `marketing/ACCOUNT-KIT.md`.

---

## 3. The content engine (how the videos get made — faceless, $0)

The 5 formats (full evidence in `WINNING-AD-FORMATS.md`), ranked for *our* config:

1. **Score Reveal — "the number is the hook"** ⭐ our bread-and-butter. The Remotion result-reveal we already render (`marketing/fried-ad/`) IS this format. Highest fit, fully faceless, infinitely variant-able.
2. **Aesthetic edit** — moody 2am-doomscroll montage on a bass-heavy sound, the Fried card drops as the punchline, app tagged not pitched. Reads as culture. Highest free ceiling.
3. **Aura-points listicle** — faceless text slideshow ("things frying your brain & the aura you lose"), running score, app = the official scorer. Hijacks an existing 26M-view trend, engineered for comment fights.
4. **POV / confession** — "POV: you check how fried your brain is and it's worse than you thought." Our v4-confession hero is this.
5. **Scan-a-stranger / street interview** — the virality spike. Needs a human → **deferred** (it's the one format that isn't pure-faceless; revisit if we add a creator).

### The production stack (all in-repo, all $0)
- **Remotion render farm** (`marketing/fried-ad/`) — programmatic result-reveal ads. Swap the hook + the result numbers → new variant. This is the unfair advantage: 5–10 videos/day at $0.
- **Kokoro `af_heart` neural VO** (`kokoro_tts.py`) — human-sounding voiceover, local, free. Per-sentence synth → captions built verbatim from the script (always correct spelling).
- **Word-by-word karaoke captions** — sound-off legibility (most of TikTok watches muted).
- **CapCut** (manual, free) — for trend-sound overlays, slideshow listicles, and quick re-cuts of the rendered clips.
- **Screen-recordings** — once the app is in TestFlight, real 90-sec test → score speed-ramps become the most native asset. Until then, the Remotion mockup *is* the screen.

### Variant doctrine
One winning **template**, run 50 ways. Vary ONLY one thing per batch (the hook line, the result number, the opening visual, the sound) so we can read *what* moved the needle. Kill in 3–5 days; scale anything alive at day 30.

---

## 4. Daily operating cadence (what I do every day)

This is a volume game disciplined by measurement. Daily loop:

- **Produce** 5–8 clips (mostly Remotion variants + 1–2 CapCut trend pieces). Each tests one lever.
- **Post** 3–5×/account/day across the portfolio, spaced 2–4h, in the evening/peak windows. Native upload, clean export (no watermark), hook in frame 1.
- **Caption** = the hook repeated + 2–3 niche tags (`#brainrot #aurapoints #screentime #fyp`) — captions are a *search* surface now.
- **Engage** the first 60 min hard (reply to every comment — comments are a ranking signal and a content well; pin the best). Bait replies: "comment your guess before you take it."
- **Log** every post in the tracker (views, completion %, rewatch %, shares, saves) — see §5.

**Warm new accounts 24–48h before posting** (scroll, like, follow the niche — look human). Don't post from a cold account.

---

## 5. Metrics & decision rules (the 2026 algorithm)

We engineer toward, and read, exactly these:

| Signal | Target | Why it matters |
|---|---|---|
| **Completion rate** | **≥ 70%** | The #1 ranking input. Drives length + loop design. |
| **Rewatch rate** | **20–30%** | Engineer a replay moment (flash the absurd number). |
| **Shares** | maximize | Shares > comments > saves > likes. Shares = the loop. |
| Follower count | ignore | Every video judged on its own. |

**Length:** **5–7s** (test→score) or **27–35s** (confession/listicle). The **20–30s middle dies** — avoid it.
**Hooks:** **declarative, not questions.** "Your brain is 47." not "How fried are you?" (question hooks had ~8% survival in the 500-creative teardown.)

**Decision rules:**
- A clip is a **winner** if completion > 55% AND (rewatch > 20% OR shares spiking) within 48h.
- **Concentrate:** once 2–3 winners surface, shift ~70% of volume onto them. Run a winner into the ground before chasing novelty.
- **Kill** anything flat after 3–5 days. No sentiment.
- **Weekly read** (every Monday): rank all posts, identify the live template(s), retire the dead, plan the next week's variants around the winner.

---

## 6. The 30-day pre-launch plan ($0)

**Pre-flight (Day 0):** secure 4 handles + warm them. Set the Formspree ID on the landing page (the one manual step that turns the funnel on). Build the swipe-bank of 30–50 viral brain-rot/aura/score-reveal references. Render the first 10 script variants (`SCRIPTS-AND-HOOKS.md`).

- **Week 1 — explore.** 2–3 posts/account/day across ALL formats × hooks (~50–70 videos). Pure exploration: we're hunting the template, not optimizing yet. Reply to everything.
- **Week 2 — read & concentrate.** Find the 3–5 clips beating the completion/rewatch/share bars. Kill the rest. Shift 70% of volume onto the winners. Start teasing "it's coming — get on the list" with the waitlist link.
- **Week 3 — build the wave.** Hammer the winning template. Launch the **#friedchallenge / "duet your brain age"** bait. Pump waitlist signups (pin "early access in bio"). Goal: a stocked content bank + a real list before we're live.
- **Week 4 — pre-launch crescendo → launch.** "Drops this week" countdown content. Coordinate the **launch wave** (§7). The moment the app is approved, flip every CTA from waitlist → App Store and blast the list.

---

## 7. The launch wave (when Fried goes live)

The day Apple approves:
1. **Flip the funnel.** Landing page CTA: waitlist → **Download on the App Store** (re-enable the real `.cta`). Update every bio link.
2. **Blast the waitlist** — email #1: "It's live. You were first. Here's your link." (Owned channel — no algorithm in the way.)
3. **Post the proven winner** simultaneously across all four accounts + the brand account's clickable link. Turn on **"comment FRIED → auto-DM the link"** (ManyChat) *before* posting.
4. **Turn on the in-app share loop** — the result card's one-tap "share my Fried Score" + "invite 3 friends → unlock." Every new user now feeds the top of funnel.
5. **ASO continuity** — first 3 App Store screenshots = the score / brain-age / archetype card (same image they saw in the video). Apple indexes screenshot caption text → seed "brain rot test, brain age, aura, fried score."
6. **Then, and only then, consider paid** — Spark-boost the single proven organic winner ($30–50/day) once we have budget. Never paid on an unproven creative.

---

## 8. Guardrails (lean-in-hard, but un-bannable)

The whole edge is being confronting without being reckless. Non-negotiable:
- **Vibe check, never a diagnosis.** Lean hard on "your brain is cooked" — but **never** claim to measure cognition, ADHD, IQ, attention span, or any medical/clinical thing. Keep the forbidden-words list (`cognitive, ADHD, IQ, dopamine, attention span, neurological, diagnose, clinical`) out of captions, VO, and on-screen text, same as the app.
- **Every number is real.** No fake scores, no fabricated percentiles, no fake countdowns. The insecurity only works because the result is genuinely computed (`CONVERSION-STRATEGY.md`).
- **Target the below-average sting (~60–85th percentile), not "bottom 5%"** — "bottom 5%" reads fake and disengages; "more fried than most people your age" stings *and* feels true.
- **Platform safety:** vary every upload (identical re-posts get suppressed), license sounds from the in-app library, don't beg for engagement in ways that trip spam filters ("comment your score" is fine; "comment or else" is not). Keep one disclaimer surface ("entertainment only").

---

## 9. Division of labor — mine vs. yours

**I run (no input needed):** all strategy, scripts, hooks, captions, hashtag sets, Remotion renders + VO, the content calendar, the metric tracker template, bios, pinned-comment copy, landing-page funnel.

**You do (one-time, only you can):**
1. **Secure the 4 handles** + the `getfried.app` domain (or your chosen brand token).
2. **Create a Formspree form** (2 min, free) and paste its ID into `docs/index.html` (replacing `REPLACE_WITH_FORM_ID`) — this turns the waitlist on.
3. **Approve the brand voice** (lean-in-hard is locked; flag if any specific clip goes too far).
4. **Post** — either hand me the account logins/scheduler access, or I hand you a daily ready-to-post pack and you tap upload. (TikTok has no public posting API for this; a human or a scheduler like Metricool/Later pushes the final files.)

That last point is the only true bottleneck: I can produce infinite content, but a person (you, or a scheduler you connect) has to press "post." Tell me which, and I'll shape the workflow around it.

---

## TL;DR — the 7 that matter
1. The **result card is the marketing.** Point everything at it.
2. **Pre-launch = free R&D** — find the winning template before we're live.
3. **Waitlist catches the curiosity** we generate (the landing-page fix).
4. **Portfolio of accounts + volume** beats one polished feed.
5. **70% completion + rewatch + shares** = the algorithm. Followers don't matter.
6. **Declarative hooks, 5–7s or 27–35s, faceless, varied.**
7. **Lean in hard, stay un-bannable** — every fear true, never a medical claim.
