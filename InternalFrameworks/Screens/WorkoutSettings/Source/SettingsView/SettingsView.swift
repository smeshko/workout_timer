import SwiftUI
import CoreInterface
import ComposableArchitecture

public struct SettingsView: View {

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    let store: Store<SettingsState, SettingsAction>

    public init(store: Store<SettingsState, SettingsAction>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                Form {
                    Section(header: Text("Customization")) {
                        VStack(alignment: .leading) {
                            Toggle("Enable sound", isOn: viewStore.binding(get: \.sound, send: SettingsAction.toggleSound))
                            Text("The app plays sounds while the timer is running or when an interval is finished.")
                                .font(.bodySmall)
                        }
                        VStack(alignment: .leading) {
                            Toggle("Keep screen on", isOn: viewStore.binding(get: \.keepScreen, send: SettingsAction.toggleScreen))
                            Text("Choose to disable auto-locking the screen while using the app.")
                                .font(.bodySmall)
                        }
                    }

                    Section(header: Text("Support")) {
                        Text("Show onboarding again")
                        Text("Report a bug")
                        Text("Feature request")
                        Text("Rate the app")
                    }

                    Section(header: Text("Contact")) {
                        Text("facebook")
                        Text("twitter")
                        Text("email")
                        Text("Homepage")
                    }

                    Section(header: Text("Legal")) {
                        Text("Privacy policy")
                        Text("Licenses")
                        Text("email")
                    }

                    Text("Version 0.2.0")
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
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
