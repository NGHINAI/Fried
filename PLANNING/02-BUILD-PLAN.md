# Fried — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: superpowers:subagent-driven-development or superpowers:executing-plans. Steps use `- [ ]` checkboxes.

**Goal:** Ship a polished iOS "Brain Rot Vibe Check" app — 90-second wow onboarding, deterministic Fried Score, on-device AI roast with fallback, $4.99 lifetime StoreKit unlock — building + tested in the iOS 26 simulator.

**Architecture:** SwiftUI, Swift 6, zero backend. Pure testable Core (scoring/tiers/roasts/OCR-parse) under TDD; UI verified by build + simulator. XcodeGen generates the project.

**Tech Stack:** SwiftUI · FoundationModels (opt) · Vision OCR · StoreKit 2 · XcodeGen · XCTest.

---

## Phase 0 — Project scaffold
### Task 0: Generate a building project
**Files:** Create `project.yml`, `Sources/Fried/App/FriedApp.swift`, `Resources/Assets.xcassets`, `Fried.storekit`.
- [ ] Write `project.yml` (iOS 18 target, Fried app + FriedTests, FoundationModels weak-linked).
- [ ] `xcodegen generate` → `Fried.xcodeproj`.
- [ ] Minimal `FriedApp.swift` showing a black screen with the brand mark.
- [ ] `xcodebuild -scheme Fried -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build` → **BUILD SUCCEEDED**.
- [ ] Commit `feat: scaffold Fried iOS project (builds on iOS 26 sim)`.

## Phase 1 — Pure Core (TDD)
### Task 1: Models + FriedTier mapping
**Files:** Create `Sources/Fried/Core/Models.swift`, `Tests/FriedTests/TierTests.swift`.
- [ ] **Test first** — tier boundaries:
```swift
import XCTest
@testable import Fried
final class TierTests: XCTestCase {
    func testTierBoundaries() {
        XCTAssertEqual(FriedTier(score: 0), .crispMind)
        XCTAssertEqual(FriedTier(score: 24), .crispMind)
        XCTAssertEqual(FriedTier(score: 25), .lightlyToasted)
        XCTAssertEqual(FriedTier(score: 49), .lightlyToasted)
        XCTAssertEqual(FriedTier(score: 50), .wellDone)
        XCTAssertEqual(FriedTier(score: 74), .wellDone)
        XCTAssertEqual(FriedTier(score: 75), .extraCrispy)
        XCTAssertEqual(FriedTier(score: 89), .extraCrispy)
        XCTAssertEqual(FriedTier(score: 90), .deepFried)
        XCTAssertEqual(FriedTier(score: 100), .deepFried)
    }
}
```
- [ ] Run → FAIL (no types). Implement `FriedTier` + `init(score:)` + `QuizResult`/`ReactionResult`/`ScreenTimeResult`/`FriedScore` structs.
- [ ] Run → PASS. Commit.

### Task 2: ScoringEngine
**Files:** Create `Sources/Fried/Core/ScoringEngine.swift`, `Tests/FriedTests/ScoringEngineTests.swift`.
- [ ] **Test first** — determinism, clamping, screen-time-absent reweighting, monotonicity:
```swift
final class ScoringEngineTests: XCTestCase {
    func testDeterministicAndClamped() {
        let q = QuizResult(answerIndices: [3,3,3,3,3,3], maxIndex: 3)   // most-fried answers
        let r = ReactionResult(meanMillis: 600, lapseVariance: 1.0)     // slow + erratic
        let s = ScoringEngine.score(quiz: q, reaction: r, screenTime: nil)
        XCTAssertEqual(s.value, ScoringEngine.score(quiz: q, reaction: r, screenTime: nil).value)
        XCTAssertTrue((0...100).contains(s.value))
        XCTAssertGreaterThan(s.value, 70)   // heavy fried inputs ⇒ high score
    }
    func testLowInputsLowScore() {
        let q = QuizResult(answerIndices: [0,0,0,0,0,0], maxIndex: 3)
        let r = ReactionResult(meanMillis: 230, lapseVariance: 0.05)
        XCTAssertLessThan(ScoringEngine.score(quiz: q, reaction: r, screenTime: nil).value, 30)
    }
}
```
- [ ] Run → FAIL. Implement weighted blend (0.45/0.45/0.10, reweight when screenTime nil), clamp, tier. Run → PASS. Commit.

### Task 3: RoastBank (deterministic fallback)
**Files:** Create `Sources/Fried/Core/RoastBank.swift`, `Tests/FriedTests/RoastBankTests.swift`.
- [ ] **Test first** — every tier returns a non-empty, behavior-based line; selection is seedable:
```swift
final class RoastBankTests: XCTestCase {
    func testEveryTierHasRoasts() {
        for tier in FriedTier.allCases {
            XCTAssertFalse(RoastBank.roast(for: tier, seed: 1).isEmpty)
        }
    }
    func testSeedDeterministic() {
        XCTAssertEqual(RoastBank.roast(for: .deepFried, seed: 7),
                       RoastBank.roast(for: .deepFried, seed: 7))
    }
}
```
- [ ] Run → FAIL. Implement curated per-tier arrays (PG-13, behavior-only, self-directed) + seeded pick. Run → PASS. Commit.

