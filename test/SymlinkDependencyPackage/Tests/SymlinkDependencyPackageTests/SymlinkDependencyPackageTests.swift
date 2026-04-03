import XCTest
@testable import SymlinkDependencyPackage

final class SymlinkDependencyPackageTests: XCTestCase {
    func testExample() throws {
        let package = SymlinkDependencyPackage()
        XCTAssertEqual(package.text, "Hello, World!")
    }
}
