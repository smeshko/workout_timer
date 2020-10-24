import SwiftUI
import ComposableArchitecture
import WorkoutCore

struct AddTimerSegmentView: View {    
    let store: Store<AddTimerSegmentState, AddTimerSegmentAction>

    @State var text = ""
    
    var body: some View {
        WithViewStore(store) { viewStore in
            HStack {
                ValuePicker(store: self.store.scope(state: \.setsState, action: AddTimerSegmentAction.changeSetsCount),
                            valueName: "Sets",
                            tint: .orange
                )

                ValuePicker(store: self.store.scope(state: \.workoutTimeState, action: AddTimerSegmentAction.changeWorkoutTime),
                            valueName: "Work",
                            tint: .red
                )

                ValuePicker(store: self.store.scope(state: \.breakTimeState, action: AddTimerSegmentAction.changeBreakTime),
                            valueName: "Break",
                            tint: .purple
                )

                Button(action: {
//                    viewStore.send(.timerFinished)
//                    self.presentationMode.wrappedValue.dismiss()
                }, label: {
                    Image(systemName: "plus")
                        .frame(width: 18, height: 18)
                        .padding(10)
                        .foregroundColor(.appWhite)
                })
                .background(Color.appSuccess)
                .cornerRadius(12)
            }
            .padding(.horizontal, 28)
            .onAppear {
                viewStore.send(.setNavigation)
            }
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
                initialState: AddTimerSegmentState(sets: 5, workoutTime: 30, breakTime: 30),
                reducer: addTimerSegmentReducer,
                environment: AddTimerSegmentEnvironment(uuid: UUID.init)
            )
        )
    }
}
