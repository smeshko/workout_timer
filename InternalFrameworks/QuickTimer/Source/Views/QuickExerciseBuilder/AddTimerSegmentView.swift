import SwiftUI
import ComposableArchitecture
import WorkoutCore

struct AddTimerSegmentView: View {    
    let store: Store<AddTimerSegmentState, AddTimerSegmentAction>
    
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
                .background(Color.appSuccess)
                .cornerRadius(12)
            }
            .padding(.horizontal, 28)
//            .gesture(
//                DragGesture()
//                    .onChanged { _ in
//                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
//                    }
//            )
//            .onTapGesture {
//                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
//            }
        }
    }
}

struct CircuitPickerView_Previews: PreviewProvider {
    static var previews: some View {
        AddTimerSegmentView(
            store: Store<AddTimerSegmentState, AddTimerSegmentAction>(
                initialState: AddTimerSegmentState(id: UUID(), sets: 5, workoutTime: 30, breakTime: 30),
                reducer: addTimerSegmentReducer,
                environment: AddTimerSegmentEnvironment(uuid: UUID.init)
            )
        )
    }
}
