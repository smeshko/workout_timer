public struct Segment: Equatable {
    public enum Category: Equatable {
        case workout
        case pause
    }
    
    public let duration: Int
    public let category: Category
}
