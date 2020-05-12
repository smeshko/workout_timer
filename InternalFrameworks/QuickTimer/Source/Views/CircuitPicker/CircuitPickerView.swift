import SwiftUI
import ComposableArchitecture

struct CircuitPickerView: View {
  
  let store: Store<CircuitPickerState, CircuitPickerAction>
  
  var body: some View {
    WithViewStore(store) { viewStore in
      VStack(spacing: 16) {
        ValuePicker(store: self.store.scope(state: \.setsState, action: CircuitPickerAction.changeSetsCount),
                    valueName: "Sets",
                    maxValue: 21,
                    tint: .orange
        )
        
        ValuePicker(store: self.store.scope(state: \.workoutTimeState, action: CircuitPickerAction.changeWorkoutTime),
                    valueName: "Workout Time",
                    maxValue: 121,
                    tint: .red
        )
        
        ValuePicker(store: self.store.scope(state: \.breakTimeState, action: CircuitPickerAction.changeBreakTime),
                    valueName: "Break Time",
                    maxValue: 61,
                    tint: .purple
        )
      }
      .onAppear {
        viewStore.send(.setNavigation)
      }
    }
  }
}

struct CircuitPickerView_Previews: PreviewProvider {
  static var previews: some View {
    CircuitPickerView(
      store: Store<CircuitPickerState, CircuitPickerAction>(
        initialState: CircuitPickerState(),
        reducer: circuitPickerReducer,
        environment: CircuitPickerEnvironment()
      )
    )
  }
}
