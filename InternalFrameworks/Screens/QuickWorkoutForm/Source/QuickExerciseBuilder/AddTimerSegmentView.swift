import SwiftUI
import DomainEntities
import ComposableArchitecture
import CoreInterface

struct AddTimerSegmentView: View {
    @Environment(\.colorScheme) var colorScheme

    let store: Store<AddTimerSegmentState, AddTimerSegmentAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                Color.black
                    .opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        viewStore.send(.cancel)
                    }

                VStack(spacing: 18) {
                    TextField("segment name", text: viewStore.binding(get: \.name, send: AddTimerSegmentAction.updateName))
                        .padding(.horizontal, 28)
                        .padding(.top, 28)

                    HStack(spacing: 18) {
                        ValuePicker(store: store.scope(state: \.setsState, action: AddTimerSegmentAction.changeSetsCount),
                                    valueName: "Sets",
                                    tint: .orange
                        )

                        ValuePicker(store: store.scope(state: \.workoutTimeState, action: AddTimerSegmentAction.changeWorkoutTime),
                                    valueName: "Work",
                                    tint: .blue
                        )

                        ValuePicker(store: store.scope(state: \.breakTimeState, action: AddTimerSegmentAction.changeBreakTime),
                                    valueName: "Break",
                                    tint: .red
                        )
                    }
                    .padding(.horizontal, 28)

                    HStack(spacing: 0) {
                        Button(action: {
                            withAnimation {
                                viewStore.send(viewStore.isEditing ? .done : .add)
                            }
                        }, label: {
                            Image(systemName: viewStore.isEditing ? "checkmark" : "plus")
                                .frame(minWidth: 0, idealWidth: 100, maxWidth: .infinity)
                                .frame(height: 44)
                                .foregroundColor(.appWhite)
                        })
                        .background(Color.appSuccess)

                        Button(action: {
                            withAnimation {
                                viewStore.send(viewStore.isEditing ? .remove : .cancel)
                            }
                        }, label: {
                            Image(systemName: viewStore.isEditing ? "trash" : "xmark")
                                .frame(minWidth: 0, idealWidth: 100, maxWidth: .infinity)
                                .frame(height: 44)
                                .foregroundColor(.appWhite)
                        })
                        .background(Color.red)
                    }
                }
                .background(Color.appCardBackground)
                .cornerRadius(12)
                .padding(28)
            }
        }
    }
}

struct CircuitPickerView_Previews: PreviewProvider {
    static var previews: some View {
        let store = Store<AddTimerSegmentState, AddTimerSegmentAction>(
            initialState: AddTimerSegmentState(id: UUID(), sets: 5, workoutTime: 30, breakTime: 30, isEditing: true),
            reducer: addTimerSegmentReducer,
            environment: AddTimerSegmentEnvironment(uuid: UUID.init)
        )

        return Group {
            AddTimerSegmentView(store: store)
                .padding()
                .previewLayout(.sizeThatFits)

            AddTimerSegmentView(store: store)
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

//        WithViewStore(store) { viewStore in
//            HStack(spacing: 12) {
//                ValuePicker(store: self.store.scope(state: \.setsState, action: AddTimerSegmentAction.changeSetsCount),
//                            valueName: "Sets",
//                            tint: workoutColor.monochromatic(for: colorScheme).color
//                )
//
//                ValuePicker(store: self.store.scope(state: \.workoutTimeState, action: AddTimerSegmentAction.changeWorkoutTime),
//                            valueName: "Work",
//                            tint: workoutColor.monochromatic(for: colorScheme).color
//                )
//
//                ValuePicker(store: self.store.scope(state: \.breakTimeState, action: AddTimerSegmentAction.changeBreakTime),
//                            valueName: "Break",
//                            tint: workoutColor.monochromatic(for: colorScheme).color
//                )
//
//                Button(action: {
//                    withAnimation {
//                        viewStore.send(viewStore.isAdded ? .removeSegments : .addSegments)
//                    }
//                }, label: {
//                    Image(systemName: viewStore.isAdded ? "trash" : "plus")
//                        .frame(width: 18, height: 18)
//                        .padding(10)
//                        .foregroundColor(.appWhite)
//                })
//                .background(viewStore.isAdded ? Color.red : color)
//                .cornerRadius(12)
//                .padding(.leading, 8)
//            }
//            .padding(.horizontal, 28)
//        }
//        .padding(.horizontal, 18)
//        .padding(.vertical, 18)
//        .background(Color.appCardBackground)
//        .cornerRadius(12)
