import SwiftUI
import ComposableArchitecture

struct ValuePicker: View {

    let store: Store<PickerState, PickerAction>
    let valueName: String
    let tint: Color

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(alignment: .leading) {
                TextField(valueName, text: viewStore.binding(get: \.value, send: PickerAction.valueUpdated))
                    .font(.h2)
                    .keyboardType(.numberPad)

                Text(valueName)
                    .foregroundColor(tint)
                    .font(.label)
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
            tint: .orange
        )
    }
}
