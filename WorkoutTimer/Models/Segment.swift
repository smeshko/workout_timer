public struct Segment {
    public enum Category {
        case workout
        case pause
    }
    
    public let duration: Int
    public let category: Category
}
