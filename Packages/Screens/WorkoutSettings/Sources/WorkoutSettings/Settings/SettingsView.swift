import SwiftUI
import CoreInterface
import ComposableArchitecture
import StoreKit

#if os(iOS)
public struct SettingsView: View {

    private let store: Store<SettingsState, SettingsAction>
    @ObservedObject private var viewStore: ViewStore<SettingsState, SettingsAction>

    public init(store: Store<SettingsState, SettingsAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    public var body: some View {
        NavigationView {
            Form {
                Section(header: Text(key: "settings_customization")) {
                    VStack(alignment: .leading) {
                        Toggle("settings_enable_sound".localized, isOn: viewStore.binding(\.$isSoundEnabled))
                        Text(key: "settings_enable_sound_descr")
                            .fixedSize(horizontal: false, vertical: true)
                            .font(.bodySmall)
                            .padding(.bottom, Spacing.xxs)
                    }
                    VStack(alignment: .leading) {
                        Toggle("settings_keep_screen".localized, isOn: viewStore.binding(\.$keepScreenActive))
                        Text(key: "settings_keep_screen_descr")
                            .fixedSize(horizontal: false, vertical: true)
                            .font(.bodySmall)
                            .padding(.bottom, Spacing.xxs)
                    }
                }

                Section(header: Text(key: "settings_support")) {
                    if MailView.canSendEmail {
                        MailButtons(store: store)
                    }
                    OnboardingButton(store: store)

                    Button(key: "settings_rate_app") {
                        if let windowScene = UIApplication.activeScene {
                            SKStoreReviewController.requestReview(in: windowScene)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }

                Section(header: Text(key: "settings_legal")) {
                    Link("settings_privacy_policy".localized, destination: URL(string: "https://pbandswift.com/privacy/")!)
                        .buttonStyle(PlainButtonStyle())

                    LicensesButton(store: store)
                }

                Text(key: "settings_version \(viewStore.versionNumber)")
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewStore.send(.close)
                    }, label: {
                        Image(systemName: "xmark")
                    })
                }
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
            .navigationTitle("settings".localized)
        }
    }
}

//struct SettingsView_Previews: PreviewProvider {
//    static var previews: some View {
//        SettingsView(
//            store: Store<SettingsState, SettingsAction>(
//                initialState: SettingsState(),
//                reducer: settingsReducer,
//                environment: SettingsEnvironment(client: .mock)
//            )
//        )
//    }
//}

private struct OnboardingButton: View {
    private let store: Store<SettingsState, SettingsAction>
    @ObservedObject private var viewStore: ViewStore<SettingsState, SettingsAction>

    public init(store: Store<SettingsState, SettingsAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    var body: some View {
        Button(key: "settings_show_onboarding") {
            viewStore.send(.onboarding(.present))
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(
            isPresented: viewStore.binding(get: \.isPresentingOnboarding),
            onDismiss: { viewStore.send(.onboarding(.dismiss)) },
            content: {
                OnboardingView(store: store.scope(state: \.onboardingState, action: SettingsAction.onboardingAction))
            })
    }
}

private struct MailButtons: View {
    private let store: Store<SettingsState, SettingsAction>
    @ObservedObject private var viewStore: ViewStore<SettingsState, SettingsAction>

    public init(store: Store<SettingsState, SettingsAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    var body: some View {
        Group {
            Button(key: "settings_report") {
                viewStore.send(.bugReport(.present))
            }
            .buttonStyle(PlainButtonStyle())

            Button(key: "settings_request") {
                viewStore.send(.featureRequest(.present))
            }
            .buttonStyle(PlainButtonStyle())
            .sheet(isPresented: viewStore.binding(get: \.isPresentingMailComposer), content: {
                MailView(subject: viewStore.mailSubject, body: viewStore.mailBody) {
                    viewStore.send(.bugReport(.dismiss))
                }
            })
        }
    }
}

private struct LicensesButton: View {
    private let store: Store<SettingsState, SettingsAction>
    @ObservedObject private var viewStore: ViewStore<SettingsState, SettingsAction>

    public init(store: Store<SettingsState, SettingsAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    var body: some View {
        Button(key: "licenses") {
            viewStore.send(.licenses(.present))
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: viewStore.binding(get: \.isPresentingLicenses),
               onDismiss: { viewStore.send(.licenses(.dismiss)) },
               content: { LicensesView(store: store) }
        )
    }
}
#endif

private extension UIApplication {
    static var activeScene: UIWindowScene? {
        UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .first(where: { $0 is UIWindowScene })
        as? UIWindowScene
    }

    static var keyWindow: UIWindow? {
        activeScene?
            .windows
            .first(where: \.isKeyWindow)
    }
}
