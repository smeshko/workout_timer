import SwiftUI
import ComposableArchitecture

public struct WorkoutsFeedView: View {
  
  let store: Store<WorkoutsFeedState, WorkoutsFeedAction>
  
  public init(store: Store<WorkoutsFeedState, WorkoutsFeedAction>) {
    self.store = store
  }
  
  public var body: some View {
    NavigationView {
      WithViewStore(store) { viewStore in
        VStack {
          WithViewStore(self.store.scope(state: \.selectedWorkoutType, action: WorkoutsFeedAction.workoutTypeChanged)) { workoutTypeViewStore in
            Picker("Types", selection: workoutTypeViewStore.binding(send: { $0 })) {
              ForEach(WorkoutsFeedState.WorkoutType.allCases, id: \.self) { type in
                Text(type.rawValue).tag(type)
              }
            }
            .padding([.leading, .trailing])
            .labelsHidden()
            .pickerStyle(SegmentedPickerStyle())
            
            if viewStore.selectedWorkoutType == .custom {
              Text("No custom workouts yet")
                .navigationBarItems(trailing: Button(action: {}) {
                  Image(systemName: "plus")
                })
            } else {
              WorkoutsListView(store: self.store.scope(state: \.workoutsListState, action: WorkoutsFeedAction.workoutsList))
                .navigationBarItems(trailing: EmptyView())
            }
            
            Spacer()
          }
          .onAppear {
            viewStore.send(.beginNavigation)
          }
        }
      }
      .navigationBarTitle("Workouts")
    }
  }
}

struct WorkoutsFeedView_Previews: PreviewProvider {
  static var previews: some View {
    WorkoutsFeedView(
      store: Store<WorkoutsFeedState, WorkoutsFeedAction>(
        initialState: WorkoutsFeedState(),
        reducer: workoutsFeedReducer,
        environment: WorkoutsFeedEnvironment(localStorageClient: .mock)
      )
    )
  }
}
