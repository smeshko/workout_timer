import SwiftUI
import ComposableArchitecture
import CoreInterface

struct AddTimerSegmentView: View {    
    let store: Store<AddTimerSegmentState, AddTimerSegmentAction>

    let color: Color
    
    var body: some View {
        WithViewStore(store) { viewStore in
            HStack {
                ValuePicker(store: self.store.scope(state: \.setsState, action: AddTimerSegmentAction.changeSetsCount),
                            valueName: "Sets",
                            tint: .orange
                )
                .disabled(viewStore.isAdded)

                ValuePicker(store: self.store.scope(state: \.workoutTimeState, action: AddTimerSegmentAction.changeWorkoutTime),
                            valueName: "Work",
                            tint: .red
                )
                .disabled(viewStore.isAdded)

                ValuePicker(store: self.store.scope(state: \.breakTimeState, action: AddTimerSegmentAction.changeBreakTime),
                            valueName: "Break",
                            tint: .purple
                )
                .disabled(viewStore.isAdded)

                Button(action: {
                    withAnimation {
                        viewStore.send(viewStore.isAdded ? .removeSegments : .addSegments)
                    }
                }, label: {
                    Image(systemName: viewStore.isAdded ? "trash" : "plus")
                        .frame(width: 18, height: 18)
                        .padding(10)
                        .foregroundColor(.appWhite)
                })
                .background(viewStore.isAdded ? Color.red : color)
                .cornerRadius(12)
            }
            .padding(.horizontal, 28)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 18)
        .background(Color.appCardBackground)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(color, lineWidth: 1))
    }
}

struct CircuitPickerView_Previews: PreviewProvider {
    static var previews: some View {
        let store = Store<AddTimerSegmentState, AddTimerSegmentAction>(
            initialState: AddTimerSegmentState(id: UUID(), sets: 5, workoutTime: 30, breakTime: 30),
            reducer: addTimerSegmentReducer,
            environment: AddTimerSegmentEnvironment(uuid: UUID.init)
        )

        return Group {
            AddTimerSegmentView(store: store, color: .appSuccess)
                .padding()
                .previewLayout(.sizeThatFits)

            AddTimerSegmentView(store: store, color: .appSuccess)
                .padding()
                .preferredColorScheme(.dark)
                .previewLayout(.sizeThatFits)
        }
    }
}