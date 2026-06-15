import XCTest
@testable import Fried

final class ScreenTimeOCRParserTests: XCTestCase {
    func testParsesRows() {
        let lines = ["Screen Time", "Daily Average", "6h 12m",
                     "Instagram", "3h 42m", "Safari", "58m"]
        let r = ScreenTimeOCRParser.parse(lines)
        XCTAssertEqual(r.totalMinutes, 6 * 60 + 12)
        XCTAssertTrue(r.apps.contains { $0.app == "Instagram" && $0.minutes == 3 * 60 + 42 })
        XCTAssertTrue(r.apps.contains { $0.app == "Safari" && $0.minutes == 58 })
    }

    func testHandlesMinutesOnly() {
        XCTAssertEqual(ScreenTimeOCRParser.duration(in: "58m"), 58)
        XCTAssertEqual(ScreenTimeOCRParser.duration(in: "1h"), 60)
        XCTAssertEqual(ScreenTimeOCRParser.duration(in: "3 hr 42 min"), 222)
        XCTAssertNil(ScreenTimeOCRParser.duration(in: "Instagram"))
    }
}
