import Utils

public struct Validator {
    public init() {}

    public func validateEmail(_ email: String) -> Bool {
        let trimmed = Utils.trimWhitespace(email)
        return trimmed.contains("@") && trimmed.contains(".")
    }

    public func validateAge(_ age: Int) -> Bool {
        age >= 0 && age <= 150
    }
}
