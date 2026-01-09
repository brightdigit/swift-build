import Testing
@testable import SingleTargetPackage

struct GreeterTests {
    @Test func greeting() throws {
        let greeter = Greeter()
        #expect(greeter.greet("World") == "Hello, World!")
    }
} 