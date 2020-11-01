import Foundation
import DomainEntities
import ComposableArchitecture
import RunningTimer

public enum QuickWorkoutCardAction: Equatable {
    case tapStart
    case runningTimerAction(RunningTimerAction)
}

struct QuickWorkoutCardState: Equatable, Identifiable {

    public var id: UUID { workout.id }
    var workout: QuickWorkout
    var canStart: Bool = false
    var runningTimerState: RunningTimerState

    var segmentsCount: Int {
        workout.segments.count
    }

    var duration: Int {
        Int(workout.segments.map { $0.sets * ($0.pause + $0.work) }.reduce(0, +) / 60)
    }

    public init(workout: QuickWorkout, canStart: Bool = false) {
        self.workout = workout
        self.canStart = canStart
        self.runningTimerState = RunningTimerState(workout: workout)
    }
}

struct QuickWorkoutCardEnvironment: Equatable {

    public init() {}
}

let quickWorkoutCardReducer = Reducer<QuickWorkoutCardState, QuickWorkoutCardAction, QuickWorkoutCardEnvironment>.combine(
    
    runningTimerReducer.pullback(
        state: \.runningTimerState,
        action: /QuickWorkoutCardAction.runningTimerAction,
        environment: { env in RunningTimerEnvironment(mainQueue: DispatchQueue.main.eraseToAnyScheduler(), soundClient: .live)}
    ),
    Reducer { state, action, environment in
        
        switch action {
        case .tapStart:
            state.runningTimerState = RunningTimerState(workout: state.workout)
            
        case .runningTimerAction(_):
            break
        }
        
        return .none
    }
)
