import Testing
@testable import Validator

@Suite("Validator Swift Testing Suite")
struct ValidatorTests {
    let validator = Validator()

    @Test("Valid emails are accepted")
    func testValidEmails() {
        #expect(validator.validateEmail("test@example.com"))
        #expect(validator.validateEmail("user.name@domain.co.uk"))
        #expect(validator.validateEmail("  spaces@test.com  "))
    }

    @Test("Invalid emails are rejected")
    func testInvalidEmails() {
        #expect(!validator.validateEmail("notanemail"))
        #expect(!validator.validateEmail("missing@domain"))
        #expect(!validator.validateEmail("nodomain@"))
    }

    @Test("Valid ages are accepted")
    func testValidAges() {
        #expect(validator.validateAge(0))
        #expect(validator.validateAge(25))
        #expect(validator.validateAge(150))
    }

    @Test("Invalid ages are rejected")
    func testInvalidAges() {
        #expect(!validator.validateAge(-1))
        #expect(!validator.validateAge(151))
        #expect(!validator.validateAge(1000))
    }
}
