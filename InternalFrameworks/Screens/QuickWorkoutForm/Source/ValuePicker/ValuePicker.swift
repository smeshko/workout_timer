import SwiftUI
import ComposableArchitecture
import CoreInterface

struct ValuePicker: View {

    let store: Store<PickerState, PickerAction>
    let valueName: String
    let valuePostfix: String?

    private let tint: Color
    private let shouldUseScrollView: Bool = false

    public init(store: Store<PickerState, PickerAction>, valueName: String, valuePostfix: String?, tint: Color) {
        self.tint = tint
        self.store = store
        self.valueName = valueName
        self.valuePostfix = valuePostfix
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(alignment: .center, spacing: Spacing.xs) {
// If I remove this line, the app crashes with
//                2020-12-01 08:57:21.285684+0100 Quick Workouts[776:122312] [error] precondition failure:
//                attribute failed to set an initial value: 856600, ForEachChild<IdentifiedArray<UUID, AddTimerSegmentState>, UUID, ModifiedContent<AddTimerSegmentView, _PaddingLayout>>
//                AttributeGraph precondition failure: attribute failed to set an initial value: 856600,
//                ForEachChild<IdentifiedArray<UUID, AddTimerSegmentState>, UUID, ModifiedContent<AddTimerSegmentView, _PaddingLayout>>.
// It would be nice to find out why some day. 
                if shouldUseScrollView {}

                Text(valueName)
                    .foregroundColor(tint)
                    .font(.label)

                VStack {
                    Picker("", selection: viewStore.binding(get: \.value, send: PickerAction.valueUpdated)) {
                        ForEach(viewStore.allNumbers, id: \.self) { number in
                            Text("\(number)" + "\(valuePostfix ?? "")")
                                .font(viewStore.value == number ? .h2 : .h3)
                                .foregroundColor(viewStore.value == number ? tint : .appGrey)
                        }
                    }
                    .frame(width: 60, height: 60)
                    .clipped()
                }
                .border(stroke: tint)
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
            ValuePicker(store: store, valueName: "Sets", valuePostfix: "sec", tint: .appSuccess)
                .padding()
                .previewLayout(.sizeThatFits)

            ValuePicker(store: store, valueName: "Sets", valuePostfix: "sec", tint: .appSuccess)
                .preferredColorScheme(.dark)
                .padding()
                .previewLayout(.sizeThatFits)
        }
    }
}
