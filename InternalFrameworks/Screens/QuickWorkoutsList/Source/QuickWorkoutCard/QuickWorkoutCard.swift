import Foundation
import CoreLogic
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
    var runningTimerState: RunningTimerState
    var isShowingTimer = false

    var segmentsCount: Int {
        workout.segments.count
    }

    var duration: Int {
        Int(workout.duration / 60)
    }

    public init(workout: QuickWorkout) {
        self.workout = workout
        self.runningTimerState = RunningTimerState(workout: workout)
    }
}

struct QuickWorkoutCardEnvironment {

    var notificationClient: LocalNotificationClient

    public init(notificationClient: LocalNotificationClient) {
        self.notificationClient = notificationClient
    }
}

let quickWorkoutCardReducer = Reducer<QuickWorkoutCardState, QuickWorkoutCardAction, QuickWorkoutCardEnvironment>.combine(
    
    runningTimerReducer.pullback(
        state: \.runningTimerState,
        action: /QuickWorkoutCardAction.runningTimerAction,
        environment: { env in RunningTimerEnvironment(mainQueue: DispatchQueue.main.eraseToAnyScheduler(), soundClient: .live, notificationClient: env.notificationClient)}
    ),
    Reducer { state, action, environment in
        
        switch action {
        case .tapStart:
            state.isShowingTimer = true
            state.runningTimerState = RunningTimerState(workout: state.workout)
            
        case .runningTimerAction(.finishedWorkoutAction(.didTapDoneButton)):
            state.isShowingTimer = false

        case .runningTimerAction:
            break
        }
        
        return .none
    }
)
