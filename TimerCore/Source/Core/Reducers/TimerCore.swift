import ComposableArchitecture
import Foundation
import Combine

public enum TimerAction: Equatable {
  case start(new: Bool)
  case stop
  case pause
  case timerTicked
  case segmentEnded
  case timerFinished
  case setNavigation
  case changeSetsCount(PickerAction)
  case changeBreakTime(PickerAction)
  case changeWorkoutTime(PickerAction)
}

public struct TimerState: Equatable {
  var isRunning: Bool = false
  var segments: [Segment] = []
  var currentSegment: Segment? = nil
  var sets = PickerState()
  var workoutTime = PickerState()
  var breakTime = PickerState()
  var totalTimeLeft: Int = 0
  var segmentTimeLeft: Int = 0
  
  public init(isRunning: Bool = false,
              segments: [Segment] = [],
              currentSegment: Segment? = nil,
              sets: PickerState = PickerState(value: 2),
              workoutTime: PickerState = PickerState(value: 60),
              breakTime: PickerState = PickerState(value: 20),
              totalTimeLeft: Int = 0,
              segmentTimeLeft: Int = 0) {
    self.isRunning = isRunning
    self.segments = segments
    self.currentSegment = currentSegment
    self.sets = sets
    self.workoutTime = workoutTime
    self.breakTime = breakTime
    self.totalTimeLeft = totalTimeLeft
    self.segmentTimeLeft = segmentTimeLeft
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
        state.createSegments()
        state.currentSegment = state.segments.first
        state.calculateInitialTime()
        
      case .pause:
        state.isRunning = false
        return Effect<TimerAction, Never>.cancel(id: TimerId())
        
      case .stop:
        return Effect(value: TimerAction.timerFinished)
        
      case .start(let new):
        state.isRunning = true
        state.hidePickers()
        state.togglePickersInteraction(disabled: true)
        if new {
          state.createSegments()
          state.currentSegment = state.segments.first
          state.calculateInitialTime()
        }
        return Effect
          .timer(id: TimerId(), every: 1, tolerance: .zero, on: environment.mainQueue)
          .map { _ in TimerAction.timerTicked }
        
      case .changeSetsCount(let action):
        switch action {
        case .valueUpdated(let value):
          state.sets.value = value
          state.calculateInitialTime()
        case .togglePickerVisibility:
          state.breakTime.hidePickerIfNeeded()
          state.workoutTime.hidePickerIfNeeded()
        }
        
      case .changeBreakTime(let action):
        switch action {
        case .valueUpdated(let value):
          state.breakTime.value = value
          state.calculateInitialTime()
        case .togglePickerVisibility:
          state.sets.hidePickerIfNeeded()
          state.workoutTime.hidePickerIfNeeded()
        }
        
      case .changeWorkoutTime(let action):
        switch action {
        case .valueUpdated(let value):
          state.workoutTime.value = value
          state.calculateInitialTime()
        case .togglePickerVisibility:
          state.sets.hidePickerIfNeeded()
          state.breakTime.hidePickerIfNeeded()
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
        return Effect<TimerAction, Never>.cancel(id: TimerId())
      }
      
      return .none
  },
    pickerReducer.pullback(
      state: \.sets,
      action: /TimerAction.changeSetsCount,
      environment: { _ in PickerEnvironment() }
    ),
    pickerReducer.pullback(
      state: \.workoutTime,
      action: /TimerAction.changeWorkoutTime,
      environment: { _ in PickerEnvironment() }
    ),
    pickerReducer.pullback(
      state: \.breakTime,
      action: /TimerAction.changeBreakTime,
      environment: { _ in PickerEnvironment() }
    )
)

private extension TimerState {
  mutating func calculateInitialTime() {
    totalTimeLeft = sets.value * workoutTime.value + (sets.value - 1) * breakTime.value
    segmentTimeLeft = currentSegment?.duration ?? 0
  }
  
  mutating func moveToNextSegment() {
    guard let segment = currentSegment, let index = segments.firstIndex(of: segment), index != segments.count - 1 else { return }
    currentSegment = segments[index + 1]
    segmentTimeLeft = currentSegment?.duration ?? 0
  }
  
  mutating func createSegments() {
    segments = []
    
    (0 ..< sets.value).enumerated().forEach { index, _ in
      segments.append(Segment(duration: workoutTime.value, category: .workout))
      if index != sets.value - 1 {
        segments.append(Segment(duration: breakTime.value, category: .pause))
      }
    }
  }
  
  mutating func reset() {
    self = TimerState()
    createSegments()
    currentSegment = segments.first
    calculateInitialTime()
  }
  
  mutating func hidePickers() {
    sets.isShowingPicker = false
    breakTime.isShowingPicker = false
    workoutTime.isShowingPicker = false
  }
  
  mutating func togglePickersInteraction(disabled: Bool) {
    sets.isInteractionDisabled = disabled
    workoutTime.isInteractionDisabled = disabled
    breakTime.isInteractionDisabled = disabled
  }
  
  var isCurrentSegmentLast: Bool {
    guard let segment = currentSegment, let index = segments.firstIndex(of: segment) else { return true }
    return index == segments.count - 1
  }
}

private extension PickerState {
  mutating func hidePickerIfNeeded() {
    if isShowingPicker { isShowingPicker = false }
  }
}

extension TimerState {
  
  var formattedTotalTimeLeft: String {
    String(format: "%02d:%02d", totalTimeLeft / 60, totalTimeLeft % 60)
  }
  
  var formattedSegmentTimeLeft: String {
    String(format: "%02d:%02d", segmentTimeLeft / 60, segmentTimeLeft % 60)
  }
  
}
