import Foundation
import CoreLogic
import DomainEntities
import ComposableArchitecture
import RunningTimerFeature

public enum TimerCardAction: Equatable {
    case start, edit, delete
}

struct TimerCardState: Equatable, Identifiable {

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

let timerCardReducer = Reducer<TimerCardState, TimerCardAction, ()>.combine(
    
    Reducer { state, action, _ in
        
        switch action {
        case .start, .edit, .delete:
            break
        }
        
        return .none
    }
)
