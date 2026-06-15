# Fried — App Store Review & Deployment

> What I (the agent) can do here vs. what needs you (the human) in App Store Connect.

## Review-survival checklist (do BEFORE submitting)
- [ ] **Score is honestly subjective** (quiz + reaction game), never presented as a real measurement → clears **1.1.6**.
- [ ] **No forbidden words** in any UI string or metadata: *attention span, cognitive, ADHD, dopamine, neurological, clinical, diagnose, measure, accurate, brain age, IQ* → clears **1.4.1**. (Grep the whole `Sources/` before each submit.)
- [ ] **Roast is self-directed + behavior-based + PG-13**, never appearance/identity/protected traits, never aimed at other people or uploaded photos → clears **1.1.1 / 1.2**.
- [ ] **Recurring value present** (daily score, streak, trend, de-fry, roast packs) → clears **4.2** (not a thin novelty).
- [ ] **Disclaimer** on the reveal screen AND in the App Store description (verbatim from 00-product §1).
- [ ] **Paywall** shows price, "one-time, no subscription," **Restore Purchases**, and links to **Terms** + **Privacy** → clears **3.1.2**.
- [ ] **Privacy:** working privacy-policy URL in App Store Connect + in-app; `PrivacyInfo.xcprivacy` declares no tracking / no data leaves device → clears **5.1.1**.
- [ ] **Age rating:** answer the new (post-Jan-2026) questionnaire honestly; crude/roast humor ⇒ likely **13+ or 16+**; answer the health/medical module **"none"** (true once cognitive framing is stripped).
- [ ] **Reviewer note:** "Fried is a subjective humor/vibe-check quiz for entertainment, not a measurement of cognition or health." + a 20s demo video.

## Deployment steps — who does what
| Step | Who | How |
|---|---|---|
| Apple Developer Program ($99/yr) | **YOU** (manual, one-time) | developer.apple.com → enroll (individual = fastest; ID verify can take hours–days) |
| Enroll Small Business Program (15%) | **YOU** | App Store Connect → Agreements |
| Bundle ID `com.<you>.fried` | me/you | Xcode auto, or `fastlane produce` |
| Signing certs/profiles | me (`fastlane match`) or Xcode automatic | one-time |
| Build + archive | **me** | `xcodebuild archive` (project already builds) |
| `.ipa` export | me | `xcodebuild -exportArchive` |
| App Store Connect app record + listing | **YOU** (manual UI) | name, subtitle, description (w/ disclaimer), keywords |
| Upload to TestFlight | me (`xcrun`/`fastlane pilot`) — needs your API key | |
| App Privacy + Age questionnaires | **YOU** (manual UI) | the modules above |
| Screenshots | me capture (`simctl`) + you upload | 2026 sizes: 6.9″ **1320×2868** required; iPad 13″ **2064×2752** |
| Submit for review | **YOU** | answer export-compliance/content-rights prompts |
| Review wait | — | ~90% < 24h, typical 24–48h; expect ≥1 rejection round for this genre |

**Honest bottom line:** I build, test, archive, and prepare everything (icon, screenshots, metadata text, privacy manifest, reviewer notes). The actual submission needs **your Apple Developer account + ~6 manual App Store Connect steps**, which I'll hand you as a literal checklist with the exact text to paste. I cannot click "Submit" for you, and I won't claim the app is "live" until you confirm Apple approved it.

## What "done" looks like from me
1. `xcodebuild test` green + full simulator E2E recording.
2. `Fried.xcarchive` + exported `.ipa`.
3. App Store metadata pack: name/subtitle/description/keywords/disclaimer text, 6.9″ + 6.7″ + iPad screenshots, app icon, privacy answers, reviewer note + demo video script.
4. The fastlane lane (optional) so you can `fastlane release` once enrolled.
