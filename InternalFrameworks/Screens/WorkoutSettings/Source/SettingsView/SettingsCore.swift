import Foundation
import CoreLogic
import ComposableArchitecture

public enum SettingsAction: Equatable {
    case toggleScreen(Bool)
    case toggleSound(Bool)
    case sendBugReport
    case sendFeatureRequest
    case didPresentMailComposer
    case didFinishComposingMail
    case onAppear
}

public struct SettingsState: Equatable {
    var sound = false
    var keepScreen = false
    var versionNumber = ""

    var mailSubject = ""
    var mailBody = ""

    var isPresentingMailComposer = false

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
        state.versionNumber = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        state.sound = environment.client.soundEnabled
        state.keepScreen = environment.client.keepScreenOn

    case .toggleScreen(let on):
        state.keepScreen = on
        environment.client.setKeepScreenOn(to: on)

    case .toggleSound(let on):
        state.sound = on
        environment.client.setSoundEnabled(to: on)

    case .sendBugReport:
        state.mailSubject = "Bug report"
        state.mailBody = "Hey team!\n\nI found the following bug:"
        state.isPresentingMailComposer = true

    case .sendFeatureRequest:
        state.mailSubject = "Feature Request"
        state.mailBody = "Hey team!\n\nI'd like to have the following feature:"
        state.isPresentingMailComposer = true

    case .didPresentMailComposer:
        break

    case .didFinishComposingMail:
        state.isPresentingMailComposer = false
    }

    return .none
}
