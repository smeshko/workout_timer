import ComposableArchitecture
import TimerCore
import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let contentView = TimerView(
            store: Store<TimerState, TimerAction>(
                initialState: TimerState(
                  sets: PickerState(value: 2),
                  workoutTime: PickerState(value: 60),
                  breakTime: PickerState(value: 20)
                ),
                reducer: timerReducer,
                environment: TimerEnvironment(
                    mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
                    soundClient: .live
                )
            )
        )

        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }
}

