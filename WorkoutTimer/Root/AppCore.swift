import ComposableArchitecture
import UIKit
import WorkoutFeed
import Foundation
import WorkoutCore
import QuickTimer

enum AppAction {
    case applicationDidStart
}

struct AppState: Equatable {
        
    init() {
    }
}

struct AppEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
    Reducer<AppState, AppAction, AppEnvironment> { state, action, env in
        struct LocalStorageReadId: Hashable {}
         
        switch action {
        case .applicationDidStart:
            break
        }
        
        return .none
    }
)
