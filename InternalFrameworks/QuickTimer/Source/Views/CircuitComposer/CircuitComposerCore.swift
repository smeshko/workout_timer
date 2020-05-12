import ComposableArchitecture
import WorkoutCore

public enum CircuitComposerAction: Equatable {
  case finishedCircuitButtonTapped
  case addAnotherCircuitButtonTapped
  case doneButtonTapped
  
  case circuitPickerUpdatedValues(QuickTimerBuilderAction)
}

public struct CircuitComposerState: Equatable {
  var segments: [Segment] = []
  var isCircuitPickerVisible: Bool = true
  
  var circuitPickerState: QuickTimerBuilderState = QuickTimerBuilderState()
  
  public init(segments: [Segment] = [],
              isCircuitPickerVisible: Bool = true,
              circuitPickerState: QuickTimerBuilderState = QuickTimerBuilderState()) {
    self.segments = segments
    self.isCircuitPickerVisible = isCircuitPickerVisible
    self.circuitPickerState = circuitPickerState
  }
  
}

public struct CircuitComposerEnvironment: Equatable {}

public let circuitComposerReducer =
  Reducer<CircuitComposerState, CircuitComposerAction, CircuitComposerEnvironment>.combine(
    Reducer { state, action, _ in
      
      switch action {        
      case .finishedCircuitButtonTapped:
        state.segments.append(contentsOf: state.circuitPickerState.segments)
        state.isCircuitPickerVisible = false
        state.circuitPickerState = QuickTimerBuilderState()
        
      case .circuitPickerUpdatedValues(let pickerAction):
        switch pickerAction {
        case .updatedSegments(let segments): break
          
        default: break
        }

      case .addAnotherCircuitButtonTapped:
        state.isCircuitPickerVisible = true
        
      case .doneButtonTapped:
        break
      }
      
      
      return .none
    },
    quickTimerBuilderReducer.pullback(
      state: \.circuitPickerState,
      action: /CircuitComposerAction.circuitPickerUpdatedValues,
      environment: { _ in QuickTimerBuilderEnvironment() }
    )
)
