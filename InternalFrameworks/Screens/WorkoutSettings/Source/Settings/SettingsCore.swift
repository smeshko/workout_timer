import Foundation
import CoreLogic
import ComposableArchitecture

public enum SettingsAction: Equatable {
    case toggleScreen(Bool)
    case toggleSound(Bool)
    case onAppear

    case onboarding(PresenterAction)
    case licenses(PresenterAction)
    case bugReport(PresenterAction)
    case featureRequest(PresenterAction)

    case onboardingAction(OnboardingAction)
}

public struct SettingsState: Equatable {
    var sound = false
    var keepScreen = false
    var versionNumber = ""

    var onboardingState = OnboardingState()

    var mailSubject = ""
    var mailBody = ""

    var isPresentingMailComposer = false
    var isPresentingLicenses = false
    var isPresentingOnboarding = false

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

public let settingsReducer = Reducer<SettingsState, SettingsAction, SettingsEnvironment>.combine(

    Reducer<SettingsState, SettingsAction, SettingsEnvironment> { state, action, environment in

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

        case .bugReport(.present):
            state.mailSubject = "Bug report"
            state.mailBody = "Hey team!\n\nI found the following bug:"

        case .featureRequest(.present):
            state.mailSubject = "Feature Request"
            state.mailBody = "Hey team!\n\nI'd like to have the following feature:"

        case .onboardingAction(.start):
            state.isPresentingOnboarding = false

        case .onboarding, .licenses, .bugReport(.dismiss), .featureRequest(.dismiss):
            break
        }

        return .none
    }
    .presenter(
        keyPath: \.isPresentingOnboarding,
        action: /SettingsAction.onboarding
    )
    .presenter(
        keyPath: \.isPresentingLicenses,
        action: /SettingsAction.licenses
    )
    .presenter(
        keyPath: \.isPresentingMailComposer,
        action: /SettingsAction.bugReport
    )
    .presenter(
        keyPath: \.isPresentingMailComposer,
        action: /SettingsAction.featureRequest
    ),
    onboardingReducer.pullback(
        state: \.onboardingState,
        action: /SettingsAction.onboardingAction,
        environment: { _ in }
    )
)
