import Testing
@testable import Calculator

@Suite("Calculator Swift Testing Suite")
struct CalculatorTests {
    let calculator = Calculator()

    @Test("Addition works correctly")
    func testAddition() {
        #expect(calculator.add(2, 3) == 5)
        #expect(calculator.add(-1, 1) == 0)
        #expect(calculator.add(0, 0) == 0)
    }

    @Test("Subtraction works correctly")
    func testSubtraction() {
        #expect(calculator.subtract(5, 3) == 2)
        #expect(calculator.subtract(1, 1) == 0)
        #expect(calculator.subtract(-5, -3) == -2)
    }

    @Test("Multiplication works correctly")
    func testMultiplication() {
        #expect(calculator.multiply(2, 3) == 6)
        #expect(calculator.multiply(-2, 3) == -6)
        #expect(calculator.multiply(0, 100) == 0)
    }

    @Test("Division works correctly")
    func testDivision() {
        #expect(calculator.divide(6, 3) == 2)
        #expect(calculator.divide(5, 2) == 2)
        #expect(calculator.divide(0, 5) == 0)
    }

    @Test("Division by zero returns nil")
    func testDivisionByZero() {
        #expect(calculator.divide(10, 0) == nil)
    }
}
