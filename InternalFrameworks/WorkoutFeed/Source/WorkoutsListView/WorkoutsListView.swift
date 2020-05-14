import SwiftUI
import ComposableArchitecture

public struct WorkoutsListView: View {
  
  let store: Store<WorkoutsListState, WorkoutsListAction>
  
  private let tabs = ["Bodyweight", "Jump rope", "Custom"]

  public init(store: Store<WorkoutsListState, WorkoutsListAction>) {
    self.store = store
  }
  
  public var body: some View {
    NavigationView {
      WithViewStore(store) { viewStore in
        if viewStore.workouts.isEmpty {
          VStack {
            Text("It seems you don't have any workouts.\nWhy not create one?")
              .multilineTextAlignment(.center)
            Button(action: {}) {
              Image(systemName: "plus")
            }
          }
        } else {
          ForEach(viewStore.workouts) { workout in
            Text(workout.name ?? "")
          }
          .navigationBarItems(trailing: Button(action: {}) {
            Image(systemName: "plus")
          })
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
