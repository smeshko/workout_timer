import SwiftUI
import WorkoutDetails
import ComposableArchitecture

struct WorkoutsListView: View {
  
  let store: Store<WorkoutsListState, WorkoutsListAction>
    
  var body: some View {
    WithViewStore(store) { viewStore in
      if viewStore.workouts.isEmpty {
        Text("Sorry, no workouts")
      } else {
        ScrollView {
          ForEach(viewStore.workouts) { workout in
            NavigationLink(destination: WorkoutDetailsView(workout: workout)) {
              WorkoutView(workout: workout)
            }
            .buttonStyle(PlainButtonStyle())
          }
          Spacer()
        }
      }
    }
  }
}

struct WorkoutsListView_Previews: PreviewProvider {
  static var previews: some View {
    WorkoutsListView(
      store: Store<WorkoutsListState, WorkoutsListAction>(
        initialState: WorkoutsListState(),
        reducer: workoutsListReducer,
        environment: WorkoutsListEnvironment()
      )
    )
  }
}
