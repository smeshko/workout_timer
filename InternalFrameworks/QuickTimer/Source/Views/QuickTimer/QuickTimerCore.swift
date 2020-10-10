import ComposableArchitecture
import Foundation
import WorkoutCore

public enum QuickTimerAction: Equatable {
    case setRunningTimer(isPresented: Bool)
    case circuitPickerUpdatedValues(QuickExerciseBuilderAction)
    case runningTimerAction(RunningTimerAction)
}

public struct QuickTimerState: Equatable {

    var isRunningTimerPresented = false
    var segments: [QuickTimerSet] = []
    var circuitPickerState: QuickExerciseBuilderState
    var runningTimerState: RunningTimerState = RunningTimerState()
    
    public init(circuitPickerState: QuickExerciseBuilderState = QuickExerciseBuilderState(sets: 2, workoutTime: 60, breakTime: 20)) {
        self.circuitPickerState = circuitPickerState
    }
}

public struct QuickTimerEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var soundClient: SoundClient
    var uuid: () -> UUID
    var timerStep: DispatchQueue.SchedulerTimeType.Stride
    
    public init(
        uuid: @escaping () -> UUID,
        mainQueue: AnySchedulerOf<DispatchQueue>,
        soundClient: SoundClient,
        timerStep: DispatchQueue.SchedulerTimeType.Stride = .milliseconds(1)
    ) {
        self.uuid = uuid
        self.mainQueue = mainQueue
        self.soundClient = soundClient
        self.timerStep = timerStep
    }
}

public let quickTimerReducer =
    Reducer<QuickTimerState, QuickTimerAction, QuickTimerEnvironment>.combine(
        Reducer { state, action, environment in
            struct TimerId: Hashable {}
            
            switch action {
            case .setRunningTimer(isPresented: true):
                state.isRunningTimerPresented = true
                state.runningTimerState = RunningTimerState(segments: state.segments)

            case .setRunningTimer(isPresented: false):
                state.isRunningTimerPresented = false
                state.runningTimerState = RunningTimerState()

            case .runningTimerAction(let action):
                break

            case .circuitPickerUpdatedValues(let circuitPickerAction):
                switch circuitPickerAction {
                case .updatedSegments(let segments):
                    state.segments = segments
                default: break
                }
                
            }
            
            return .none
        },
        quickExerciseBuilderReducer.pullback(
            state: \.circuitPickerState,
            action: /QuickTimerAction.circuitPickerUpdatedValues,
            environment: { env in QuickExerciseBuilderEnvironment(uuid: env.uuid) }
        ),
        runningTimerReducer.pullback(
            state: \.runningTimerState,
            action: /QuickTimerAction.runningTimerAction,
            environment: { env in RunningTimerEnvironment(uuid: env.uuid, mainQueue: env.mainQueue, soundClient: env.soundClient)}
        )
)
