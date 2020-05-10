import SwiftUI
import ComposableArchitecture

struct CircuitComposerView: View {
    
  let store: Store<CircuitComposerState, CircuitComposerAction>
  
  private let segments = ["3x60", "2x15", "10x40"]
  
  var body: some View {
    WithViewStore(store) { viewStore in
      ScrollView {
        ForEach(self.segments, id: \.self) { segment in
          Text(segment)
            .padding()
        }
        
        Button(action: {}) {
          Image(systemName: "plus")
            .font(.system(size: 24))
        }
      }
      
    }
  }
}

struct CircuitComposerView_Previews: PreviewProvider {
  static var previews: some View {
    CircuitComposerView(
      store: Store<CircuitComposerState, CircuitComposerAction>(
        initialState: CircuitComposerState(),
        reducer: circuitComposerReducer,
        environment: CircuitComposerEnvironment()
      )
    )
  }
}
