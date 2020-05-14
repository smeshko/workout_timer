import ComposableArchitecture
import WorkoutCore
import QuickTimer

enum AppAction: Equatable {
  case applicationDidStart
}

struct AppState: Equatable {}

struct AppEnvironment {
  var localStorageClient: LocalStorageClient
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action, env in
  
  
  return .none
}
