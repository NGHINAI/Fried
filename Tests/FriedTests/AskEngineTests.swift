import XCTest
@testable import Fried

/// Verifies the on-device AI output sanitizer fixes the exact junk the small model
/// produced in the wild: an echoed "**Yolkie:**" label, markdown asterisks, and lists.
final class AskEngineTests: XCTestCase {

    func testStripsEchoedYolkieLabel() {
        XCTAssertEqual(AskEngine.clean("**Yolkie:** Hey there, slow poke!"), "Hey there, slow poke!")
        XCTAssertEqual(AskEngine.clean("Yolkie: You're 63% fried."), "You're 63% fried.")
    }

    func testStripsMarkdownEmphasis() {
        XCTAssertEqual(AskEngine.clean("You're **deep fried** today."), "You're deep fried today.")
        XCTAssertEqual(AskEngine.clean("## Heading\nDo a mission."), "Heading Do a mission.")
    }

    func testFlattensLists() {
        let raw = "Here's how:\n1. Start small\n2. Practice daily\n- Take breaks"
        let out = AskEngine.clean(raw)
        XCTAssertFalse(out.contains("1."))
        XCTAssertFalse(out.contains("\n"))
        XCTAssertTrue(out.contains("Start small"))
        XCTAssertTrue(out.contains("Take breaks"))
    }

    func testLeavesCleanTextAlone() {
        let good = "You're 71% fried — do one mission now."
        XCTAssertEqual(AskEngine.clean(good), good)
    }
}
