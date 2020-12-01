import SwiftUI
import ComposableArchitecture
import CoreInterface

struct ValuePicker: View {

    let store: Store<PickerState, PickerAction>
    let valueName: String

    private let tint: Color
    private let shouldUseScrollView: Bool = false

    public init(store: Store<PickerState, PickerAction>, valueName: String, tint: Color) {
        self.tint = tint
        self.store = store
        self.valueName = valueName
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(alignment: .leading, spacing: 8) {
// If I remove this line, the app crashes with
//                2020-12-01 08:57:21.285684+0100 Quick Workouts[776:122312] [error] precondition failure:
//                attribute failed to set an initial value: 856600, ForEachChild<IdentifiedArray<UUID, AddTimerSegmentState>, UUID, ModifiedContent<AddTimerSegmentView, _PaddingLayout>>
//                AttributeGraph precondition failure: attribute failed to set an initial value: 856600,
//                ForEachChild<IdentifiedArray<UUID, AddTimerSegmentState>, UUID, ModifiedContent<AddTimerSegmentView, _PaddingLayout>>.
// It would be nice to find out why some day. 
                if shouldUseScrollView {}
                VStack {
                    Picker("", selection: viewStore.binding(get: \.value, send: PickerAction.valueUpdated)) {
                        ForEach(viewStore.allNumbers, id: \.self) { number in
                            Text("\(number)")
                                .font(viewStore.value == number ? .h2 : .h3)
                                .foregroundColor(viewStore.value == number ? tint : .appGrey)
                        }
                    }
                    .frame(width: 60, height: 60)
                    .clipped()
                }
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(tint, lineWidth: 2))

                Text(valueName)
                    .foregroundColor(tint)
                    .font(.label)
            }
        }
    }
}

struct ValuePicker_Previews: PreviewProvider {
    static var previews: some View {

        let store = Store<PickerState, PickerAction>(
            initialState: PickerState(),
            reducer: pickerReducer,
            environment: PickerEnvironment()
        )

        return Group {
            ValuePicker(store: store, valueName: "Sets", tint: .appSuccess)
                .padding()
                .previewLayout(.sizeThatFits)

            ValuePicker(store: store, valueName: "Sets", tint: .appSuccess)
                .preferredColorScheme(.dark)
                .padding()
                .previewLayout(.sizeThatFits)
        }
    }
}
