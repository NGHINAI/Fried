import XCTest
@testable import Fried

final class ScoringEngineTests: XCTestCase {
    func testDeterministicAndClamped() {
        let q = QuizResult(answerIndices: [3,3,3,3,3,3], maxIndex: 3)
        let r = ReactionResult(meanMillis: 600, lapseVariance: 1.0)
        let s = ScoringEngine.score(quiz: q, reaction: r, screenTime: nil)
        XCTAssertEqual(s.value, ScoringEngine.score(quiz: q, reaction: r, screenTime: nil).value)
        XCTAssertTrue((0...100).contains(s.value))
        XCTAssertGreaterThan(s.value, 70)
    }

    func testLowInputsLowScore() {
        let q = QuizResult(answerIndices: [0,0,0,0,0,0], maxIndex: 3)
        let r = ReactionResult(meanMillis: 230, lapseVariance: 0.05)
        let s = ScoringEngine.score(quiz: q, reaction: r, screenTime: nil)
        XCTAssertLessThan(s.value, 30)
    }

    func testScreenTimePushesScoreUp() {
        let q = QuizResult(answerIndices: [1,1,1,1,1,1], maxIndex: 3)
        let r = ReactionResult(meanMillis: 400, lapseVariance: 0.4)
        let without = ScoringEngine.score(quiz: q, reaction: r, screenTime: nil).value
        let heavy = ScreenTimeResult(totalMinutes: 600, apps: [])
        let with = ScoringEngine.score(quiz: q, reaction: r, screenTime: heavy).value
        XCTAssertGreaterThanOrEqual(with, without)
    }
}
