import XCTest
@testable import SingleTargetPackage

final class GreeterTests: XCTestCase {
    func testGreeting() throws {
        let greeter = Greeter()
        XCTAssertEqual(greeter.greet("World"), "Hello, World!")
    }
} 