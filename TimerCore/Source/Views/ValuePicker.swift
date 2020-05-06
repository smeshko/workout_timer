import SwiftUI
import ComposableArchitecture

struct ValuePicker: View {
  
  let store: Store<PickerState, PickerAction>
  let valueName: String
  let maxValue: Int
  let tint: Color
  
  var body: some View {
    WithViewStore(store) { viewStore in
      VStack(alignment: .center, spacing: 0) {
        Button(action: {
          viewStore.send(.togglePickerVisibility)
        }) {
          VStack {
            Text("\(viewStore.value)")
              .font(Font.system(size: 22, weight: .bold))
              .foregroundColor(self.tint)
            Text(self.valueName)
          }
          .foregroundColor(.primary)
        }
        if viewStore.isShowingPicker {
          Picker(selection: viewStore.binding(get: \.value, send: PickerAction.valueUpdated), label: Text("")) {
            ForEach(0 ..< self.maxValue) { index in
              Text("\(index)")
            }
          }
          .labelsHidden()
          .onTapGesture {
            viewStore.send(.togglePickerVisibility)
          }
        }
      }
    }
  }
}

struct ValuePicker_Previews: PreviewProvider {
  static var previews: some View {
    ValuePicker(
      store: Store<PickerState, PickerAction>(
        initialState: PickerState(),
        reducer: pickerReducer,
        environment: PickerEnvironment()
      ),
      valueName: "Sets",
      maxValue: 20,
      tint: .orange
    )
  }
}
