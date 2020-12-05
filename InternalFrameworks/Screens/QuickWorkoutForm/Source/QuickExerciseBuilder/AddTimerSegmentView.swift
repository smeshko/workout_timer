import SwiftUI
import DomainEntities
import ComposableArchitecture
import CoreInterface

struct AddTimerSegmentView: View {
    @Environment(\.colorScheme) var colorScheme

    let store: Store<AddTimerSegmentState, AddTimerSegmentAction>
    let tint: Color

    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                Color.black
                    .opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        viewStore.send(.cancel)
                    }

                VStack(spacing: Spacing.xxl) {
                    VStack(alignment: .leading, spacing: Spacing.none) {
                        TextField("interval name", text: viewStore.binding(get: \.name, send: AddTimerSegmentAction.updateName))
                            .padding(.horizontal, Spacing.xxl)
                            .padding(.top, Spacing.xxl)
                        Rectangle()
                            .foregroundColor(tint)
                            .frame(height: 2)
                            .padding(.horizontal, Spacing.xl)
                    }

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

                    HStack(spacing: Spacing.none) {
                        Button(action: {
                            withAnimation {
                                viewStore.send(viewStore.isEditing ? .remove : .cancel)
                            }
                        }, label: {
                            Text(viewStore.isEditing ? "Delete" : "Cancel")
                                .font(.bodyLarge)
                                .fullWidth()
                                .frame(height: 44)
                                .foregroundColor(.appWhite)
                        })
                        .background(Color.red)

                        Button(action: {
                            withAnimation {
                                viewStore.send(viewStore.isEditing ? .done : .add)
                            }
                        }, label: {
                            Text(viewStore.isEditing ? "Done" : "Add")
                                .font(.bodyLarge)
                                .fullWidth()
                                .frame(height: 44)
                                .foregroundColor(.appWhite)
                        })
                        .background(tint)
                    }
                }
                .background(Color.appCardBackground)
                .cornerRadius(CornerRadius.m)
                .padding(Spacing.xxl)
            }
        }
    }
}

struct CircuitPickerView_Previews: PreviewProvider {
    static var previews: some View {
        let editingStore = Store<AddTimerSegmentState, AddTimerSegmentAction>(
            initialState: AddTimerSegmentState(id: UUID(), name: "Interval", sets: 5, workoutTime: 30, breakTime: 30, isEditing: true),
            reducer: addTimerSegmentReducer,
            environment: AddTimerSegmentEnvironment(uuid: UUID.init)
        )

        let creatingStore = Store<AddTimerSegmentState, AddTimerSegmentAction>(
            initialState: AddTimerSegmentState(id: UUID(), name: "Interval", sets: 5, workoutTime: 30, breakTime: 30, isEditing: false),
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

private extension WorkoutColor {
    func monochromatic(for scheme: ColorScheme) -> WorkoutColor {
        let brightnessModifier = scheme == .dark ? 0.3 : -0.3
        return WorkoutColor(hue: hue,
                            saturation: saturation + 0.2,
                            brightness: brightness + brightnessModifier)
    }
}
