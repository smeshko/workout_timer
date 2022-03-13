import Foundation

public struct QuickWorkout: Equatable, Identifiable, Hashable {
    public let id: UUID
    public let name: String
    public let color: WorkoutColor
    public let countdown: Int
    public let segments: [QuickWorkoutSegment]

    public init(id: UUID, name: String, color: WorkoutColor, countdown: Int, segments: [QuickWorkoutSegment]) {
        self.id = id
        self.name = name
        self.countdown = countdown
        self.color = color
        self.segments = segments
    }
}

public extension QuickWorkout {
    var duration: Int {
        segments.map { $0.duration }.reduce(0, +)
    }
}
