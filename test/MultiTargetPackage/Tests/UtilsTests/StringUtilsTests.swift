import Testing
@testable import Utils

struct StringUtilsTests {
    @Test func capitalize() {
        #expect(StringUtils.capitalize("hello") == "Hello")
        #expect(StringUtils.capitalize("world") == "World")
    }
    
    @Test func reverse() {
        #expect(StringUtils.reverse("hello") == "olleh")
        #expect(StringUtils.reverse("world") == "dlrow")
    }
} 