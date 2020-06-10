import SwiftUI
import ComposableArchitecture
import Foundation

struct QuickExerciseBuilderView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
    
    let store: Store<QuickExerciseBuilderState, QuickExerciseBuilderAction>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            Group {
                if self.horizontalSizeClass == .compact {
                    VStack(spacing: 16, content: self.content)
                } else {
                    HStack(spacing: 16, content: self.content)
                }
            }
            .onAppear {
                viewStore.send(.setNavigation)
            }
        }
    }
    
    func content() -> some View {
        Group {
            ValuePicker(store: self.store.scope(state: \.setsState, action: QuickExerciseBuilderAction.changeSetsCount),
                        valueName: "Sets",
                        maxValue: 21,
                        tint: .orange
            )
            
            ValuePicker(store: self.store.scope(state: \.workoutTimeState, action: QuickExerciseBuilderAction.changeWorkoutTime),
                        valueName: "Workout Time",
                        maxValue: 241,
                        tint: .red
            )
            
            ValuePicker(store: self.store.scope(state: \.breakTimeState, action: QuickExerciseBuilderAction.changeBreakTime),
                        valueName: "Break Time",
                        maxValue: 121,
                        tint: .purple
            )
        }
    }
}

struct CircuitPickerView_Previews: PreviewProvider {
    static var previews: some View {
        QuickExerciseBuilderView(
            store: Store<QuickExerciseBuilderState, QuickExerciseBuilderAction>(
                initialState: QuickExerciseBuilderState(sets: 5, workoutTime: 30, breakTime: 30),
                reducer: quickExerciseBuilderReducer,
                environment: QuickExerciseBuilderEnvironment(uuid: UUID.init)
            )
        )
    }
}
