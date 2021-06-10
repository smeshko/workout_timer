import Foundation

public struct Statistic: Equatable, Identifiable {
    public let id: UUID
    public let date: Date
    public let workoutName: String
    public let workoutDuration: Double

    public init(id: UUID, date: Date, workoutName: String, workoutDuration: Double) {
        self.id = id
        self.date = date
        self.workoutName = workoutName
        self.workoutDuration = workoutDuration
    }
}
