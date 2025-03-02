import XCTest
@testable import Utils

final class StringUtilsTests: XCTestCase {
    func testCapitalize() {
        XCTAssertEqual(StringUtils.capitalize("hello"), "Hello")
        XCTAssertEqual(StringUtils.capitalize("world"), "World")
    }
    
    func testReverse() {
        XCTAssertEqual(StringUtils.reverse("hello"), "olleh")
        XCTAssertEqual(StringUtils.reverse("world"), "dlrow")
    }
} 