### Task 4: Screen-time OCR parser (pure string→data, no Vision in the test)
**Files:** Create `Sources/Fried/Core/ScreenTimeOCRParser.swift`, `Tests/FriedTests/ScreenTimeOCRParserTests.swift`.
- [ ] **Test first**:
```swift
final class ScreenTimeOCRParserTests: XCTestCase {
    func testParsesRows() {
        let lines = ["Screen Time","Daily Average","6h 12m","Instagram","3h 42m","Safari","58m"]
        let r = ScreenTimeOCRParser.parse(lines)
        XCTAssertEqual(r.totalMinutes, 6*60+12)
        XCTAssertTrue(r.apps.contains { $0.app == "Instagram" && $0.minutes == 3*60+42 })
    }
}
```
- [ ] Run → FAIL. Implement regex `(?:(\d+)\s*h)?\s*(?:(\d+)\s*m)?`, attach nearest label, capture "Daily Average"/"Total". Run → PASS. Commit.

## Phase 2 — Design system
### Task 5: Theme + core components
**Files:** Create `Design/Theme.swift`, `Design/Components/{GlassCard,PrimaryButton,ScoreDial}.swift`.
- [ ] Implement `Theme` (palette, heat gradient, fonts, spacing, haptic helper) per 00-design.
- [ ] `GlassCard` (`.ultraThinMaterial` + stroke), `PrimaryButton` (heat gradient + `.sensoryFeedback`), `ScoreDial` (Canvas ring + counting numeral, reduce-motion fallback).
- [ ] Build succeeds. Commit `feat: design system + glass components`.

## Phase 3 — Onboarding (the 90s wow)
### Task 6: Quiz content + QuizCard
**Files:** Create `Core/QuizContent.swift`, `Features/Onboarding/QuizCardView.swift`.
- [ ] 6 questions w/ answer arrays + weights (subjective, fun). Card UI: big question, tappable answers, progress dots, spring transition, haptic. Build. Commit.

### Task 7: Reaction Gauntlet (live data, the demoable beat)
**Files:** Create `Features/Onboarding/ReactionGauntletView.swift`.
- [ ] Reaction round (tap on green, randomized delays, record ms) + go/no-go round (tap green / withhold red). Produce `ReactionResult(meanMillis, lapseVariance)`. Big, juicy, haptic, anti-cheat (penalize early taps). Build + manual sim play. Commit.

### Task 8: Calculating beat + OnboardingFlow wiring
**Files:** Create `Features/Onboarding/{CalculatingView,OnboardingFlow}.swift`, `App/Routing.swift`, `App/AppState.swift`.
- [ ] Splash → quiz → gauntlet → calculating (2–4s, fake-precise copy) → emit `FriedScore`. Build + run full flow in sim. Commit.

## Phase 4 — Reveal + AI roast
### Task 9: RoastEngine (FoundationModels + fallback)
**Files:** Create `Features/Reveal/RoastEngine.swift`.
- [ ] `if #available(iOS 26)` + `SystemLanguageModel.default.availability == .available` ⇒ `LanguageModelSession` w/ playful instructions, `temperature 1.3`, `maximumResponseTokens 60`, `try/catch` ⇒ `RoastBank`. Else `RoastBank`. Manual: verify returns a line on sim. Commit.

### Task 10: RevealView + ShareCard
**Files:** Create `Features/Reveal/RevealView.swift`, `Design/Components/ShareCardView.swift`.
- [ ] Animated `ScoreDial` count-up + haptic ramp, tier label, roast (streams if AI), share button → `ImageRenderer` export of `ShareCardView` (1080×1920, watermark "fried.app"). Disclaimer line present. Build + sim screenshot. Commit.

## Phase 5 — Monetization
### Task 11: Store (StoreKit 2) + Fried.storekit
**Files:** Create `Features/Store/Store.swift`, `Resources/Fried.storekit`.
- [ ] Non-consumable `com.fried.app.lifetime`; `loadProducts`, `purchase`, `restore`, `Transaction.currentEntitlements`/`.updates` listener, `isUnlocked`. `.storekit` config for sim testing. Build. Commit.

### Task 12: PaywallView + gating
**Files:** Create `Features/Paywall/PaywallView.swift`; modify `RevealView` to gate breakdown/roast-packs.
- [ ] Teaser: score+card free; blurred breakdown + "Unlock everything — $4.99 once · no subscription" + Restore + terms/privacy links (App Review 3.1.2/5.1.1). Test purchase via `.storekit` in sim. Commit.

## Phase 6 — Home / retention
### Task 13: HomeView (daily score, streak, trend, de-fry)
**Files:** Create `Features/Home/HomeView.swift`; modify `AppState` (streak/history).
- [ ] Today's score, de-fry streak, 7-day trend chart (Swift Charts), daily roast, one de-fry nudge, "re-test" CTA. Build + sim. Commit.

## Phase 7 — Ship readiness
### Task 14: Disclaimers, privacy, age rating, icon, screenshots
**Files:** `Resources/Assets.xcassets` (icon), `PrivacyInfo.xcprivacy`, settings/about screen.
- [ ] App icon (heat-gradient brand), disclaimer screen, privacy manifest (no tracking, no data collected off-device), Settings → restore/terms/privacy/contact. Build. Commit.
### Task 15: Full test + simulator E2E + archive
- [ ] `xcodebuild test` green. Boot sim, run full onboarding→reveal→paywall→home, capture screenshots. `xcodebuild archive` succeeds. Commit. → hand to `03-APPSTORE-DEPLOY.md`.

---

## Self-review checklist (run after build)
- [ ] Every screen from 00-design §2 has a task (1→12 mapped).
- [ ] No forbidden words (attention span/cognitive/etc.) anywhere in UI strings — grep before submit.
- [ ] Disclaimer present on reveal + about + App Store description.
- [ ] Restore button exists; paywall shows price+terms+privacy.
- [ ] Type names consistent: `FriedScore.value:Int`, `FriedTier(score:)`, `ReactionResult(meanMillis:lapseVariance:)`, `QuizResult(answerIndices:maxIndex:)`, `Store.isUnlocked`.
