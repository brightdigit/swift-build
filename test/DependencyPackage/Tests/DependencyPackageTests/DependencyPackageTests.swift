import XCTest
@testable import DependencyPackage

final class DependencyPackageTests: XCTestCase {
    func testUniqueElements() {
        let package = DependencyPackage()
        let input = [1, 2, 2, 3, 3, 3, 4]
        let result = package.uniqueElements(from: input)
        XCTAssertEqual(result, [1, 2, 3, 4])
    }

    func testChunked() {
        let package = DependencyPackage()
        let input = [1, 2, 3, 4, 5, 6]
        let result = package.chunked(input, size: 2)
        XCTAssertEqual(result, [[1, 2], [3, 4], [5, 6]])
    }
}
