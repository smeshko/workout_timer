import SwiftUI
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
                        Toggle("Enable sound", isOn: viewStore.binding(get: \.sound, send: SettingsAction.toggleSound))
                        Toggle("Enable iCloud sync", isOn: viewStore.binding(get: \.iCloud, send: SettingsAction.toggleiCloud))
                        Toggle("Keep screen on", isOn: viewStore.binding(get: \.keepScreen, send: SettingsAction.toggleScreen))
                    }

                    Section(header: Text("App")) {
                        Text("facebook")
                    }
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
