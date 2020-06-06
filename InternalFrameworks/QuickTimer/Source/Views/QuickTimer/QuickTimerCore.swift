import ComposableArchitecture
import Foundation
import WorkoutCore

public enum QuickTimerAction: Equatable {
    case timerTicked
    case segmentEnded
    case timerFinished
    case setNavigation
    case progressBarDidUpdate(Double)

    case timerControlsUpdatedState(QuickTimerControlsAction)
    case circuitPickerUpdatedValues(QuickExerciseBuilderAction)
}

public struct QuickTimerState: Equatable {
    var segments: [Segment] = []
    var currentSegment: Segment? = nil
    var totalTimeLeft: TimeInterval = 0
    var segmentTimeLeft: TimeInterval = 0
    
    var timerControlsState: QuickTimerControlsState
    var circuitPickerState: QuickExerciseBuilderState
    
    public init(segments: [Segment] = [],
                currentSegment: Segment? = nil,
                totalTimeLeft: TimeInterval = 0,
                segmentTimeLeft: TimeInterval = 0,
                circuitPickerState: QuickExerciseBuilderState = QuickExerciseBuilderState(sets: 2, workoutTime: 60, breakTime: 20),
                timerControlsState: QuickTimerControlsState = QuickTimerControlsState()) {
        self.segments = segments
        self.currentSegment = currentSegment
        self.circuitPickerState = circuitPickerState
        self.totalTimeLeft = totalTimeLeft
        self.segmentTimeLeft = segmentTimeLeft
        self.timerControlsState = timerControlsState
    }
}

public struct QuickTimerEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var soundClient: SoundClient
    var uuid: () -> UUID
    
    public init(
        uuid: @escaping () -> UUID,
        mainQueue: AnySchedulerOf<DispatchQueue>,
        soundClient: SoundClient
    ) {
        self.uuid = uuid
        self.mainQueue = mainQueue
        self.soundClient = soundClient
    }
}

public let quickTimerReducer =
    Reducer<QuickTimerState, QuickTimerAction, QuickTimerEnvironment>.combine(
        Reducer { state, action, environment in
            struct TimerId: Hashable {}
            
            switch action {
                
            case .setNavigation:
                state.updateSegments()
                
            case .progressBarDidUpdate:
                break
                
            case .timerControlsUpdatedState(let controlsAction):
                switch controlsAction {
                case .pause:
                    return Effect<QuickTimerAction, Never>.cancel(id: TimerId())
                    
                case .stop:
                    return Effect(value: QuickTimerAction.timerFinished)
                    
                case .start:
                    state.hidePickers()
                    state.togglePickersInteraction(disabled: true)
                    // timer has been previously stopped (as opposed to paused)
                    if state.currentSegment == nil {
                        state.updateSegments()
                    }
                    return Effect
                        .timer(id: TimerId(), every: 0.01, tolerance: .zero, on: environment.mainQueue)
                        .map { _ in QuickTimerAction.timerTicked }
                }
                
            case .circuitPickerUpdatedValues(let circuitPickerAction):
                switch circuitPickerAction {
                case .updatedSegments(let segments):
                    state.segments = segments
                    state.updateSegments()
                default: break
                }
                
            case .timerTicked:
                state.totalTimeLeft -= 0.01
                state.segmentTimeLeft -= 0.01
                
                if state.totalTimeLeft <= 0 {
                    return Effect(value: QuickTimerAction.timerFinished)
                }
                
                if state.segmentTimeLeft <= 0, !state.isCurrentSegmentLast {
                    return Effect(value: QuickTimerAction.segmentEnded)
                }
                
            case .segmentEnded:
                state.moveToNextSegment()
                return environment
                    .soundClient.play(.segment)
                    .fireAndForget()
                
            case .timerFinished:
                state.reset()
                return Effect<QuickTimerAction, Never>
                    .cancel(id: TimerId())
                    .flatMap { _ in environment.soundClient.play(.segment).fireAndForget() }
                    .eraseToEffect()
            }
            
            return .none
        },
        quickExerciseBuilderReducer.pullback(
            state: \.circuitPickerState,
            action: /QuickTimerAction.circuitPickerUpdatedValues,
            environment: { env in QuickExerciseBuilderEnvironment(uuid: env.uuid) }
        ),
        quickTimerControlsReducer.pullback(
            state: \.timerControlsState,
            action: /QuickTimerAction.timerControlsUpdatedState,
            environment: { _ in QuickTimerControlsEnvironment() }
        )
)

private extension QuickTimerState {
    mutating func calculateInitialTime() {
        totalTimeLeft = segments.map { $0.duration }.reduce(0, +)
        segmentTimeLeft = currentSegment?.duration ?? 0
    }
    
    mutating func moveToNextSegment() {
        guard let segment = currentSegment, let index = segments.firstIndex(of: segment), index != segments.count - 1 else { return }
        currentSegment = segments[index + 1]
        segmentTimeLeft = currentSegment?.duration ?? 0
    }
    
    mutating func updateSegments() {
        currentSegment = segments.first
        calculateInitialTime()
    }
    
    mutating func reset() {
        self = QuickTimerState()
        currentSegment = segments.first
        calculateInitialTime()
    }
    
    mutating func hidePickers() {
        circuitPickerState.setsState.isShowingPicker = false
        circuitPickerState.breakTimeState.isShowingPicker = false
        circuitPickerState.workoutTimeState.isShowingPicker = false
    }
    
    mutating func togglePickersInteraction(disabled: Bool) {
        circuitPickerState.setsState.isInteractionDisabled = disabled
        circuitPickerState.breakTimeState.isInteractionDisabled = disabled
        circuitPickerState.workoutTimeState.isInteractionDisabled = disabled
    }
    
    var isCurrentSegmentLast: Bool {
        guard let segment = currentSegment, let index = segments.firstIndex(of: segment) else { return true }
        return index == segments.count - 1
    }
}

private extension QuickExerciseBuilderState {
    init(state: QuickExerciseBuilderState) {
        self.init(sets: state.setsState.value, workoutTime: state.workoutTimeState.value, breakTime: state.breakTimeState.value)
    }
}
