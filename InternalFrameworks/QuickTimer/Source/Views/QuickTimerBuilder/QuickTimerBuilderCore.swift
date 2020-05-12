import ComposableArchitecture
import WorkoutCore

public enum QuickTimerBuilderAction: Equatable {
  case changeSetsCount(PickerAction)
  case changeBreakTime(PickerAction)
  case changeWorkoutTime(PickerAction)
  
  case updatedSegments([Segment])
  case setNavigation
}

public struct QuickTimerBuilderState: Equatable {
  
  var setsState = PickerState()
  var workoutTimeState = PickerState()
  var breakTimeState = PickerState()
  var segments: [Segment] = []

  fileprivate var sets: Int { setsState.value }
  fileprivate var workoutTime: Int { workoutTimeState.value }
  fileprivate var breakTime: Int { breakTimeState.value }

  public init() {}
  public init(sets: Int, workoutTime: Int, breakTime: Int) {
    setsState = PickerState(value: sets)
    workoutTimeState = PickerState(value: workoutTime)
    breakTimeState = PickerState(value: breakTime)
  }
}

public struct QuickTimerBuilderEnvironment: Equatable {}

public let quickTimerBuilderReducer =
  Reducer<QuickTimerBuilderState, QuickTimerBuilderAction, QuickTimerBuilderEnvironment>.combine(
    Reducer { state, action, _ in
      
      switch action {
      case .setNavigation:
        state.createSegments()
        return Effect(value: .updatedSegments(state.segments))
        
      case .changeSetsCount(let action):
        switch action {
        case .valueUpdated(let value):
          state.setsState.value = value
          state.createSegments()
          return Effect(value: .updatedSegments(state.segments))
          
        case .togglePickerVisibility:
          state.breakTimeState.hidePickerIfNeeded()
          state.workoutTimeState.hidePickerIfNeeded()
        }
        
      case .changeBreakTime(let action):
        switch action {
        case .valueUpdated(let value):
          state.breakTimeState.value = value
          state.createSegments()
          return Effect(value: .updatedSegments(state.segments))
          
        case .togglePickerVisibility:
          state.setsState.hidePickerIfNeeded()
          state.workoutTimeState.hidePickerIfNeeded()
        }
        
      case .changeWorkoutTime(let action):
        switch action {
        case .valueUpdated(let value):
          state.workoutTimeState.value = value
          state.createSegments()
          return Effect(value: .updatedSegments(state.segments))
          
        case .togglePickerVisibility:
          state.setsState.hidePickerIfNeeded()
          state.breakTimeState.hidePickerIfNeeded()
        }
        
      case .updatedSegments: break
      }
      
      return .none
    },
    pickerReducer.pullback(
      state: \.setsState,
      action: /QuickTimerBuilderAction.changeSetsCount,
      environment: { _ in PickerEnvironment() }
    ),
    pickerReducer.pullback(
      state: \.workoutTimeState,
      action: /QuickTimerBuilderAction.changeWorkoutTime,
      environment: { _ in PickerEnvironment() }
    ),
    pickerReducer.pullback(
      state: \.breakTimeState,
      action: /QuickTimerBuilderAction.changeBreakTime,
      environment: { _ in PickerEnvironment() }
    )
)

private extension QuickTimerBuilderState {
  
  mutating func createSegments() {
    segments = []
    
    (0 ..< sets).enumerated().forEach { index, _ in
      segments.append(Segment(duration: workoutTime, category: .workout))
      if index != sets - 1 {
        segments.append(Segment(duration: breakTime, category: .pause))
      }
    }
  }
  
}

private extension PickerState {
  mutating func hidePickerIfNeeded() {
    if isShowingPicker { isShowingPicker = false }
  }
}