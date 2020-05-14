import ComposableArchitecture
import QuickTimer
import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  
  var window: UIWindow?
  
  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    let contentView = RootView(
      store: Store<AppState, AppAction>(
        initialState: AppState(),
        reducer: appReducer,
        environment: AppEnvironment(
          mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
          localStorageClient: .live
        )
      )
    )
    
    if let windowScene = scene as? UIWindowScene {
      let window = UIWindow(windowScene: windowScene)
      window.rootViewController = UIHostingController(rootView: contentView)
      self.window = window
      window.makeKeyAndVisible()
    }
    
    disableIdleTimer()
    
  }
  
  private func disableIdleTimer() {
    UIApplication.shared.isIdleTimerDisabled = true
  }
}
