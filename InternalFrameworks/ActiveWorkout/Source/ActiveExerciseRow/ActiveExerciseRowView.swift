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
          
          Text(viewStore.formattedTimeLeft)
            .font(.system(size: 16, weight: .semibold, design: .monospaced))
            .padding([.horizontal], 16)
          
          Text("\(viewStore.set.name)")
            .padding(.trailing, 16)
          
          Spacer()
        }
        .padding([.vertical], 32)
        
        Divider()
      }
      .onAppear {
        viewStore.send(.exerciseBegin)
      }
    }
  }
}

struct ActiveExerciseRowView_Previews: PreviewProvider {
  static var previews: some View {
    ActiveExerciseRowView(
      store: Store<ActiveExerciseRowState, ActiveExerciseRowAction>(
        initialState: ActiveExerciseRowState(set: ExerciseSet(exercise: self.mockExercise, duration: 30)),
        reducer: activeExerciseRowReducer,
        environment: ActiveExerciseRowEnvironment(
          mainQueue: DispatchQueue.main.eraseToAnyScheduler()
        )
      )
    )
  }
}

extension PreviewProvider {
  static var mockExercise: Exercise {
    Exercise(name: "Mock exercise", image: "preview-exercise-1")
  }
}

struct ProgressBar: View {
  @Binding var value: Double
  
  var body: some View {
    GeometryReader { geometry in
      ZStack(alignment: .leading) {
        Rectangle().frame(width: geometry.size.width , height: geometry.size.height)
          .opacity(0.3)
          .foregroundColor(Color(UIColor.systemTeal))
        
        Rectangle().frame(width: min(CGFloat(self.value) * geometry.size.width, geometry.size.width), height: geometry.size.height)
          .foregroundColor(Color(UIColor.systemBlue))
          .animation(.linear)
      }
    }
  }
}
