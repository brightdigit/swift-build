import Utils

public struct MessageFormatter {
    public init() {}
    
    public func format(_ message: String, capitalize: Bool = false, reverse: Bool = false) -> String {
        var result = message
        
        if capitalize {
            result = StringUtils.capitalize(result)
        }
        
        if reverse {
            result = StringUtils.reverse(result)
        }
        
        return result
    }
} 