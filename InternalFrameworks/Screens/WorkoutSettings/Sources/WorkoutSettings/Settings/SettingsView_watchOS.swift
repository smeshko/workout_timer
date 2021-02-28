import SwiftUI
import CoreInterface
import ComposableArchitecture
import StoreKit

#if os(watchOS)
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
                        Toggle("settings_enable_sound".localized, isOn: viewStore.binding(get: \.sound, send: SettingsAction.toggleSound))
                        Text(key: "settings_enable_sound_descr")
                            .font(.bodySmall)
                            .padding(.bottom, Spacing.xxs)
                    }
                    VStack(alignment: .leading) {
                        Toggle("settings_keep_screen".localized, isOn: viewStore.binding(get: \.keepScreen, send: SettingsAction.toggleScreen))
                        Text(key: "settings_keep_screen_descr")
                            .font(.bodySmall)
                            .padding(.bottom, Spacing.xxs)
                    }
                }

                Section(header: Text(key: "settings_support")) {
                    OnboardingButton(store: store)
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
