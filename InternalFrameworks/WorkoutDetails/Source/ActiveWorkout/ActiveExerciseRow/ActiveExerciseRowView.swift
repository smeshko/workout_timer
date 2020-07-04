import SwiftUI
import ComposableArchitecture
import WorkoutCore

struct ActiveExerciseRowView: View {
  
  let store: Store<ActiveExerciseRowState, ActiveExerciseRowAction>
  
  var body: some View {
    WithViewStore(store) { viewStore in
      VStack(spacing: 0) {
        Divider()
        
        HStack(spacing: 0) {
          
          Text(viewStore.secondsLeft.formattedTimeLeft)
            .font(.system(size: 16, weight: .semibold, design: .monospaced))
            .padding([.horizontal], 16)
          
          Text("\(viewStore.set.name)")
            .padding(.trailing, 16)
          
          Spacer()
        }
        .padding([.vertical], 32)
        .background(viewStore.isActive ?
            AnyView(ProgressView(
                value: viewStore.binding(
                    get: \.progress,
                    send: ActiveExerciseRowAction.progressBarDidUpdate),
                axis: .horizontal)) :
            AnyView(Color(.systemGray).opacity(0.2))
        )
        
        Divider()
      }
    }
  }
}

struct ActiveExerciseRowView_Previews: PreviewProvider {
  static var previews: some View {
    ActiveExerciseRowView(
      store: Store<ActiveExerciseRowState, ActiveExerciseRowAction>(
        initialState: ActiveExerciseRowState(set: ExerciseSet(id: "setid", exercise: mockExercise1, duration: 30)),
        reducer: activeExerciseRowReducer,
        environment: ActiveExerciseRowEnvironment()
      )
    )
  }
}
