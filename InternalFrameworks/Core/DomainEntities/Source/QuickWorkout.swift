import Foundation

public struct QuickWorkout: Equatable, Identifiable, Hashable {
    public let id: UUID
    public let name: String
    public let color: WorkoutColor
    public let segments: [QuickWorkoutSegment]

    public init(id: UUID, name: String, color: WorkoutColor, segments: [QuickWorkoutSegment]) {
        self.id = id
        self.name = name
        self.color = color
        self.segments = segments
    }
}
