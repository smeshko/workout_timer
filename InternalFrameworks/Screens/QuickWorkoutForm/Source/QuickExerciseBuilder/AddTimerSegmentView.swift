import SwiftUI
import DomainEntities
import ComposableArchitecture
import CoreInterface

struct AddTimerSegmentView: View {
    @Environment(\.colorScheme) var colorScheme

    let store: Store<AddTimerSegmentState, AddTimerSegmentAction>
    let color: Color

    private var workoutColor: WorkoutColor {
        WorkoutColor(color: color)
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            HStack(spacing: 12) {
                ValuePicker(store: self.store.scope(state: \.setsState, action: AddTimerSegmentAction.changeSetsCount),
                            valueName: "Sets",
                            tint: workoutColor.monochromatic(for: colorScheme).color
                )

                ValuePicker(store: self.store.scope(state: \.workoutTimeState, action: AddTimerSegmentAction.changeWorkoutTime),
                            valueName: "Work",
                            tint: workoutColor.monochromatic(for: colorScheme).color
                )

                ValuePicker(store: self.store.scope(state: \.breakTimeState, action: AddTimerSegmentAction.changeBreakTime),
                            valueName: "Break",
                            tint: workoutColor.monochromatic(for: colorScheme).color
                )

                Button(action: {
                    withAnimation {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
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
                .padding(.leading, 8)
            }
            .padding(.horizontal, 28)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 18)
        .background(Color.appCardBackground)
        .cornerRadius(12)
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

private extension WorkoutColor {
    func monochromatic(for scheme: ColorScheme) -> WorkoutColor {
        let brightnessModifier = scheme == .dark ? 0.3 : -0.3
        return WorkoutColor(hue: hue,
                            saturation: saturation + 0.2,
                            brightness: brightness + brightnessModifier)
    }
}
