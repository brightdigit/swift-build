import XCTest
@testable import Core

final class MessageFormatterTests: XCTestCase {
    func testFormatting() {
        let formatter = MessageFormatter()
        
        XCTAssertEqual(formatter.format("hello"), "hello")
        XCTAssertEqual(formatter.format("hello", capitalize: true), "Hello")
        XCTAssertEqual(formatter.format("hello", reverse: true), "olleh")
        XCTAssertEqual(formatter.format("hello", capitalize: true, reverse: true), "olleH")
    }
} 