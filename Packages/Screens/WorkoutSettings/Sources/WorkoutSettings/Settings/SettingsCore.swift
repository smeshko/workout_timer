import Foundation
import CoreLogic
import ComposableArchitecture

public enum SettingsAction: BindableAction, Equatable {
    case onAppear
    case binding(BindingAction<SettingsState>)

    case onboarding(PresenterAction)
    case licenses(PresenterAction)
    case bugReport(PresenterAction)
    case featureRequest(PresenterAction)

    case onboardingAction(OnboardingAction)
    case close
}

public struct SettingsState: Equatable {
    @BindableState var isSoundEnabled = false
    @BindableState var keepScreenActive = false
    var versionNumber = ""

    var onboardingState = OnboardingState()

    var mailSubject = ""
    var mailBody = ""

    var isPresentingMailComposer = false
    var isPresentingLicenses = false
    var isPresentingOnboarding = false

    public init(sound: Bool = false, keepScreen: Bool = false) {
        self.isSoundEnabled = sound
        self.keepScreenActive = keepScreen
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
            state.isSoundEnabled = environment.client.value(for: .sound)
            state.keepScreenActive = environment.client.value(for: .screen)

        case .binding(\.$keepScreenActive):
            environment.client.set(.screen, to: state.keepScreenActive)

        case .binding(\.$isSoundEnabled):
            environment.client.set(.sound, to: state.isSoundEnabled)

        case .bugReport(.present):
            state.mailSubject = "Bug report"
            state.mailBody = "Hey team!\n\nI found the following bug:"

        case .featureRequest(.present):
            state.mailSubject = "Feature Request"
            state.mailBody = "Hey team!\n\nI'd like to have the following feature:"

        case .onboardingAction(.start):
            state.isPresentingOnboarding = false

        case .onboarding, .licenses, .bugReport(.dismiss), .featureRequest(.dismiss), .close, .binding:
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
    .binding()
