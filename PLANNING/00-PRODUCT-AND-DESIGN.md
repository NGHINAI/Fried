# Fried — Product & Design Spec

> One-line: **A playful "Brain Rot Vibe Check" that scores how fried your attention is, roasts you, and dares you to share it.**
> Status: locked 2026-06-15. Source research: `../PLANNING/` siblings + 4 deep-research passes.

---

## 1. What it is (and what it must NOT claim)

**Fried** gives the user a **"Fried Score" (0–100)** from a fast, fun mix of:
- a 6-question scroll-habits quiz (self-reported, subjective), and
- a 30–45s live **reaction / attention mini-game** (earned in-app, zero permissions).

It then shows a **tier** ("Lightly Toasted" → "Extra Crispy"), a **self-roast**, and a **share card**.

### The framing rule (this is the whole App Store survival strategy)
The score is an **honestly subjective vibe check**, branded as entertainment — **never a measurement of cognition, attention span, IQ, or health.**

- ✅ Allowed words: *Fried Score, Brain Rot Vibe Check, scroll personality, toasted, crispy, de-fry, focus streak.*
- ❌ Forbidden words anywhere in UI/metadata: *attention span, cognitive, ADHD, dopamine, neurological, clinical, diagnose, measure, accurate, brain age, IQ.*
- ❌ Never score/roast another person or an uploaded photo of someone. Self-directed only.
- ✅ Disclaimer (result screen + App Store description, not buried):
  > "Fried is for entertainment only. Your Fried Score is a playful, made-up vibe check — not a medical, psychological, or scientific assessment of your attention, intelligence, or health. If you're worried about your focus or mental health, talk to a qualified professional."

Why: App Review **1.1.6** (a faked score presented as real device data is rejected, and "it's for entertainment" does NOT save you), **1.4.1** (health-measurement claims trigger validation you can't meet), **1.1.1** (mean-spirited roast), **4.2** (thin novelty). The fix for all four is *framing + a real recurring loop*, not cutting features.

---

## 2. The 90-second wow (the entire reason this works)

The user must hit a **"holy crap, I need this"** moment by ~second 60. Flow (Cal AI playbook, adapted):

| # | Screen | ~time | Purpose |
|---|--------|-------|---------|
| 1 | **Hook splash** — "How fried is your brain? Let's find out." + 3s ambient animation | 0–4s | Tone, playful dread |
| 2–7 | **6 tappy quiz cards** — "Hours of shorts/day?", "Can you watch a movie without your phone?", "Tabs open right now?", "First thing you touch awake?", "Pick your poison: TikTok/Reels/Shorts", "Finish what you start?" | 4–30s | Foot-in-the-door commitment + zero-party data to personalize |
| 8 | **The Reaction Gauntlet** — tap-on-green reaction + a go/no-go round; measures mean RT + lapse variance | 30–55s | The *earned, live* data. Zero permissions. Most demoable & shareable. |
| 9 | **"Frying your brain…"** dramatic calc beat ("measuring your dopamine debt…") | 55–58s | Makes the reveal feel earned/personalized |
| 10 | **THE REVEAL** — big animated score dial ("Your Fried Score: 87 — Extra Crispy 💀"), tier, **roast**, share card | 58–70s | The value moment + the viral artifact (free, shareable) |
| 11 | **Paywall** — at peak emotion | 70–80s | Gate the *depth* (below) |
| 12 | **(optional) notif permission, then home** | 80–90s | Daily ritual hook |

**Free (the viral top-of-funnel):** the score reveal + the shareable card. Never hide these — they are the distribution engine.
**Paid (the payoff):** full breakdown, extra roast packs, **daily score + de-fry streak + weekly trend**, the "de-fry plan," and the **screen-time screenshot deep analysis**.

---

## 3. Retention — why they keep it & happily paid $5 (also satisfies Apple 4.2)

A one-shot number is a thin novelty (rejected) and churns. Fried is a **daily ritual**:
- **Daily Fried Score** + a **de-fry streak** (loss-averse: don't break the streak).
- **A fresh roast every day** + unlockable roast packs.
- **Weekly trend** ("you got 12% less fried this week") via the reaction mini-game played daily.
- **Share cards** as the recurring flex/shame artifact.
- **"De-fry" challenge** = generic focus-habit nudges ("one phone-free meal"), never clinical.

---

## 4. Monetization (locked)

- **$4.99 one-time "Lifetime Unlock"** — non-consumable. Labeled **"one time, no subscription."** (Sub-fatigue is itself a 2026 conversion lever; a one-shot reveal has no honest recurring value, so a sub invites 1★ "scam" reviews.)
- **Why $4.99 not $1.99:** the buy trigger is a 5-second peak-emotion impulse ("I got an 87, I NEED the breakdown + to roast my friends"). Elasticity $1.99↔$4.99 is tiny at that arousal; $4.99 ≈ 2.5× revenue/buyer and still "impulse/cheap." $1.99 signals junk.
- **Teaser paywall:** free dramatic score + share card → gate breakdown/roast packs/tracking/de-fry/OCR.
- **Apple Small Business Program** → 15% cut from day one (net ≈ $4.24/sale).
- **Tech:** raw **StoreKit 2**, single non-consumable (no RevenueCat dependency for v1 → keeps our run-cost truly $0; revisit RevenueCat only to A/B price later).
- Cost to us: **~$0 forever** (on-device score + on-device AI + on-device OCR; no servers, no API bills). Only cost = Apple's 15% + the $99/yr developer account.

---

## 5. Design system (decided — dark premium "Liquid Glass")

Chosen over cartoon and flat-B&W because the viral genre (Umax/Cal AI/Cluely) wins on **dark premium glass**, it's native to iOS 26 (Liquid Glass), and "fried/overcooked" maps perfectly onto a **heat gradient**.

**Aesthetic:** near-black canvas, frosted-glass cards, oversized rounded numerals, spring physics, rich haptics. Premium, a little ominous, very screenshotable.

**Palette (`Theme.swift` is source of truth):**
- `canvas` `#0A0A0B` (near-black), `canvasElevated` `#141417`
- Glass: white at 6–10% opacity + `.ultraThinMaterial`
- **Heat accent (the brand):** gradient `#FFB020` (amber) → `#FF6A2C` → `#FF3B2E` (hot). Used for the score dial, "fried" states, the brand mark.
- **Cool counter-accent:** `#39E5C8` (mint) for "focused / good / improving."
- Text: `#F5F5F7` primary, `#9A9AA2` secondary.
- Tiers map to heat: 0–24 Crisp Mind (mint) · 25–49 Lightly Toasted · 50–74 Well Done · 75–89 Extra Crispy · 90–100 Deep Fried 💀 (max heat).

**Type:** SF Pro Rounded. Score numerals at ~96pt heavy; headlines 28–34 bold; body 16.
**Motion:** spring (response 0.45, damping 0.8). Score dial counts up with a haptic ramp. Reveal = scale+blur-in. Every tap = `.sensoryFeedback`.
**Components:** `GlassCard`, `ScoreDial` (animated ring + counting numeral), `PrimaryButton` (heat-gradient, haptic), `QuizCard`, `ShareCard` (1080×1920 export), `Paywall`.

**Accessibility:** Dynamic Type, VoiceOver labels, reduce-motion fallback (cross-fade instead of dial spin), color-independent tier labels.

---

## 6. Out of scope for v1 (YAGNI)
Family Controls / live Screen Time monitoring (entitlement gate, can't read numbers), accounts/login, server/backend, Android, social graph, RevenueCat/Superwall. All deferrable; none block launch.
