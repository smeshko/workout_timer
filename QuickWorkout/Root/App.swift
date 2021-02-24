import SwiftUI
import CoreLogic
import ComposableArchitecture
import CorePersistence
import QuickWorkoutsList
import CoreInterface
import WorkoutSettings

@main
struct MainApp: App {
    @Environment(\.scenePhase) var scenePhase

    let store: Store<AppState, AppAction>
    @State var isPresentingOnboarding: Bool = false

    init() {
        store = Store<AppState, AppAction>(
            initialState: AppState(),
            reducer: appReducer,
            environment: .live
        )
    }

    var body: some Scene {
        WithViewStore(store.scope(state: \.view)) { viewStore in
            WindowGroup {
                if isPresentingOnboarding {
                    OnboardingView(store: store.scope(state: \.onboardingState, action: AppAction.onboardingAction))
                } else {
                    QuickWorkoutsListView(store: store.scope(state: \.workoutsListState, action: AppAction.workoutsListAction))
                        .onAppear(perform: UIApplication.shared.addTapGestureRecognizer)
                }
            }
            .onChange(of: scenePhase) { newScenePhase in
                switch newScenePhase {
                case .active:
                    viewStore.send(.appDidBecomeActive)
                case .inactive:
                    viewStore.send(.appDidBecomeInactive)
                case .background:
                    viewStore.send(.appDidGoToBackground)
                @unknown default:
                    break
                }
            }
            .onChange(of: viewStore.shouldShowOnboarding) { value in
                withAnimation {
                    isPresentingOnboarding = value
                }
            }
        }
    }
}

extension UIApplication {
    func addTapGestureRecognizer() {
        guard let window = windows.first else { return }
        let tapGesture = UITapGestureRecognizer(target: window, action: #selector(UIView.endEditing))
        tapGesture.requiresExclusiveTouchType = false
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        window.addGestureRecognizer(tapGesture)
    }
}

extension UIApplication: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}

private struct MainAppState: Equatable {
    var shouldShowOnboarding = false
}

private extension AppState {
    var view: MainAppState {
        MainAppState(shouldShowOnboarding: shouldShowOnboarding)
    }
}
