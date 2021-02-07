import SwiftUI
import CoreInterface
import ComposableArchitecture
import StoreKit

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
                Section(header: Text("Customization")) {
                    VStack(alignment: .leading) {
                        Toggle("Enable sound", isOn: viewStore.binding(get: \.sound, send: SettingsAction.toggleSound))
                        Text("The app plays sounds while the timer is running or when an interval is finished.")
                            .font(.bodySmall)
                            .padding(.bottom, Spacing.xxs)
                    }
                    VStack(alignment: .leading) {
                        Toggle("Keep screen on", isOn: viewStore.binding(get: \.keepScreen, send: SettingsAction.toggleScreen))
                        Text("Choose to disable auto-locking the screen while using the app.")
                            .font(.bodySmall)
                            .padding(.bottom, Spacing.xxs)
                    }
                }

                Section(header: Text("Support")) {
                    if MailView.canSendEmail {
                        MailButtons(store: store)
                    }
                    OnboardingButton(store: store)

                    Button("Rate the app") {
                        if let windowScene = UIApplication.shared.windows.first?.windowScene {
                            SKStoreReviewController.requestReview(in: windowScene)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }

                Section(header: Text("Legal")) {
                    Button("Privacy policy") {

                    }
                    .buttonStyle(PlainButtonStyle())

                    LicensesButton(store: store)
                }

                Text("Version \(viewStore.versionNumber)")
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
            .navigationTitle("Settings")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(
            store: Store<SettingsState, SettingsAction>(
                initialState: SettingsState(),
                reducer: settingsReducer,
                environment: SettingsEnvironment(client: .mock)
            )
        )
    }
}

private struct OnboardingButton: View {
    private let store: Store<SettingsState, SettingsAction>
    @ObservedObject private var viewStore: ViewStore<SettingsState, SettingsAction>

    public init(store: Store<SettingsState, SettingsAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    var body: some View {
        Button("Show onboarding") {
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
            Button("Report a bug") {
                viewStore.send(.bugReport(.present))
            }
            .buttonStyle(PlainButtonStyle())

            Button("Feature request") {
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
        Button("Licenses") {
            viewStore.send(.licenses(.present))
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: viewStore.binding(get: \.isPresentingLicenses),
               onDismiss: { viewStore.send(.licenses(.dismiss)) },
               content: LicensesView.init
        )
    }
}
