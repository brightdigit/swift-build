import XCTest
@testable import Calculator

final class CalculatorXCTests: XCTestCase {
    var calculator: Calculator!

    override func setUp() {
        super.setUp()
        calculator = Calculator()
    }

    func testAddition() {
        XCTAssertEqual(calculator.add(10, 20), 30)
        XCTAssertEqual(calculator.add(-5, 5), 0)
    }

    func testSubtraction() {
        XCTAssertEqual(calculator.subtract(10, 5), 5)
        XCTAssertEqual(calculator.subtract(0, 10), -10)
    }

    func testMultiplication() {
        XCTAssertEqual(calculator.multiply(4, 5), 20)
        XCTAssertEqual(calculator.multiply(-3, 3), -9)
    }

    func testDivision() {
        XCTAssertEqual(calculator.divide(10, 2), 5)
        XCTAssertEqual(calculator.divide(7, 3), 2)
    }

    func testDivisionByZero() {
        XCTAssertNil(calculator.divide(5, 0))
    }

    func testEdgeCases() {
        XCTAssertEqual(calculator.add(Int.max, 0), Int.max)
        XCTAssertEqual(calculator.multiply(1, 100), 100)
    }
}
