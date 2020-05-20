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
              
            } else if viewStore.selectedWorkoutType == .jumpRope {
              
              WorkoutsListView(store: self.store.scope(state: \.jumpropeWorkoutsState, action: WorkoutsFeedAction.jumpropeWorkoutsAction))
                .navigationBarItems(trailing: EmptyView())
              
            } else if viewStore.selectedWorkoutType == .bodyweight {
              
              WorkoutsListView(store: self.store.scope(state: \.bodyweightWorkoutsState, action: WorkoutsFeedAction.jumpropeWorkoutsAction))
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
    .navigationViewStyle(StackNavigationViewStyle())
    .accentColor(.primary)
  }
}

struct WorkoutsFeedView_Previews: PreviewProvider {
  static var previews: some View {
    WorkoutsFeedView(
      store: Store<WorkoutsFeedState, WorkoutsFeedAction>(
        initialState: WorkoutsFeedState(),
        reducer: workoutsFeedReducer,
        environment: WorkoutsFeedEnvironment(
          localStorageClient: .mock,
          mainQueue: DispatchQueue.main.eraseToAnyScheduler()
        )
      )
    )
  }
}
