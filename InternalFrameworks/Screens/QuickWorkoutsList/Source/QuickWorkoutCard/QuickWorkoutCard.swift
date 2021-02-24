import Foundation
import CoreLogic
import DomainEntities
import ComposableArchitecture
import RunningTimer

public enum QuickWorkoutCardAction: Equatable {
    case tapStart
}

struct QuickWorkoutCardState: Equatable, Identifiable {

    public var id: UUID { workout.id }
    var workout: QuickWorkout

    var segmentsCount: Int {
        workout.segments.count
    }

    var duration: Int {
        let minutes = Int(workout.duration / 60)
        return minutes < 1 ? 1 : minutes
    }

    public init(workout: QuickWorkout) {
        self.workout = workout
    }
}

struct QuickWorkoutCardEnvironment {}

let quickWorkoutCardReducer = Reducer<QuickWorkoutCardState, QuickWorkoutCardAction, QuickWorkoutCardEnvironment>.combine(
    
    Reducer { state, action, environment in
        
        switch action {
        case .tapStart:
            break
        }
        
        return .none
    }
)
