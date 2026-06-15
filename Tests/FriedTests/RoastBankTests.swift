import XCTest
@testable import Fried

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
