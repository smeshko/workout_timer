import ComposableArchitecture
import Foundation

public enum TimerAction: Equatable {
  case timerTicked
  case segmentEnded
  case timerFinished
  case setNavigation
  case setCircuitComposerSheet(isPresented: Bool)
  
  case circuitComposerUpdated(CircuitComposerAction)
  case timerControlsUpdatedState(TimerControlsAction)
  case circuitPickerUpdatedValues(CircuitPickerAction)
}

public struct TimerState: Equatable {
  var isRunning: Bool { timerControlsState.isRunning }
  var segments: [Segment] = []
  var currentSegment: Segment? = nil
  var totalTimeLeft: Int = 0
  var segmentTimeLeft: Int = 0
  var isPresentingCircuitComposer: Bool = false
  
  var circuitComposerState: CircuitComposerState
  var timerControlsState: TimerControlsState
  var circuitPickerState: CircuitPickerState
  
  public init(segments: [Segment] = [],
              currentSegment: Segment? = nil,
              totalTimeLeft: Int = 0,
              segmentTimeLeft: Int = 0,
              isPresentingCircuitComposer: Bool = false,
              circuitComposerState: CircuitComposerState = CircuitComposerState(),
              circuitPickerState: CircuitPickerState = CircuitPickerState(sets: 2, workoutTime: 60, breakTime: 20),
              timerControlsState: TimerControlsState = TimerControlsState()) {
    self.segments = segments
    self.currentSegment = currentSegment
    self.circuitPickerState = circuitPickerState
    self.totalTimeLeft = totalTimeLeft
    self.segmentTimeLeft = segmentTimeLeft
    self.isPresentingCircuitComposer = isPresentingCircuitComposer
    self.timerControlsState = timerControlsState
    self.circuitComposerState = circuitComposerState
  }
}

public struct TimerEnvironment {
  var mainQueue: AnySchedulerOf<DispatchQueue>
  var soundClient: SoundClient
  
  public init(
    mainQueue: AnySchedulerOf<DispatchQueue>,
    soundClient: SoundClient
  ) {
    self.mainQueue = mainQueue
    self.soundClient = soundClient
  }
}

public let timerReducer =
  Reducer<TimerState, TimerAction, TimerEnvironment>.combine(
    Reducer { state, action, environment in
      struct TimerId: Hashable {}
      
      switch action {

      case .setNavigation:
        state.updateSegments()

      case .setCircuitComposerSheet(let isPresented):
        state.isPresentingCircuitComposer = isPresented

      case .timerControlsUpdatedState(let controlsAction):
        switch controlsAction {
          case .pause:
            return Effect<TimerAction, Never>.cancel(id: TimerId())
            
          case .stop:
            return Effect(value: TimerAction.timerFinished)
            
          case .start:
            state.hidePickers()
            state.togglePickersInteraction(disabled: true)
            // timer has been previously stopped (as opposed to paused)
            if state.currentSegment == nil {
              state.updateSegments()
            }
            return Effect
              .timer(id: TimerId(), every: 1, tolerance: .zero, on: environment.mainQueue)
              .map { _ in TimerAction.timerTicked }
        }

      case .circuitPickerUpdatedValues(let circuitPickerAction):
        switch circuitPickerAction {
        case .updatedSegments(let segments):
          state.segments = segments
          state.updateSegments()
        default: break
        }

      case .circuitComposerUpdated(let circuitComposerAction):
        switch circuitComposerAction {
        case .doneButtonTapped:
          state.segments = state.circuitComposerState.segments
          state.updateSegments()
          state.circuitPickerState.setsState.value = state.circuitComposerState.circuitPickerState.setsState.value
          return Effect(value: TimerAction.setCircuitComposerSheet(isPresented: false))
        default: break
        }
        
      case .timerTicked:
        state.totalTimeLeft -= 1
        state.segmentTimeLeft -= 1
        
        if state.totalTimeLeft <= 0 {
          return Effect(value: TimerAction.timerFinished)
        }
        
        if state.segmentTimeLeft == 0, !state.isCurrentSegmentLast {
          return Effect(value: TimerAction.segmentEnded)
        }
        
      case .segmentEnded:
        state.moveToNextSegment()
        return environment
          .soundClient.play(.segment)
          .fireAndForget()
        
      case .timerFinished:
        state.reset()
        return Effect<TimerAction, Never>
          .cancel(id: TimerId())
          .flatMap { _ in environment.soundClient.play(.segment).fireAndForget() }
          .eraseToEffect()
      }
      
      return .none
  },
    circuitPickerReducer.pullback(
      state: \.circuitPickerState,
      action: /TimerAction.circuitPickerUpdatedValues,
      environment: { _ in CircuitPickerEnvironment() }
    ),
    timerControlsReducer.pullback(
      state: \.timerControlsState,
      action: /TimerAction.timerControlsUpdatedState,
      environment: { _ in TimerControlsEnvironment() }
    ),
    circuitComposerReducer.pullback(
      state: \.circuitComposerState,
      action: /TimerAction.circuitComposerUpdated,
      environment: { _ in CircuitComposerEnvironment() }
    )
)

private extension TimerState {
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
    self = TimerState()
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

private extension CircuitPickerState {
  init(state: CircuitPickerState) {
    self.init(sets: state.setsState.value, workoutTime: state.workoutTimeState.value, breakTime: state.breakTimeState.value)
  }
}
