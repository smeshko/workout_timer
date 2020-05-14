import SwiftUI
import WorkoutFeed
import QuickTimer
import ComposableArchitecture

struct RootView: View {
  var body: some View {
    TabView {
      WorkoutsFeedView()
        .tabItem {
          Image(systemName: "heart")
          Text("Workouts")
      }

      QuickTimerView()
        .tabItem {
          Image(systemName: "timer")
          Text("Quick timer")
      }
    }
  }
}

struct RootView_Previews: PreviewProvider {
  static var previews: some View {
    RootView()
  }
}

extension QuickTimerView {
  init() {
    self.init(
      store: Store<QuickTimerState, QuickTimerAction>(
        initialState: QuickTimerState(),
        reducer: quickTimerReducer,
        environment: QuickTimerEnvironment(
          mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
          soundClient: .mock
        )
      )
    )
  }
}

extension WorkoutsFeedView {
  init() {
    self.init(
      store: Store<WorkoutsFeedState, WorkoutsFeedAction>(
        initialState: WorkoutsFeedState(),
        reducer: workoutsFeedReducer,
        environment: WorkoutsFeedEnvironment()
      )
    )
  }
}
