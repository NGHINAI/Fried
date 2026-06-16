# Fried — Conversion & Insecurity Strategy

Research-backed plan for the front-door $4.99 conversion + the retention loop.
Two independent research sweeps (viral-app teardowns + behavioral neuroscience)
converged on the same playbook. Sources are cited inline below.

---

## The one decision that de-risks everything: stay a one-time purchase

**Keep the $4.99 one-time non-consumable. Do NOT switch to a subscription/trial.**

Apple pulled **Cal AI** in 2026 under Guideline **3.1.2** for a manipulative
subscription paywall (showing a per-week price more prominently than the real
charge), and killed toggle/free-trial paywalls. A clean one-time price with the
amount shown plainly **sidesteps that entire minefield** — and it matches the
"$5" you wanted. Trials only exist for subscriptions, so "2-day trial" would
force us into the exact rejection zone Apple is actively policing. We get the
"reward" another way (below).

> Hard/soft paywall gating the *result detail* converts ~**5.5×** better than
> freemium (RevenueCat 2025: 12.11% vs 2.18% Day-35). We are NOT a freemium app.

---

## The front door: sell the OTHER HALF (this is what makes them pay)

The conversion is won by the *result*, not the paywall. The mechanic, assembled
from the highest-converting apps (Umax, LooksMax, Tinder Gold, Handsome AI) and
the behavioral literature:

1. **Earn it first (IKEA effect + sunk cost).** 60–90s of effortful, self-authored
   input (quiz + reaction test) BEFORE any ask. People pay **63% more** for things
   they helped build (Norton/Ariely). The test must *complete successfully* or the
   effect evaporates.
2. **Reveal the scary verdict FREE** — the shareable hook:
   - The big **Fried Score** (tabular, turns red when bad).
   - **"More fried than X% of people your age"** — social comparison (Festinger).
     We target the **below-average sting (~60–85%)**, never "bottom 5%" (reads fake
     → disengagement). Always recoverable.
   - The **loss gap**: `FRIED NOW → RECOVERABLE TO`, "you're sitting on an N-point
     loss." Loss framing (Kahneman λ≈2.25 — losses hurt ~2× gains). This is the
     current→potential pattern that Handsome AI/Mogged convert on.
3. **Lock the WHY + HOW (the open loop — Zeigarnik/Ovsiankina).** Free users see
   their **#1 leak named** ("Your #1 leak: Focus hold") but the explanation, the
   other four axes' scores, and the recovery plan are **blurred/redacted**. The
   brain compulsively wants to close a visible-but-incomplete loop. Tinder's blurred
   likes convert ~8% to a $20/mo upgrade on this mechanic alone.
4. **Paywall = "1 step to view."** Loss-framed headline ("You're sitting on an
   N-point loss"), value stack (the 5-axis breakdown, the named leak, the recovery
   plan+goal, daily tracking), **price shown plainly**, dismiss one obvious tap away.
5. **The "reward" instead of a trial:** the free verdict is genuinely valuable +
   screenshot-able, AND **invite 3 friends → unlock free**. Honest, and it feeds the
   viral acquisition loop (Umax's growth engine). The score IS the marketing.

---

## The strict calculator (legitimacy = the insecurity bites)

`BrainBreakdownEngine` decomposes the headline score into **5 axes, each traceable
to real inputs** — so the number feels *earned*, not random:

| Axis | Computed from |
|------|---------------|
| **Focus hold** | movie-without-phone, tabs open, finishing things, reaction steadiness |
| **Scroll pull** | short-form video, your "poison", screen-time load |
| **Sleep & mornings** | first thing you touch on waking, screen-time load |
| **Reflex speed** | reaction-test mean time (200→650ms) |
| **Focus consistency** | reaction-test erraticness |

Plus `percentile` (age-adjusted, monotonic) and `potential` (the recoverable
target → the loss gap). The 5 axes ARE the paid payload — granularity reads as
depth reads as credibility.

---

## Credibility through type, not gimmicks

Per the neuro research, a made-up score only stings if it *feels* like a measured
instrument:
- **Tabular figures** (`monospacedDigit`) on every number — reads as a readout, not a graphic.
- **Huge, heavy** hero number; **uppercase, wide-tracked** axis labels (clinical chrome).
- Kept the warm copper aesthetic (no clashing clinical blue) — **type** does the
  credibility work, **color** stays on-brand. One desaturated **alarm red** signals
  *decline/loss only* (stays urgent because it's rare); muted **green** = recovery.

---

## The retention loop (after they've paid)

- **Decay made felt** — the brain fries ~13/day; on return the bar drains, a
  "while you were gone — fried X%, aged Y" banner lands, heavy haptic. (Shipped.)
- **Streak-as-loss** — the 🔥 streak turns **red + dimmed when at-risk**; completing
  one de-fry mission secures it; "complete 1 to keep your N-day streak — resets at
  midnight." The personalized 7pm notification: *"🔥 Your N-day streak ends tonight."*
  Duolingo's #1 retention mechanic; 7-day-streak users retain **2.4×**. (Shipped.)
- **Daily Brain Report** — one on-device AI reading/day = the variable reward
  (dopamine lives in *uncertainty* of a genuine payoff). (Shipped.)

---

## Ethics / Apple guardrails (non-negotiable, baked in)

The one-sentence rule: **every fear is true, every locked thing is real, the price
is the most prominent number, the exit is one tap away.**
- ✅ Real computed score; loss framing of a *real* deficit; percentile vs a disclosed
  population; honest variable rewards.
- ❌ No fake countdowns, no fabricated scores/percentiles, no price obfuscation, no
  hidden dismiss, no clinical/diagnostic claims.
- "**Entertainment only — not a measurement of health, focus, or intelligence**"
  disclaimer on every surface. Forbidden medical terms (cognitive, ADHD, IQ,
  dopamine, attention span, …) kept out of all UI strings.

---

## Status

**Built & verified:** strict 5-axis calculator · reveal front-door (free verdict +
percentile + loss gap + locked breakdown) · loss-framed paywall · streak-as-loss +
personalized notifications · tabular/clinical type system. 8/8 tests pass.

**Candidate next:** "potential you" share card (viral) · onboarding progress bar +
theatrical analysis screen (IKEA effect) · A/B the percentile band · exit-offer
re-anchor copy ("$4.99 = less than a coffee").

### Sources
RevenueCat State of Subscription Apps 2025 · Superwall paywall patterns · ScreensDesign/Adapty
teardowns (Umax, Cal AI, LooksMax, Rizz, Finch) · Kahneman & Tversky (loss aversion λ=2.25) ·
Zeigarnik/Ovsiankina (Nature 2025 meta-analysis) · Norton/Mochon/Ariely (IKEA effect) ·
Festinger (social comparison) · Ferster & Skinner (variable-ratio) · Apple Guideline 3.1.2 / Cal AI crackdown.
