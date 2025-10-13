import Algorithms

public struct DependencyPackage {
    public init() {}

    public func uniqueElements<T: Hashable>(from array: [T]) -> [T] {
        return array.uniqued()
    }

    public func chunked<T>(_ array: [T], size: Int) -> [[T]] {
        return array.chunks(ofCount: size).map(Array.init)
    }
}
