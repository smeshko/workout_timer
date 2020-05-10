import ComposableArchitecture


public enum CircuitComposerAction: Equatable {
  
}

public struct CircuitComposerState: Equatable {
  var segments: [Segment] = []
  
}

public struct CircuitComposerEnvironment: Equatable {
  
}

public let circuitComposerReducer = Reducer<CircuitComposerState, CircuitComposerAction, CircuitComposerEnvironment> { state, action, _ in
  
  
  
  return .none
}
