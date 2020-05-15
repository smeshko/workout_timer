import SwiftUI
import WorkoutFeed
import QuickTimer
import ComposableArchitecture

struct RootView: View {
  
  let store: Store<AppState, AppAction>
  
  var body: some View {
    WithViewStore(store) { viewStore in
      TabView {
        WorkoutsFeedView(store: self.store.scope(state: \.workoutsFeedState, action: AppAction.workoutsFeed))
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
      .accentColor(.primary)
      .onAppear {
        viewStore.send(.applicationDidStart)
      }
    }
  }
}

struct RootView_Previews: PreviewProvider {
  static var previews: some View {
    RootView(
      store: Store<AppState, AppAction>(
        initialState: AppState(),
        reducer: appReducer,
        environment: AppEnvironment(
          mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
          localStorageClient: .mock
        )
      )
    )
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
