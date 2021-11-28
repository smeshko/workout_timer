import Foundation
import DomainEntities

public struct FinishedWorkout: Equatable {
    let workout: QuickWorkout
    let totalDuration: TimeInterval
    let startDate: Date
    let finishDate: Date
}
