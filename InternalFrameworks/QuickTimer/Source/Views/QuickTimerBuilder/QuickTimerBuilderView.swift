import SwiftUI
import ComposableArchitecture

struct QuickTimerBuilderView: View {
  
  let store: Store<QuickTimerBuilderState, QuickTimerBuilderAction>
  
  var body: some View {
    WithViewStore(store) { viewStore in
      VStack(spacing: 16) {
        ValuePicker(store: self.store.scope(state: \.setsState, action: QuickTimerBuilderAction.changeSetsCount),
                    valueName: "Sets",
                    maxValue: 21,
                    tint: .orange
        )
        
        ValuePicker(store: self.store.scope(state: \.workoutTimeState, action: QuickTimerBuilderAction.changeWorkoutTime),
                    valueName: "Workout Time",
                    maxValue: 121,
                    tint: .red
        )
        
        ValuePicker(store: self.store.scope(state: \.breakTimeState, action: QuickTimerBuilderAction.changeBreakTime),
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
    QuickTimerBuilderView(
      store: Store<QuickTimerBuilderState, QuickTimerBuilderAction>(
        initialState: QuickTimerBuilderState(),
        reducer: quickTimerBuilderReducer,
        environment: QuickTimerBuilderEnvironment()
      )
    )
  }
}
