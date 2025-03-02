public struct StringUtils {
    public static func capitalize(_ string: String) -> String {
        return string.prefix(1).uppercased() + string.dropFirst()
    }
    
    public static func reverse(_ string: String) -> String {
        return String(string.reversed())
    }
} 