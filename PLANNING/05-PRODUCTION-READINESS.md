# Fried — Production Readiness Audit (path to App Store)

Status of every area, and exactly what's left to be a launch-ready, conversion-optimized app.

## ✅ DONE
- Full flow: splash → quiz → interstitial → reaction gauntlet → calculating → reveal (wow + confetti) → paywall → home (Today/Trends/You tabs).
- **Mascot** "Yolkie" (reacts to tier) across splash, interstitial, calculating, home.
- **Insecurity on-screen**: 144x/day interstitial + "crispier than N% of people" comparison.
- **Value**: personalized de-fry plan + AI analysis + breakdown + paywall plan-preview.
- **Monetization**: StoreKit 2 lifetime unlock, discount-on-exit ladder (50%→80%) with a clear way out, invite-to-unlock.
- On-device AI roast + analysis ($0), deterministic fallback.
- App icon, privacy manifest, share card, history persistence, tests (8/8), archives.

## 🔴 REQUIRED before submission (blockers)
1. **Real Terms + Privacy pages.** Currently `fried.app/terms` placeholders. Need live URLs (host a simple page) — App Review 5.1.1 rejects missing/broken privacy links.
2. **Create the 3 IAP products in App Store Connect** (`com.fried.app.lifetime`, `.off50`, `.off80`) at $4.99/$2.49/$0.99, all non-consumable. (Or switch discounts to Apple Offer Codes.)
3. **Apple Developer Program** ($99/yr) + Small Business Program (15%).
4. **App Store assets**: screenshots (6.9″ 1320×2868 required, 6.7″, iPad 13″), optional app-preview video, listing (name/subtitle/description with the disclaimer), keywords.
5. **App Privacy + Age-rating questionnaires** (answer health module "none" — true now).
6. **Reviewer note**: "subjective humor/vibe-check, not a measurement" + a demo video.

## 🟠 HIGH value (do before/just after launch)
1. **Daily notification reminder** — "Time to check how fried you are 🍳". The single biggest retention lever for a daily-ritual app. Needs `UNUserNotificationCenter` permission (with a warm-up screen first, per research) + a scheduled local notification. ~half a day.
2. **Daily challenge with check-offs** — make the de-fry plan *actionable*: tappable daily tasks ("✓ phone-free first hour") that feed the streak. Turns "a number" into a program people pay for.
3. **Improvement tracking** — "You've dropped 12 points since you started 📉" on Today/Trends. Makes the value felt over time.

## 🟡 MEDIUM (polish + conversion)
- **Onboarding depth** (per your research): mascot **speech bubbles** that "talk", 2–3 more personalization questions, a mid-onboarding **review prompt** (Cal AI's rating trick at peak goodwill), a "building your plan…" animated loader.
- **More content variety**: expand the RoastBank + AI prompts so daily roasts/analyses don't repeat; more de-fry steps.
- **Accessibility**: Dynamic Type pass, VoiceOver labels on the dial/mascot/charts, full reduce-motion coverage (confetti off when reduce-motion).
- **Edge cases**: empty trend state, first-launch, re-test mid-session, network-less behavior, very fast/slow reaction outliers.
- **Settings**: notification toggle, "How it works", reset, share the app.

## 🟢 NICE later
- Analytics funnel (TelemetryDeck or App Store Connect analytics — no backend needed) to see onboarding→paywall→purchase drop-off and A/B the paywall.
- Sound effects on the reaction game + reveal.
- More mascot moods/animations (blink, react live during the gauntlet).
- Widget ("today's fried score"), Live Activity, App Clip for the share link.
- Real referral verification for invite-to-unlock (needs a tiny backend).

## Honest priorities
For a viral toy, the order that matters most: **(1) get it live** (the REQUIRED list), **(2) daily notification + daily challenge** (retention + value to justify $5), **(3) analytics to learn**, then iterate the onboarding depth from real numbers rather than building 20 screens on spec.
