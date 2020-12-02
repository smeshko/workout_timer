import Foundation
import CoreLogic
import ComposableArchitecture

public enum SettingsAction: Equatable {
    case toggleScreen(Bool)
    case toggleSound(Bool)
    case onAppear
}

public struct SettingsState: Equatable {
    var sound = false
    var keepScreen = false

    public init(sound: Bool = false, keepScreen: Bool = false) {
        self.sound = sound
        self.keepScreen = keepScreen
    }
}

public struct SettingsEnvironment {

    var client: SettingsClient

    public init(client: SettingsClient) {
        self.client = client
    }
}

public let settingsReducer = Reducer<SettingsState, SettingsAction, SettingsEnvironment> { state, action, environment in

    switch action {
    case .onAppear:
        state.sound = environment.client.soundEnabled
        state.keepScreen = environment.client.keepScreenOn

    case .toggleScreen(let on):
        state.keepScreen = on
        environment.client.setKeepScreenOn(to: on)

    case .toggleSound(let on):
        state.sound = on
        environment.client.setSoundEnabled(to: on)
    }

    return .none
}
