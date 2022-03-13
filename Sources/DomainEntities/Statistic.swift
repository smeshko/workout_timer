import Foundation

public struct Statistic: Equatable, Identifiable {
    public let id: UUID
    public let workoutName: String
    public let duration: Double
    public let startDate: Date
    public let finishDate: Date
    public let burnedCalories: Int

    public init(id: UUID, workoutName: String, duration: Double, startDate: Date, finishDate: Date, burnedCalories: Int) {
        self.id = id
        self.workoutName = workoutName
        self.duration = duration
        self.startDate = startDate
        self.finishDate = finishDate
        self.burnedCalories = burnedCalories
    }
}
