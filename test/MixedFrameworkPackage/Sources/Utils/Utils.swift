import Foundation

public struct Utils {
    public static func trimWhitespace(_ string: String) -> String {
        string.trimmingCharacters(in: .whitespaces)
    }

    public static func isEmpty(_ string: String) -> Bool {
        trimWhitespace(string).isEmpty
    }
}
