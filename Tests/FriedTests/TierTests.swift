import XCTest
@testable import Fried

final class TierTests: XCTestCase {
    func testTierBoundaries() {
        XCTAssertEqual(FriedTier(score: 0),   .crispMind)
        XCTAssertEqual(FriedTier(score: 24),  .crispMind)
        XCTAssertEqual(FriedTier(score: 25),  .lightlyToasted)
        XCTAssertEqual(FriedTier(score: 49),  .lightlyToasted)
        XCTAssertEqual(FriedTier(score: 50),  .wellDone)
        XCTAssertEqual(FriedTier(score: 74),  .wellDone)
        XCTAssertEqual(FriedTier(score: 75),  .extraCrispy)
        XCTAssertEqual(FriedTier(score: 89),  .extraCrispy)
        XCTAssertEqual(FriedTier(score: 90),  .deepFried)
        XCTAssertEqual(FriedTier(score: 100), .deepFried)
    }
}
