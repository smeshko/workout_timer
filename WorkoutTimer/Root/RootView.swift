import SwiftUI
import Home
import QuickTimer
import WorkoutCore
import ComposableArchitecture
import CorePersistence

struct RootView: View {
    
    let store: Store<AppState, AppAction>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            TabView {
                NavigationView {
                    HomeView()
                }
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
            }
            .accentColor(.appPrimary)
        }
    }
}

extension HomeView {
    init() {
        self.init(
            store: Store<HomeState, HomeAction>(
                initialState: HomeState(),
                reducer: homeReducer,
                environment: HomeEnvironment(
                    mainQueue: DispatchQueue.main.eraseToAnyScheduler()
                )
            )
        )
    }
}
