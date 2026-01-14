import XCTest
@testable import Utils

final class UtilsXCTests: XCTestCase {
    func testTrimWhitespace() {
        XCTAssertEqual(Utils.trimWhitespace("  hello  "), "hello")
        XCTAssertEqual(Utils.trimWhitespace("nowhitespace"), "nowhitespace")
        XCTAssertEqual(Utils.trimWhitespace("   "), "")
    }

    func testIsEmpty() {
        XCTAssertTrue(Utils.isEmpty(""))
        XCTAssertTrue(Utils.isEmpty("   "))
        XCTAssertFalse(Utils.isEmpty("not empty"))
        XCTAssertFalse(Utils.isEmpty("  text  "))
    }
}
