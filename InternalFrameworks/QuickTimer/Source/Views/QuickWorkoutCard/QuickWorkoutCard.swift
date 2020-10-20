import Foundation
import CorePersistence
import ComposableArchitecture

public enum QuickWorkoutCardAction: Equatable {
    case tapStart
}

public struct QuickWorkoutCardState: Equatable, Identifiable {

    public var id: UUID { workout.id }
    var workout: QuickWorkout
    var canStart: Bool = false

    var segmentsCount: Int {
        workout.segments.count
    }

    var duration: Int {
        Int(workout.segments.map { $0.sets * ($0.pause + $0.work) }.reduce(0, +) / 60)
    }

    public init(workout: QuickWorkout, canStart: Bool = false) {
        self.workout = workout
        self.canStart = canStart
    }
}

public struct QuickWorkoutCardEnvironment: Equatable {

    public init() {}
}

public let quickWorkoutCardReducer = Reducer<QuickWorkoutCardState, QuickWorkoutCardAction, QuickWorkoutCardEnvironment> { state, action, environment in

    switch action {
    case .tapStart:
        break
    }

    return .none
}
