import SwiftUI
import ComposableArchitecture

struct CircuitComposerView: View {
  
  let store: Store<CircuitComposerState, CircuitComposerAction>
  
  var body: some View {
    NavigationView {
      WithViewStore(store) { viewStore in
        ScrollView {
          ForEach(viewStore.segments, id: \.self) { segment in
            Text(segment.description)
              .padding()
          }
          if viewStore.isCircuitPickerVisible {
            VStack(spacing: 16) {
              QuickExerciseBuilderView(store: self.store.scope(state: \.circuitPickerState, action: CircuitComposerAction.circuitPickerUpdatedValues))
              
              Button("Done") {
                viewStore.send(.finishedCircuitButtonTapped)
              }
            }
          }
        }
        .navigationBarTitle("Circuit composer")
        .navigationBarItems(trailing:
          HStack(spacing: 16) {
            Button("Add") { viewStore.send(.addAnotherCircuitButtonTapped) }
            Button("Done") { viewStore.send(.doneButtonTapped) }
        })
      }
    }
  }
}

struct CircuitComposerView_Previews: PreviewProvider {
  static var previews: some View {
    CircuitComposerView(
      store: Store<CircuitComposerState, CircuitComposerAction>(
        initialState: CircuitComposerState(isCircuitPickerVisible: true),
        reducer: circuitComposerReducer,
        environment: CircuitComposerEnvironment()
      )
    )
  }
}
