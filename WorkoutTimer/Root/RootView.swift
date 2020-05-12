import SwiftUI
import QuickTimer
import ComposableArchitecture

struct RootView: View {
  var body: some View {
    TabView {
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
        reducer: timerReducer,
        environment: QuickTimerEnvironment(
          mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
          soundClient: .live
        )
      )
    )
  }
}
