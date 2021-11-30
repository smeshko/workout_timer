import Foundation

public struct FinishedWorkout: Equatable {
    public let workout: QuickWorkout
    public let totalDuration: TimeInterval
    public let startDate: Date
    public let finishDate: Date
    
    public init(workout: QuickWorkout, totalDuration: TimeInterval, startDate: Date, finishDate: Date) {
        self.workout = workout
        self.totalDuration = totalDuration
        self.startDate = startDate
        self.finishDate = finishDate
    }
}
