import SwiftUI
import Home
import QuickTimer
import WorkoutCore
import ComposableArchitecture

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


                NavigationView {
                    QuickTimerView()
                }
                .tabItem {
                    Image(systemName: "timer")
                    Text("Quick timer")
                }
                .background(Color.appBackground)

            }
            .accentColor(.appPrimary)
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
                    mainQueue: DispatchQueue.main.eraseToAnyScheduler()
                )
            )
        )
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

extension QuickTimerView {
    init() {
        self.init(
            store: Store<QuickTimerState, QuickTimerAction>(
                initialState: QuickTimerState(),
                reducer: quickTimerReducer,
                environment: QuickTimerEnvironment(
                    uuid: UUID.init,
                    mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
                    soundClient: .live
                )
            )
        )
    }
}

extension UITabBar {
    override open func didMoveToSuperview() {
        super.didMoveToSuperview()
        GlobalTabBar.tabBar = self
    }
}
