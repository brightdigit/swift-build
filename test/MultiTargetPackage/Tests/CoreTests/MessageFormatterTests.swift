import Testing
@testable import Core

struct MessageFormatterTests {
    @Test func formatting() {
        let formatter = MessageFormatter()
        
        #expect(formatter.format("hello") == "hello")
        #expect(formatter.format("hello", capitalize: true) == "Hello")
        #expect(formatter.format("hello", reverse: true) == "olleh")
        #expect(formatter.format("hello", capitalize: true, reverse: true) == "olleH")
    }
} 