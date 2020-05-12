import SwiftUI
import QuickTimer
import ComposableArchitecture

struct RootView: View {
  var body: some View {
    TabView {
      TimerView()
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

extension TimerView {
  init() {
    self.init(
      store: Store<TimerState, TimerAction>(
        initialState: TimerState(),
        reducer: timerReducer,
        environment: TimerEnvironment(
          mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
          soundClient: .live
        )
      )
    )
  }
}
