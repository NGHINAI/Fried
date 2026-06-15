# Fried — Technical Architecture

> Locked 2026-06-15. iOS 26, SwiftUI, Swift 6.2. Zero backend. Zero run-cost.

## Principles
- **No server, no API keys, no per-use cost.** Everything on-device.
- **Score = deterministic math.** The "AI" is optional flavor on the roast text only.
- **Graceful degradation:** every "smart" path has a dumb fallback that works on every iPhone.
- **Swift 6 strict concurrency.** `@MainActor` UI; engine pure & testable (no UI deps).
- **TDD on the pure core** (scoring, OCR parsing, tier mapping, roast selection). UI verified by build + simulator snapshot.

## Data sources (all permission-light)
1. **Quiz** (6 self-report questions) — zero permission. Subjective by design (keeps us clear of App Review 1.1.6).
2. **Reaction Gauntlet** (in-app mini-game) — zero permission. Measures mean reaction time + lapse variance (a "vibe" proxy, never called a cognitive test).
3. **Screen-time screenshot OCR** (Vision `RecognizeTextRequest`, on-device, free) — user shares a screenshot; we parse hours/apps. *Optional, post-paywall "deep analysis." NOT required for the core reveal.*
   - We do **not** use FamilyControls/DeviceActivity: Apple sandboxes the numbers (confirmed by Apple DTS) and the distribution entitlement is a multi-week approval gate. Out of scope for v1.

## Scoring engine (`ScoringEngine.swift`, pure, unit-tested)
`func score(quiz: QuizResult, reaction: ReactionResult, screenTime: ScreenTimeResult?) -> FriedScore`
- Quiz axis (0–100): weighted sum of answer indices, normalized.
- Reaction axis (0–100): higher mean RT + higher lapse variance ⇒ more "fried."
- Blend: `0.45*quiz + 0.45*reaction + 0.10*screenTime` (screenTime weight redistributed to quiz/reaction when absent).
- Clamp 0–100, map to `FriedTier`. Deterministic & seedable for tests.

## On-device AI (`RoastEngine.swift`)
- Try `FoundationModels` (`SystemLanguageModel.default` → `LanguageModelSession`) when `.available`.
- System instructions force *playful, PG-13, behavior-based, never appearance/identity* → keeps it funny AND past the guardrail.
- `try/catch` any error (`guardrailViolation`, model-not-ready, ineligible device) ⇒ **fall back to a curated `RoastBank` keyed by tier** (still $0, still offline, works on 100% of devices).
- The AI is never on the critical path — the reveal always has a roast.

## Persistence (`Store` + `AppState`)
- `UserDefaults`/`@AppStorage` for: lifetime-unlock flag (mirrors StoreKit entitlement), streak count, last-played date, history of daily scores (small JSON), onboarding-complete.
- StoreKit 2 `Transaction.currentEntitlements` is the source of truth for unlock; UserDefaults is a cache.

## Monetization (`Store.swift`)
- StoreKit 2, one **non-consumable** `com.fried.app.lifetime`.
- `.storekit` config file for local/simulator testing (no sandbox account needed).
- `isUnlocked` gates the paid surfaces. `Restore` button required (App Review).

## File / module map
```
Sources/Fried/
  App/
    FriedApp.swift            // @main, injects AppState + Store
    AppState.swift            // ObservableObject: route, streak, history, unlock cache
    Routing.swift             // enum Screen { splash, onboarding, reveal, home, paywall }
  Design/
    Theme.swift               // colors, gradients, type, spacing, haptics (source of truth)
    Components/
      GlassCard.swift
      ScoreDial.swift         // animated ring + counting numeral
      PrimaryButton.swift
      ShareCardView.swift     // 1080x1920 export
  Core/                       // PURE, unit-tested, no SwiftUI import
    Models.swift              // QuizResult, ReactionResult, ScreenTimeResult, FriedScore, FriedTier
    ScoringEngine.swift
    RoastBank.swift           // deterministic fallback roasts per tier
    QuizContent.swift         // the 6 questions + answer weights
  Features/
    Onboarding/
      OnboardingFlow.swift
      QuizCardView.swift
      ReactionGauntletView.swift   // the live mini-game
      CalculatingView.swift
    Reveal/
      RevealView.swift
      RoastEngine.swift            // FoundationModels + fallback
    Home/
      HomeView.swift               // daily score, streak, trend, de-fry
    Paywall/
      PaywallView.swift
    Store/
      Store.swift                  // StoreKit 2
  Resources/
    Assets.xcassets
    Fried.storekit                 // local IAP test config
Tests/FriedTests/
  ScoringEngineTests.swift
  TierTests.swift
  RoastBankTests.swift
  ScreenTimeOCRParserTests.swift
```

## Build/test tooling
- **XcodeGen** (`project.yml`) generates `Fried.xcodeproj` — agent-authorable, no fragile pbxproj by hand.
- Build: `xcodebuild -scheme Fried -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build`
- Test: `xcodebuild test -scheme Fried -destination '...'` (unit tests run headless on the sim).
- Visual check: boot sim, `xcrun simctl` install + launch + screenshot.

## Device/OS support
- Deployment target **iOS 18** (broad reach) — but `FoundationModels` calls are `if #available(iOS 26)` gated; below that, always `RoastBank`. Reaction game, quiz, OCR, scoring, StoreKit all work iOS 18+. (Decision: target 18 to maximize the install base since AI is optional. Revisit to 26 only if a 26-only API becomes core.)
