import SwiftUI
import DomainEntities
import ComposableArchitecture
import CoreInterface

struct AddTimerSegmentView: View {
    private let store: Store<AddTimerSegmentState, AddTimerSegmentAction>
    private let tint: Color

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    init(store: Store<AddTimerSegmentState, AddTimerSegmentAction>, tint: Color) {
        self.store = store
        self.tint = tint
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                VStack(spacing: Spacing.xxl) {
                    TextField("round name", text: viewStore.binding(get: \.name, send: AddTimerSegmentAction.updateName))
                        .padding(Spacing.s)
                        .border(stroke: tint)

                    HStack(alignment: .bottom, spacing: Spacing.l) {
                        ValuePicker(store: store.scope(state: \.setsState, action: AddTimerSegmentAction.changeSetsCount),
                                    valueName: "sets", valuePostfix: nil, tint: .orange
                        )

                        ValuePicker(store: store.scope(state: \.workoutTimeState, action: AddTimerSegmentAction.changeWorkoutTime),
                                    valueName: "duration/set", valuePostfix: "s", tint: .blue
                        )

                        ValuePicker(store: store.scope(state: \.breakTimeState, action: AddTimerSegmentAction.changeBreakTime),
                                    valueName: "rest in between", valuePostfix: "s", tint: .red
                        )
                    }
                    Spacer()
                }
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button(viewStore.isEditing ? "Done" : "Add", action: {
                            presentationMode.wrappedValue.dismiss()
                            viewStore.send(viewStore.isEditing ? .done : .add)
                        })
                    }

                    ToolbarItem(placement: viewStore.isEditing ? .navigationBarLeading : .cancellationAction) {
                            if viewStore.isEditing {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                                    .onTapGesture {
                                        presentationMode.wrappedValue.dismiss()
                                        viewStore.send(.remove)
                                    }
                            } else {
                                Button(action: {
                                    presentationMode.wrappedValue.dismiss()
                                    viewStore.send(.cancel)
                                }, label: {
                                    Text("Cancel")
                                })

                            }
                        }
                }
                .navigationTitle(viewStore.name.isEmpty ? "Unnamed round" : viewStore.name)
                .padding(Spacing.xxl)
            }
        }
    }
}

struct CircuitPickerView_Previews: PreviewProvider {
    static var previews: some View {
        let editingStore = Store<AddTimerSegmentState, AddTimerSegmentAction>(
            initialState: AddTimerSegmentState(id: UUID(), name: "Round 1", sets: 5, workoutTime: 30, breakTime: 30, isEditing: true),
            reducer: addTimerSegmentReducer,
            environment: AddTimerSegmentEnvironment(uuid: UUID.init)
        )

        let creatingStore = Store<AddTimerSegmentState, AddTimerSegmentAction>(
            initialState: AddTimerSegmentState(id: UUID(), name: "Round 1", sets: 5, workoutTime: 30, breakTime: 30, isEditing: false),
            reducer: addTimerSegmentReducer,
            environment: AddTimerSegmentEnvironment(uuid: UUID.init)
        )

        return Group {
            AddTimerSegmentView(store: editingStore, tint: .green)
                .padding()
                .previewLayout(.sizeThatFits)

            AddTimerSegmentView(store: creatingStore, tint: .blue)
                .padding()
                .preferredColorScheme(.dark)
                .previewLayout(.sizeThatFits)
        }
    }
}
