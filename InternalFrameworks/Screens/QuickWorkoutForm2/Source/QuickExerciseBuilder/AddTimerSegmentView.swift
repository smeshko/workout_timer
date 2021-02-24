import SwiftUI
import DomainEntities
import ComposableArchitecture
import CoreInterface

struct AddTimerSegmentView: View {
    private let store: Store<AddTimerSegmentState, AddTimerSegmentAction>
    private let tint: Color

    fileprivate struct State: Equatable {
        var name: String
        var isEditing = false
    }

    init(store: Store<AddTimerSegmentState, AddTimerSegmentAction>, tint: Color) {
        self.store = store
        self.tint = tint
    }

    var body: some View {
        WithViewStore(store.scope(state: \.view)) { viewStore in
            NavigationView {
                VStack(spacing: Spacing.xxl) {
                    TextField("round_name_placeholder".localized, text: viewStore.binding(get: \.name, send: AddTimerSegmentAction.updateName))
                        .padding(Spacing.s)
                        .border(stroke: tint)

                    HStack(alignment: .bottom, spacing: Spacing.l) {
                        ValuePicker(store: store.scope(state: \.setsState, action: AddTimerSegmentAction.changeSetsCount),
                                    valueName: "sets_value_picker".localized, valuePostfix: nil, tint: .orange
                        )

                        ValuePicker(store: store.scope(state: \.workoutTimeState, action: AddTimerSegmentAction.changeWorkoutTime),
                                    valueName: "duration_value_picker".localized, valuePostfix: "s", tint: .blue
                        )

                        ValuePicker(store: store.scope(state: \.breakTimeState, action: AddTimerSegmentAction.changeBreakTime),
                                    valueName: "rest_value_picker".localized, valuePostfix: "s", tint: .red
                        )
                    }
                    Spacer()
                }
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button(key: viewStore.isEditing ? "done" : "add") {
                            viewStore.send(viewStore.isEditing ? .done : .add)
                        }
                    }

                    ToolbarItem(placement: viewStore.isEditing ? .navigationBarLeading : .cancellationAction) {
                            if viewStore.isEditing {
                                HStack {
                                    Image(systemName: "trash")
                                    Text(key: "delete")
                                        .bold()
                                }
                                .font(.bodyRegular)
                                .foregroundColor(.red)
                                .onTapGesture {
                                    viewStore.send(.remove)
                                }
                            } else {
                                Button(action: {
                                    viewStore.send(.cancel)
                                }, label: {
                                    Text(key: "cancel")
                                })

                            }
                        }
                }
                .navigationTitle(viewStore.name.isEmpty ? "unnamed_round".localized : viewStore.name)
                .padding(Spacing.xxl)
            }
            .navigationViewStyle(StackNavigationViewStyle())
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

private extension AddTimerSegmentState {
    var view: AddTimerSegmentView.State {
        AddTimerSegmentView.State(
            name: name,
            isEditing: isEditing
        )
    }
}
